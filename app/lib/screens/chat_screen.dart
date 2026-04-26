import 'dart:convert';

import 'package:fisioia/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String? zoneId; // Si no es null, es una recomendación de ejercicios
  final List<String>? suggestedExerciseIds;
  final String? suggestedRoutineName;

  _ChatMessage({
    required this.fromUser,
    required this.text,
    this.zoneId,
    this.suggestedExerciseIds,
    this.suggestedRoutineName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUser': fromUser,
      'text': text,
      'zoneId': zoneId,
      'suggestedExerciseIds': suggestedExerciseIds,
      'suggestedRoutineName': suggestedRoutineName,
    };
  }

  factory _ChatMessage.fromJson(Map<String, dynamic> json) {
    final ids = (json['suggestedExerciseIds'] as List?)?.map((e) => e.toString()).toList();
    return _ChatMessage(
      fromUser: json['fromUser'] == true,
      text: (json['text'] as String?) ?? '',
      zoneId: json['zoneId'] as String?,
      suggestedExerciseIds: ids,
      suggestedRoutineName: json['suggestedRoutineName'] as String?,
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  static const _chatStorageKey = 'chat_screen_messages_v1';

  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  bool _sending = false;
  final _limiter = ChatUsageLimiter();

  final _routineRepo = RoutineRepository();
  _PendingRoutine? _pendingRoutine;
  bool _showGoToRoutines = false;

  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _restoreChat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  _ChatMessage _initialAssistantMessage() {
    return _ChatMessage(
      fromUser: false,
      text: 'Hola. Soy tu asistente (demo). Preguntame sobre ejercicios o zonas (rodilla, hombro...).',
    );
  }

  Future<void> _restoreChat() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatStorageKey);

    if (!mounted) return;

    if (raw == null || raw.trim().isEmpty) {
      setState(() {
        _messages
          ..clear()
          ..add(_initialAssistantMessage());
      });
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final restored = decoded
          .whereType<Map>()
          .map((e) => _ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .where((m) => m.text.trim().isNotEmpty)
          .toList();

      setState(() {
        _messages
          ..clear()
          ..addAll(restored.isEmpty ? [_initialAssistantMessage()] : restored);
      });
    } catch (_) {
      setState(() {
        _messages
          ..clear()
          ..add(_initialAssistantMessage());
      });
    }

    _rebuildPendingFromLatestSuggestion();
  }

  Future<void> _persistChat() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _messages
        .skip(_messages.length > 120 ? _messages.length - 120 : 0)
        .map((m) => m.toJson())
        .toList();
    await prefs.setString(_chatStorageKey, jsonEncode(payload));
  }

  Future<void> _resetChat() async {
    _pendingRoutine = null;
    _showGoToRoutines = false;
    setState(() {
      _messages
        ..clear()
        ..add(_initialAssistantMessage());
    });
    await _persistChat();
  }

  void _rebuildPendingFromLatestSuggestion() {
    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (!m.fromUser && m.zoneId != null) {
        _setPendingFromMessage(m);
        return;
      }
    }
  }

  void _setPendingFromMessage(_ChatMessage message) {
    if (message.zoneId == null) return;

    if (message.suggestedExerciseIds != null && message.suggestedExerciseIds!.isNotEmpty) {
      final selected = widget.data.exercises
          .where((e) => message.suggestedExerciseIds!.contains(e.id))
          .toList();
      if (selected.isNotEmpty) {
        _pendingRoutine = _PendingRoutine(
          nombre: message.suggestedRoutineName ?? 'Rutina guiada',
          descripcion: 'Generada desde el chat. Ajustable antes de guardar.',
          exerciseIds: selected.map((e) => e.id).toList(),
        );
        return;
      }
    }

    _buildPendingRoutineForZone(message.zoneId!);
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

  String? _extractZoneIdFromText(String text) {
    final lower = _normalize(text);
    for (final zone in widget.data.zones) {
      final zn = _normalize(zone.nombre);
      if (lower.contains(zn)) return zone.id;
    }
    return null;
  }

  List<String> _extractAllZoneIdsFromText(String text) {
    final lower = _normalize(text);
    final zones = <String>[];
    for (final zone in widget.data.zones) {
      final zn = _normalize(zone.nombre);
      if (lower.contains(zn) && !zones.contains(zone.id)) {
        zones.add(zone.id);
      }
    }
    return zones;
  }

  bool _looksLikeRoutineIntent(String text) {
    final lower = _normalize(text);
    return lower.contains('rutina') ||
        lower.contains('plan') ||
        lower.contains('sesion') ||
        lower.contains('ejercicios') ||
        lower.contains('recomienda');
  }

  String? _lastUserMessageText() {
    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.fromUser) return m.text;
    }
    return null;
  }

  String _buildPendingRoutineForZone(String zoneId, {String? customName}) {
    return _buildPendingRoutineForZones([zoneId], customName: customName);
  }

  String _buildPendingRoutineForZones(List<String> zoneIds, {String? customName}) {
    if (zoneIds.isEmpty) return 'No hay zonas especificadas.';

    // Collect exercises from all zones
    final allExercises = <Exercise>[];
    final zoneNames = <String>[];

    for (final zoneId in zoneIds) {
      final zone = widget.data.zones.firstWhere((z) => z.id == zoneId);
      zoneNames.add(zone.nombre);
      final exercises = widget.data.exercises.where((e) => e.zonaId == zoneId).toList();
      allExercises.addAll(exercises);
    }

    if (allExercises.isEmpty) {
      return 'No tengo ejercicios cargados para las zonas seleccionadas todavía.';
    }

    // Shuffle and pick (3-4 per zone, up to 10 total)
    allExercises.shuffle();
    final maxExercises = (zoneIds.length * 3).clamp(5, 10);
    final picked = allExercises.take(maxExercises).toList();
    final ids = picked.map((e) => e.id).toList();
    final list = picked.map((e) => '• ${e.nombre} (${e.series}x${e.repeticiones})').join('\n');

    final zoneName = zoneNames.length > 1 ? zoneNames.join(' + ') : zoneNames.first;
    final name = (customName == null || customName.trim().isEmpty)
        ? '$zoneName · rutina guiada'
        : customName.trim();

    _pendingRoutine = _PendingRoutine(
      nombre: name,
      descripcion: 'Generada desde el chat. Ajustable antes de guardar.',
      exerciseIds: ids,
    );
    _showGoToRoutines = false;

    return 'Rutina sugerida para $zoneName:\n$list';
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
    await _persistChat();

    String reply;
    String? recommendedZoneId;
    List<String>? suggestedExerciseIds;
    String? suggestedRoutineName;
    try {
      final result = await _respondAsync(text);
      reply = result['text'] as String;
      recommendedZoneId = result['zoneId'] as String?;
      suggestedExerciseIds = (result['suggestedExerciseIds'] as List?)?.map((e) => e.toString()).toList();
      suggestedRoutineName = result['suggestedRoutineName'] as String?;
    } catch (_) {
      reply = 'He tenido un problema procesando tu mensaje. Inténtalo de nuevo en unos segundos.';
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(
        fromUser: false,
        text: reply,
        zoneId: recommendedZoneId,
        suggestedExerciseIds: suggestedExerciseIds,
        suggestedRoutineName: suggestedRoutineName,
      ));
      _sending = false;
    });
    await _persistChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<Map<String, dynamic>> _respondAsync(String userText) async {
    final lower = _normalize(userText);

    if (lower == 'ayuda' || lower == 'help') {
      return {'text': 'Comandos útiles:\n'
          '• zonas\n'
          '• rutina hombro\n'
          '• guardar rutina\n'
          '• limpiar chat\n'
          '• cancelar rutina'};
    }

    if (lower == 'limpiar chat') {
      await _resetChat();
      return {'text': 'Listo, he limpiado la conversación.'};
    }

    if (lower == 'cancelar rutina') {
      _pendingRoutine = null;
      _showGoToRoutines = false;
      return {'text': 'Rutina pendiente cancelada.'};
    }

    // Prioridad: si parece intención de rutina y detectamos zona(s), generamos pendiente local.
    final allZoneIds = _extractAllZoneIdsFromText(userText);
    final zoneId = allZoneIds.isNotEmpty ? allZoneIds.first : null;
    final routineIntent =
        _looksLikeRoutineIntent(userText) ||
        lower.contains('dolor') ||
        lower.contains('molest') ||
        lower.contains('lesion') ||
        lower.contains('recuper');
    if (allZoneIds.isNotEmpty && routineIntent) {
      final text = _buildPendingRoutineForZones(allZoneIds);
      return {
        'text': text,
        'zoneId': allZoneIds.first,
        'suggestedExerciseIds': _pendingRoutine?.exerciseIds,
        'suggestedRoutineName': _pendingRoutine?.nombre,
      };
    }

    // Backward compatibility con comando explícito.
    if (lower.startsWith('rutina ') || lower.startsWith('crear rutina ') || lower.contains('hazme rutina')) {
      final text = _respondRoutineLocal(userText);
      final responseZoneId = _extractZoneIdFromText(text);
      return {
        'text': text,
        'zoneId': responseZoneId,
        'suggestedExerciseIds': _pendingRoutine?.exerciseIds,
        'suggestedRoutineName': _pendingRoutine?.nombre,
      };
    }

    // Save routine if the user confirms.
    if (lower == 'guardar rutina' || lower == 'guarda rutina') {
      if (_pendingRoutine == null) {
        final last = _lastUserMessageText();
        final zoneFromLast = last == null ? null : _extractZoneIdFromText(last);
        if (zoneFromLast != null) {
          _buildPendingRoutineForZone(zoneFromLast);
        }
      }
      return {'text': await _savePendingRoutine()};
    }

    if (AzureOpenAIConfig.isConfigured) {
      try {
        final uid = FirebaseBootstrap.isReady ? AuthService().currentUser()?.uid : null;
        final userKey = uid ?? 'guest';

        final ok = await _limiter.tryConsume(userKey: userKey);
        if (!ok) {
          return {'text': 'Has alcanzado el límite diario de consultas (10). Vuelve mañana.'};
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

        final azureReply = await AzureOpenAIService(data: widget.data).reply(
          userText: userText,
          history: history,
        );

        final responseZoneIds = _extractAllZoneIdsFromText(azureReply);
        final shouldBuildFromAzure = responseZoneIds.isNotEmpty &&
            (azureReply.toLowerCase().contains('rutina') ||
                azureReply.toLowerCase().contains('ejercicios') ||
                azureReply.toLowerCase().contains('suger'));

        if (shouldBuildFromAzure) {
          _buildPendingRoutineForZones(responseZoneIds);
        } else if (zoneId != null) {
          _buildPendingRoutineForZone(zoneId);
        }

        final responseZoneId = responseZoneIds.isNotEmpty
            ? responseZoneIds.first
            : zoneId;

        return {
          'text': azureReply,
          'zoneId': responseZoneId,
          'suggestedExerciseIds': responseZoneId == null ? null : _pendingRoutine?.exerciseIds,
          'suggestedRoutineName': responseZoneId == null ? null : _pendingRoutine?.nombre,
        };
      } catch (_) {
        final text = _respondDemo(userText);
        return {
          'text': text,
          'zoneId': zoneId,
          'suggestedExerciseIds': zoneId == null ? null : _pendingRoutine?.exerciseIds,
          'suggestedRoutineName': zoneId == null ? null : _pendingRoutine?.nombre,
        };
      }
    }

    final text = _respondDemo(userText);
    final responseZoneIds = _extractAllZoneIdsFromText(text);
    final shouldBuildFromDemo = responseZoneIds.isNotEmpty && text.toLowerCase().contains('rutina');
    if (shouldBuildFromDemo) {
      _buildPendingRoutineForZones(responseZoneIds);
    }
    return {
      'text': text,
      'zoneId': responseZoneIds.isNotEmpty ? responseZoneIds.first : zoneId,
      'suggestedExerciseIds': responseZoneIds.isNotEmpty ? _pendingRoutine?.exerciseIds : null,
      'suggestedRoutineName': responseZoneIds.isNotEmpty ? _pendingRoutine?.nombre : null,
    };
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

    final firebaseReady = FirebaseBootstrap.isReady;
    final uid = firebaseReady ? AuthService().currentUser()?.uid : null;
    if (firebaseReady && uid == null) {
      return 'Para guardar rutinas necesitas iniciar sesión.';
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
      return uid == null
          ? 'Listo. He guardado la rutina en “Mis rutinas” (modo local).'
          : 'Listo. He guardado la rutina en “Mis rutinas”.';
    } catch (e) {
      return 'No he podido guardarla: $e';
    }
  }

  Future<String> _editAndSavePendingRoutine() async {
    final pending = _pendingRoutine;
    if (pending == null) {
      return 'No tengo ninguna rutina pendiente para editar.';
    }

    final firebaseReady = FirebaseBootstrap.isReady;
    final uid = firebaseReady ? AuthService().currentUser()?.uid : null;
    if (firebaseReady && uid == null) {
      return 'Para guardar rutinas necesitas iniciar sesión.';
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
      return ''; // Silent cancel - don't show message
    }

    try {
      await _routineRepo.upsert(uid: uid, routine: edited);
      _pendingRoutine = null;
      _showGoToRoutines = true;
      return uid == null
          ? 'Perfecto. He guardado la rutina editada en “Mis rutinas” (modo local).'
          : 'Perfecto. He guardado la rutina editada en “Mis rutinas”.';
    } catch (e) {
      return 'No he podido guardarla: $e';
    }
  }

  Widget _buildRecommendationCard(BuildContext context, _ChatMessage message) {
    final zoneId = message.zoneId!;
    final zone = widget.data.zones.firstWhere((z) => z.id == zoneId);
    List<Exercise> picked;
    if (message.suggestedExerciseIds != null && message.suggestedExerciseIds!.isNotEmpty) {
      picked = widget.data.exercises.where((e) => message.suggestedExerciseIds!.contains(e.id)).toList();
    } else {
      final exercises = widget.data.exercises
          .where((e) => e.zonaId == zoneId)
          .toList()
        ..shuffle();
      picked = exercises.take(5).toList();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Rutina para ${zone.nombre}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...picked.map(
            (exercise) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${exercise.nombre} (${exercise.series}x${exercise.repeticiones})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _sending
                    ? null
                    : () {
                        _setPendingFromMessage(message);
                        _runPendingAction(_savePendingRoutine);
                      },
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Guardar rutina'),
              ),
              OutlinedButton.icon(
                onPressed: _sending
                    ? null
                    : () {
                        _setPendingFromMessage(message);
                        _runPendingAction(_editAndSavePendingRoutine);
                      },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMyRoutines() async {
    final firebaseReady = FirebaseBootstrap.isReady;
    final uid = firebaseReady ? AuthService().currentUser()?.uid : null;
    if (firebaseReady && uid == null) {
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

    // Only add message if it's not empty
    if (reply.isNotEmpty) {
      setState(() {
        _messages.add(_ChatMessage(fromUser: false, text: reply));
        _sending = false;
      });
      await _persistChat();
    } else {
      setState(() => _sending = false);
    }

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente (IA)'),
        actions: [
          IconButton(
            tooltip: 'Nuevo chat',
            onPressed: _sending
                ? null
                : () async {
                    final clear = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Nuevo chat'),
                        content: const Text('Se borrará la conversación actual. ¿Quieres continuar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Empezar nuevo'),
                          ),
                        ],
                      ),
                    );
                    if (clear == true) {
                      await _resetChat();
                    }
                  },
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.25),
              const Color(0xFFF4F8FF),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final align = m.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                  final color = m.fromUser
                      ? scheme.primaryContainer
                      : scheme.surface;

                  return Column(
                    crossAxisAlignment: align,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 520),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Text(m.text),
                      ),
                      if (!m.fromUser && m.zoneId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildRecommendationCard(context, m),
                        ),
                    ],
                  );
                },
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
                          hintText: 'Escribe tu pregunta...',
                          border: OutlineInputBorder(),
                        ),
                        enabled: !_sending,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _sending ? null : _send,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
