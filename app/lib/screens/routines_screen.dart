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
  final VoidCallback? onGuestBack;

  const RoutinesScreen({
    super.key,
    required this.data,
    required this.uid,
    this.isGuest = false,
    this.onGuestBack,
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

  Widget _animatedIn({
    required int index,
    required Widget child,
  }) {
    final step = (index * 40).clamp(0, 240);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + step),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Transform.translate(
          offset: Offset(0, (1 - t) * 10),
          child: Opacity(opacity: t, child: child),
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(icon, size: 30, color: scheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetTab() {
    final zones = widget.data.zones;

    if (zones.isEmpty) {
      return _emptyState(
        icon: Icons.category_outlined,
        title: 'Sin zonas disponibles',
        subtitle: 'Aún no se han cargado zonas articulares en el catálogo.',
      );
    }

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
        ...zones.asMap().entries.map((entry) {
          final idx = entry.key;
          final zone = entry.value;
          final routine = _presetRoutineForZone(zone);
          String? firstExerciseName;
          for (final exercise in widget.data.exercises) {
            if (routine.exerciseIds.contains(exercise.id)) {
              firstExerciseName = exercise.nombre;
              break;
            }
          }

          return _animatedIn(
            index: idx,
            child: Padding(
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
          return _emptyState(
            icon: Icons.playlist_add_circle_outlined,
            title: 'Todavía no tienes rutinas',
            subtitle: 'Crea una rutina propia o guarda una desde el chat de IA.',
            actionLabel: 'Crear rutina',
            onAction: _createManual,
          );
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = routines[i];
              final scheme = Theme.of(context).colorScheme;
              
              return _animatedIn(
                index: i,
                child: GestureDetector(
                  onTap: () => _open(r),
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer.withValues(alpha: 0.5),
                            scheme.primaryContainer.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.nombre,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: scheme.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${r.exerciseIds.length} ejercicio${r.exerciseIds.length == 1 ? '' : 's'}',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: scheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Duplicar'),
                                      onTap: () => _duplicate(r),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Eliminar'),
                                      onTap: () => _delete(r),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
        leading: widget.isGuest
            ? IconButton(
                tooltip: 'Volver',
                onPressed: widget.onGuestBack,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: const Text('RUTINAS'),
        bottom: showUserTab
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Mis rutinas'),
                  Tab(text: 'Predeterminadas'),
                ],
              )
            : null,
      ),
      body: showUserTab
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildUserTab(),
                _buildPresetTab(),
              ],
            )
          : _buildPresetTab(),
      floatingActionButton: showUserTab && _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createManual,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
