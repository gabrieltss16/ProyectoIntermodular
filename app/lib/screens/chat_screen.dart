import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/azure_openai_service.dart';
import '../services/auth_service.dart';
import '../services/chat_usage_limiter.dart';
import '../services/firebase_bootstrap.dart';
import '../services/routine_repository.dart';
import '../models/routine.dart';
import 'routine_editor_screen.dart';
import 'routines_screen.dart';

class ChatScreen extends StatefulWidget {
  final CatalogData data;

  const ChatScreen({super.key, required this.data});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final bool fromUser;
  final String text;

  _ChatMessage({required this.fromUser, required this.text});
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  bool _sending = false;
  final _limiter = ChatUsageLimiter();

  final _routineRepo = RoutineRepository();
  _PendingRoutine? _pendingRoutine;
  bool _showGoToRoutines = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      fromUser: false,
      text: 'Hola. Soy tu asistente (demo). Pregúntame sobre ejercicios o zonas (rodilla, hombro…).',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .trim();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El mensaje es demasiado largo (máx. 500 caracteres).')),
      );
      return;
    }

    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(fromUser: true, text: text));
      _ctrl.clear();
    });

    String reply;
    try {
      reply = await _respondAsync(text);
    } catch (_) {
      reply = 'He tenido un problema procesando tu mensaje. Inténtalo de nuevo en unos segundos.';
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(fromUser: false, text: reply));
      _sending = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> _respondAsync(String userText) async {
    final lower = _normalize(userText);

    if (lower == 'ayuda' || lower == 'help') {
      return 'Comandos útiles:\n'
          '• zonas\n'
          '• rutina hombro\n'
          '• guardar rutina\n'
          '• limpiar chat\n'
          '• cancelar rutina';
    }

    if (lower == 'limpiar chat') {
      _messages
        ..clear()
        ..add(
          _ChatMessage(
            fromUser: false,
            text: 'Chat reiniciado. Puedes preguntarme por una zona o pedir una rutina.',
          ),
        );
      _pendingRoutine = null;
      _showGoToRoutines = false;
      return 'Listo, he limpiado la conversación.';
    }

    if (lower == 'cancelar rutina') {
      _pendingRoutine = null;
      _showGoToRoutines = false;
      return 'Rutina pendiente cancelada.';
    }

    // Prefer local routine generation (no Azure tokens) when the user asks for a routine.
    if (lower.startsWith('rutina ') || lower.startsWith('crear rutina ') || lower.contains('hazme rutina')) {
      return _respondRoutineLocal(userText);
    }

    // Save routine if the user confirms.
    if (lower == 'guardar rutina' || lower == 'guarda rutina') {
      return await _savePendingRoutine();
    }

    if (AzureOpenAIConfig.isConfigured) {
      try {
        final uid = FirebaseBootstrap.isReady ? AuthService().currentUser()?.uid : null;
        final userKey = uid ?? 'guest';

        final ok = await _limiter.tryConsume(userKey: userKey);
        if (!ok) {
          return 'Has alcanzado el límite diario de consultas (10). Vuelve mañana.';
        }

        // Keep only the last few turns to reduce token usage.
        final history = <Map<String, String>>[];
        final take = 10;
        final start = (_messages.length - 1 - take);
        final from = start < 0 ? 0 : start;

        for (final m in _messages.sublist(from, _messages.length - 1)) {
          history.add({
            'role': m.fromUser ? 'user' : 'assistant',
            'content': m.text,
          });
        }

        return await AzureOpenAIService(data: widget.data).reply(
          userText: userText,
          history: history,
        );
      } catch (_) {
        return _respondDemo(userText);
      }
    }

    return _respondDemo(userText);
  }

  String _respondRoutineLocal(String userText) {
    final lower = _normalize(userText);
    final zoneName = lower
        .replaceFirst('crear rutina', '')
        .replaceFirst('rutina', '')
        .replaceFirst('hazme', '')
        .trim();

    final zone = widget.data.zones.where((z) {
      final normalizedZone = _normalize(z.nombre);
      return normalizedZone == zoneName || normalizedZone.contains(zoneName) || zoneName.contains(normalizedZone);
    }).toList();
    if (zone.isEmpty) {
      return 'No encuentro esa zona. Prueba con: ${widget.data.zones.map((z) => z.nombre).join(', ')}.';
    }

    final exercises = widget.data.exercises.where((e) => e.zonaId == zone.first.id).toList();
    if (exercises.isEmpty) {
      return 'No tengo ejercicios cargados para ${zone.first.nombre} todavía.';
    }

    final picked = exercises.take(5).toList();
    final ids = picked.map((e) => e.id).toList();
    final list = picked.map((e) => '• ${e.nombre} (${e.series}x${e.repeticiones})').join('\n');

    final name = '${zone.first.nombre} · rutina rápida';
    _pendingRoutine = _PendingRoutine(
      nombre: name,
      descripcion: 'Generada desde el chat (catálogo local).',
      exerciseIds: ids,
    );
    _showGoToRoutines = false;

    return 'Rutina sugerida para ${zone.first.nombre}:\n$list\n\n'
        'Si quieres que la guarde en “Mis rutinas”, escribe: guardar rutina.';
  }

  Future<String> _savePendingRoutine() async {
    final pending = _pendingRoutine;
    if (pending == null) {
      return 'No tengo ninguna rutina pendiente. Pídeme una con “rutina hombro” (por ejemplo).';
    }

    final uid = FirebaseBootstrap.isReady ? AuthService().currentUser()?.uid : null;
    if (uid == null) {
      return 'Para guardar rutinas necesitas iniciar sesión (RF08: en invitado no se guardan).';
    }

    final routine = Routine.create(
      nombre: pending.nombre,
      descripcion: pending.descripcion,
      creadaPorIA: true,
      exerciseIds: pending.exerciseIds,
    );

    try {
      await _routineRepo.upsert(uid: uid, routine: routine);
      _pendingRoutine = null;
      _showGoToRoutines = true;
      return 'Listo. He guardado la rutina en “Mis rutinas”.';
    } catch (e) {
      return 'No he podido guardarla: $e';
    }
  }

  Future<String> _editAndSavePendingRoutine() async {
    final pending = _pendingRoutine;
    if (pending == null) {
      return 'No tengo ninguna rutina pendiente para editar.';
    }

    final uid = FirebaseBootstrap.isReady ? AuthService().currentUser()?.uid : null;
    if (uid == null) {
      return 'Para guardar rutinas necesitas iniciar sesión (RF08: en invitado no se guardan).';
    }

    final draft = Routine.create(
      nombre: pending.nombre,
      descripcion: pending.descripcion,
      creadaPorIA: true,
      exerciseIds: pending.exerciseIds,
    );

    final edited = await Navigator.push<Routine?>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          data: widget.data,
          initial: draft,
          creadaPorIA: true,
        ),
      ),
    );

    if (edited == null) {
      return 'Edición cancelada. La rutina sigue pendiente; puedes guardarla cuando quieras.';
    }

    try {
      await _routineRepo.upsert(uid: uid, routine: edited);
      _pendingRoutine = null;
      _showGoToRoutines = true;
      return 'Perfecto. He guardado la rutina editada en “Mis rutinas”.';
    } catch (e) {
      return 'No he podido guardarla: $e';
    }
  }

  Future<void> _openMyRoutines() async {
    final uid = FirebaseBootstrap.isReady ? AuthService().currentUser()?.uid : null;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para ver tus rutinas.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutinesScreen(data: widget.data, uid: uid),
      ),
    );
  }

  Future<void> _runPendingAction(Future<String> Function() action) async {
    if (_sending) return;

    setState(() => _sending = true);
    final reply = await action();
    if (!mounted) return;

    setState(() {
      _messages.add(_ChatMessage(fromUser: false, text: reply));
      _sending = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _respondDemo(String userText) {
    final lower = _normalize(userText);

    final zones = widget.data.zones.map((z) => _normalize(z.nombre)).toList();
    final matchedZone = zones.where(lower.contains).toList();

    if (lower.contains('dolor') || lower.contains('fuerte') || lower.contains('hinch')) {
      return 'Si el dolor es intenso, aparece hinchazón o empeora, lo recomendable es consultar con un profesional. '
          'Puedo ayudarte a repasar ejercicios suaves del catálogo si quieres decirme la zona.';
    }

    if (lower.contains('zona') || lower.contains('zonas')) {
      return 'Zonas disponibles: ${widget.data.zones.map((z) => z.nombre).join(', ')}.';
    }

    if (matchedZone.isNotEmpty) {
      final zoneName = matchedZone.first;
      final zone = widget.data.zones.firstWhere(
        (z) => _normalize(z.nombre) == zoneName,
        orElse: () => widget.data.zones.first,
      );
      final exercises = widget.data.exercises.where((e) => e.zonaId == zone.id).toList();
      if (exercises.isEmpty) {
        return 'No tengo ejercicios cargados para $zoneName todavía.';
      }

      final sample = exercises.take(3).map((e) => '• ${e.nombre} (${e.series}x${e.repeticiones})').join('\n');
      return 'Para $zoneName, puedes probar:\n$sample\n\nSi quieres, dime “rutina $zoneName” y te propongo una secuencia (demo).';
    }

    if (lower.startsWith('rutina ')) {
      final zoneName = lower.replaceFirst('rutina', '').trim();
      final zone = widget.data.zones.where((z) => _normalize(z.nombre) == zoneName).toList();
      if (zone.isEmpty) {
        return 'No encuentro esa zona. Prueba con: ${widget.data.zones.map((z) => z.nombre).join(', ')}.';
      }

      final exercises = widget.data.exercises.where((e) => e.zonaId == zone.first.id).toList();
      final sample = exercises.take(5).map((e) => '• ${e.nombre}').join('\n');
      return 'Rutina sugerida (demo) para ${zone.first.nombre}:\n$sample\n\nRecuerda: adapta la intensidad y para si hay dolor.';
    }

    final names = widget.data.exercises.map((e) => _normalize(e.nombre)).toList();
    final maybeExercise = names.where(lower.contains).toList();
    if (maybeExercise.isNotEmpty) {
      final name = maybeExercise.first;
      final e = widget.data.exercises.firstWhere((x) => _normalize(x.nombre) == name);
      return '${e.nombre}: ${e.descripcion}\n\nSeries/Reps: ${e.series}x${e.repeticiones}.';
    }

    return 'Ahora mismo estoy en modo demo sin Azure OpenAI. '
        'Puedo listar zonas (“zonas”), sugerir ejercicios si me dices una zona (ej. “rodilla”) o describir un ejercicio del catálogo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente (IA)')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final align = m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final color = m.fromUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest;

                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_pendingRoutine != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Rutina pendiente: ${_pendingRoutine!.nombre}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _sending
                                ? null
                                : () => _runPendingAction(_savePendingRoutine),
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _sending
                                ? null
                                : () => _runPendingAction(_editAndSavePendingRoutine),
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar y guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showGoToRoutines)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _openMyRoutines,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Ir a Mis rutinas'),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu pregunta…',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_sending,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Enviar',
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingRoutine {
  final String nombre;
  final String descripcion;
  final List<String> exerciseIds;

  const _PendingRoutine({
    required this.nombre,
    required this.descripcion,
    required this.exerciseIds,
  });
}
