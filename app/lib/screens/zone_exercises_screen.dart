import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';
import '../models/routine.dart';
import '../services/catalog_service.dart';
import '../services/routine_repository.dart';
import 'routine_editor_screen.dart';

class ZoneExercisesScreen extends StatelessWidget {
  final CatalogData data;
  final String zoneId;
  final String zoneName;
  final String? uid;

  const ZoneExercisesScreen({
    super.key,
    required this.data,
    required this.zoneId,
    required this.zoneName,
    required this.uid,
  });

  Widget _animatedIn({required int index, required Widget child}) {
    final step = (index * 35).clamp(0, 220);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + step),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: Opacity(opacity: t, child: child),
        );
      },
    );
  }

  Future<void> _createRoutineFromExercise(BuildContext context, dynamic exercise) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar rutinas.')),
      );
      return;
    }

    final seedRoutine = Routine.create(
      nombre: 'Rutina de ${exercise.nombre}',
      descripcion: 'Creada desde el catálogo de ejercicios.',
      creadaPorIA: false,
      exerciseIds: [exercise.id],
    );

    final routine = await Navigator.push<Routine?>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          data: data,
          initial: seedRoutine,
          creadaPorIA: false,
        ),
      ),
    );

    if (routine == null) return;

    await RoutineRepository().upsert(uid: uid, routine: routine);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rutina guardada en Mis rutinas.')),
    );
  }

  void _openExerciseDetails(BuildContext context, dynamic exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: exercise.imagen == null
                        ? Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.fitness_center, size: 56),
                            ),
                          )
                        : Image.asset(
                          assetKey(exercise.imagen!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.fitness_center, size: 56),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.nombre,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(zoneName)),
                    Chip(label: Text('${exercise.series} series')),
                    Chip(label: Text('${exercise.repeticiones} repeticiones')),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.descripcion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createRoutineFromExercise(context, exercise);
                    },
                    child: const Text('Crear rutina con este ejercicio'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final exercises = data.exercises.where((e) => e.zonaId == zoneId).toList();

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('EJERCICIOS · ${zoneName.toUpperCase()}')),
        body: Center(
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
                      child: Icon(Icons.fitness_center, color: scheme.primary, size: 30),
                    ),
                    const SizedBox(height: 12),
                    const Text('No hay ejercicios cargados para esta zona todavía.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('EJERCICIOS · ${zoneName.toUpperCase()}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.fitness_center, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ejercicios disponibles: ${exercises.length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            return _animatedIn(
              index: idx,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(e.nombre),
                    subtitle: Text('${e.series} series · ${e.repeticiones} reps'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openExerciseDetails(context, e),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}