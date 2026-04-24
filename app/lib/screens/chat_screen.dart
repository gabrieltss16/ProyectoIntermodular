import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/azure_openai_service.dart';
import '../services/auth_service.dart';
import '../services/chat_usage_limiter.dart';
import '../services/firebase_bootstrap.dart';
import '../services/routine_repository.dart';
import '../models/routine.dart';

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

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(fromUser: true, text: text));
      _ctrl.clear();
    });

    final reply = await _respondAsync(text);

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
    final lower = userText.toLowerCase().trim();

    // Prefer local routine generation (no Azure tokens) when the user asks for a routine.
    if (lower.startsWith('rutina ') || lower.startsWith('crear rutina ')) {
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
    final lower = userText.toLowerCase().trim();
    final zoneName = lower
        .replaceFirst('crear rutina', '')
        .replaceFirst('rutina', '')
        .trim();

    final zone = widget.data.zones.where((z) => z.nombre.toLowerCase() == zoneName).toList();
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
      return 'Listo. He guardado la rutina en “Mis rutinas”.';
    } catch (e) {
      return 'No he podido guardarla: $e';
    }
  }

  String _respondDemo(String userText) {
    final lower = userText.toLowerCase();

    final zones = widget.data.zones.map((z) => z.nombre.toLowerCase()).toList();
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
        (z) => z.nombre.toLowerCase() == zoneName,
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
      final zone = widget.data.zones.where((z) => z.nombre.toLowerCase() == zoneName).toList();
      if (zone.isEmpty) {
        return 'No encuentro esa zona. Prueba con: ${widget.data.zones.map((z) => z.nombre).join(', ')}.';
      }

      final exercises = widget.data.exercises.where((e) => e.zonaId == zone.first.id).toList();
      final sample = exercises.take(5).map((e) => '• ${e.nombre}').join('\n');
      return 'Rutina sugerida (demo) para ${zone.first.nombre}:\n$sample\n\nRecuerda: adapta la intensidad y para si hay dolor.';
    }

    final names = widget.data.exercises.map((e) => e.nombre.toLowerCase()).toList();
    final maybeExercise = names.where(lower.contains).toList();
    if (maybeExercise.isNotEmpty) {
      final name = maybeExercise.first;
      final e = widget.data.exercises.firstWhere((x) => x.nombre.toLowerCase() == name);
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
