import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/catalog_service.dart';

class RoutineDetailScreen extends StatelessWidget {
  final CatalogData data;
  final Routine routine;

  const RoutineDetailScreen({
    super.key,
    required this.data,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
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
          if (routine.descripcion.trim().isNotEmpty)
            Text(routine.descripcion, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(routine.creadaPorIA ? 'IA (demo)' : 'Manual')),
              Chip(label: Text('${exercises.length} ejercicios')),
            ],
          ),
          const SizedBox(height: 16),
          ...exercises.map(
            (e) => Card(
              child: ListTile(
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
