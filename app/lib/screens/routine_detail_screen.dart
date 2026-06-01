import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';

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
      assetKey(exercise.imagen!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }

  void _openExerciseDetails(BuildContext context, Exercise exercise) {
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
                    child: _exerciseThumb(context, exercise),
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
                    Chip(label: Text('${exercise.series} series')),
                    Chip(label: Text('${exercise.repeticiones} repeticiones')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercise.descripcion,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
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
    final byId = {for (final e in data.exercises) e.id: e};
    final exercises = routine.exerciseIds
        .map((id) => byId[id])
        .whereType<Exercise>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE RUTINA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.6),
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
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: scheme.primary,
                          child: Icon(Icons.task_alt, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.nombre,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.primary,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${exercises.length} ejercicio${exercises.length == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (routine.descripcion.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        routine.descripcion,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sourceLabel ?? (routine.creadaPorIA ? 'IA' : 'Manual'),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (exercises.isNotEmpty)
            Text(
              'Ejercicios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          const SizedBox(height: 12),
          ...exercises.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (idx * 50)),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                return Transform.translate(
                  offset: Offset(0, (1 - t) * 8),
                  child: Opacity(
                    opacity: t,
                    child: Card(
                      child: InkWell(
                        onTap: () => _openExerciseDetails(context, e),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                scheme.primaryContainer.withValues(alpha: 0.4),
                                scheme.primaryContainer.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: _exerciseThumb(context, e),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.nombre,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: scheme.secondary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${e.series}x${e.repeticiones}',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: scheme.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: scheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(
                child: Text(
                  'Esta rutina no tiene ejercicios (todavía).',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
