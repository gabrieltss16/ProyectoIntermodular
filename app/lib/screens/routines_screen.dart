import 'dart:math';

import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../models/zone.dart';
import '../services/catalog_service.dart';
import '../services/routine_repository.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends StatefulWidget {
  final CatalogData data;
  final String? uid;
  final bool isGuest;

  const RoutinesScreen({
    super.key,
    required this.data,
    required this.uid,
    this.isGuest = false,
  });

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> with TickerProviderStateMixin {
  final _repo = RoutineRepository();
  late Future<List<Routine>> _future;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _future = _repo.list(uid: widget.uid);
    _tabController = TabController(length: widget.isGuest ? 1 : 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.list(uid: widget.uid);
    });
  }

  List<String> _pickExercisesForZone(String zoneId) {
    final candidates = widget.data.exercises.where((e) => e.zonaId == zoneId).toList();
    if (candidates.isEmpty) return <String>[];

    candidates.sort((a, b) => a.nombre.compareTo(b.nombre));
    final count = min(candidates.length, 5);
    return candidates.take(count).map((e) => e.id).toList();
  }

  Routine _presetRoutineForZone(Zone zone) {
    final exerciseIds = _pickExercisesForZone(zone.id);
    return Routine.create(
      nombre: 'Rutina predeterminada · ${zone.nombre}',
      descripcion: 'Rutina base de la app para trabajar ${zone.nombre.toLowerCase()}.',
      creadaPorIA: false,
      exerciseIds: exerciseIds,
    );
  }

  Future<void> _openPreset(Zone zone) async {
    final routine = _presetRoutineForZone(zone);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(
          data: widget.data,
          routine: routine,
          sourceLabel: 'Predeterminada',
        ),
      ),
    );
  }

  Future<void> _createManual() async {
    if (widget.isGuest) return;

    final routine = await Navigator.push<Routine?>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          data: widget.data,
          initial: null,
          creadaPorIA: false,
        ),
      ),
    );

    if (routine == null) return;
    await _repo.upsert(uid: widget.uid, routine: routine);
    await _reload();
  }

  Future<void> _open(Routine routine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(data: widget.data, routine: routine),
      ),
    );
  }

  Future<void> _delete(Routine routine) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Eliminar "${routine.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (ok != true) return;
    await _repo.deleteById(uid: widget.uid, id: routine.id);
    await _reload();
  }

  Future<void> _duplicate(Routine routine) async {
    final duplicated = Routine.create(
      nombre: '${routine.nombre} (copia)',
      descripcion: routine.descripcion,
      creadaPorIA: routine.creadaPorIA,
      exerciseIds: routine.exerciseIds,
    );

    await _repo.upsert(uid: widget.uid, routine: duplicated);
    await _reload();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rutina duplicada.')),
    );
  }

  Widget _buildPresetTab() {
    final zones = widget.data.zones;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutinas predeterminadas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isGuest
                      ? 'Solo puedes ver esta sección en modo invitado.'
                      : 'Rutinas base por zona para empezar rápido. Puedes abrir cada una y ver sus ejercicios.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...zones.map((zone) {
          final routine = _presetRoutineForZone(zone);
          String? firstExerciseName;
          for (final exercise in widget.data.exercises) {
            if (routine.exerciseIds.contains(exercise.id)) {
              firstExerciseName = exercise.nombre;
              break;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                title: Text(zone.nombre),
                subtitle: Text(
                  routine.exerciseIds.isEmpty
                      ? 'Sin ejercicios disponibles todavía.'
                      : '${routine.exerciseIds.length} ejercicios base · ${firstExerciseName ?? 'Rutina base'}',
                ),
                leading: CircleAvatar(
                  child: Text(
                    zone.nombre.isNotEmpty ? zone.nombre[0].toUpperCase() : '?',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openPreset(zone),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUserTab() {
    return FutureBuilder<List<Routine>>(
      future: _future,
      builder: (context, snap) {
        final routines = snap.data;
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        if (routines == null || routines.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Aún no tienes rutinas. Pulsa + para crear una.'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = routines[i];
              final subtitle = r.creadaPorIA ? 'Creada desde IA' : 'Manual';
              return Card(
                child: ListTile(
                  title: Text(r.nombre),
                  subtitle: Text('$subtitle · ${r.exerciseIds.length} ejercicios'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Duplicar',
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _duplicate(r),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(r),
                      ),
                    ],
                  ),
                  onTap: () => _open(r),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final showUserTab = !widget.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas'),
        bottom: showUserTab
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Predeterminadas'),
                  Tab(text: 'Mis rutinas'),
                ],
              )
            : null,
      ),
      body: showUserTab
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildPresetTab(),
                _buildUserTab(),
              ],
            )
          : _buildPresetTab(),
      floatingActionButton: showUserTab && _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _createManual,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
