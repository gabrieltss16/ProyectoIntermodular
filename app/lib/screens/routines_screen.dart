import 'dart:math';

import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../services/catalog_service.dart';
import '../services/routine_repository.dart';
import 'routine_detail_screen.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends StatefulWidget {
  final CatalogData data;
  final String? uid;

  const RoutinesScreen({super.key, required this.data, required this.uid});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final _repo = RoutineRepository();
  late Future<List<Routine>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.list(uid: widget.uid);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.list(uid: widget.uid);
    });
  }

  Future<void> _createManual() async {
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

  Future<void> _createIA() async {
    final zone = await showDialog<_ZonePick?>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Generar rutina por IA (demo)'),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Para el 50%: se genera una rutina automática sin backend.',
              ),
            ),
            const SizedBox(height: 8),
            ...widget.data.zones.map(
              (z) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, _ZonePick(z.id, z.nombre)),
                child: Text(z.nombre),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (zone == null) return;

    final candidates = widget.data.exercises.where((e) => e.zonaId == zone.id).toList();
    if (candidates.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ejercicios en esa zona.')),
      );
      return;
    }

    candidates.shuffle(Random());
    final chosen = candidates.take(min(6, candidates.length)).map((e) => e.id).toList();

    final routine = Routine.create(
      nombre: 'Rutina ${zone.name}',
      descripcion: 'Generada automáticamente (demo).',
      creadaPorIA: true,
      exerciseIds: chosen,
    );

    await _repo.upsert(uid: widget.uid, routine: routine);
    await _reload();

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(data: widget.data, routine: routine),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis rutinas'),
        actions: [
          IconButton(
            tooltip: 'Generar por IA (demo)',
            onPressed: _createIA,
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: FutureBuilder<List<Routine>>(
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
                child: Text('Aún no tienes rutinas. Crea una con el botón +.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              itemCount: routines.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = routines[i];
                final subtitle = r.creadaPorIA ? 'Generada por IA (demo)' : 'Manual';
                return ListTile(
                  title: Text(r.nombre),
                  subtitle: Text('$subtitle · ${r.exerciseIds.length} ejercicios'),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(r),
                  ),
                  onTap: () => _open(r),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createManual,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ZonePick {
  final String id;
  final String name;

  _ZonePick(this.id, this.name);
}
