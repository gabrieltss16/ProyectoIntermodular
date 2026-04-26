import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/catalog_service.dart';

class RoutineDetailScreen extends StatelessWidget {
  final CatalogData data;
  final Routine routine;
  final String? sourceLabel;

  const RoutineDetailScreen({
    super.key,
    required this.data,
    required this.routine,
    this.sourceLabel,
  });

  Widget _exerciseThumb(BuildContext context, Exercise exercise) {
    Widget fallback() {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.fitness_center),
      );
    }

    if (exercise.imagen == null || exercise.imagen!.trim().isEmpty) {
      return fallback();
    }

    return Image.asset(
      exercise.imagen!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final byId = {for (final e in data.exercises) e.id: e};
    final exercises = routine.exerciseIds
        .map((id) => byId[id])
        .whereType<Exercise>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(routine.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.task_alt, color: scheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          routine.nombre,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (routine.descripcion.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      routine.descripcion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          sourceLabel ?? (routine.creadaPorIA ? 'IA (demo)' : 'Manual'),
                        ),
                      ),
                      Chip(label: Text('${exercises.length} ejercicios')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...exercises.map(
            (e) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: _exerciseThumb(context, e),
                  ),
                ),
                title: Text(e.nombre),
                subtitle: Text('${e.series} series · ${e.repeticiones} reps\n${e.descripcion}'),
                isThreeLine: true,
              ),
            ),
          ),
          if (exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('Esta rutina no tiene ejercicios (todavía).'),
            ),
        ],
      ),
    );
  }
}
