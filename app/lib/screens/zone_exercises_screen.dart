import 'package:flutter/material.dart';
import '../services/catalog_service.dart';

class ZoneExercisesScreen extends StatelessWidget {
  final CatalogData data;
  final String zoneId;
  final String zoneName;

  const ZoneExercisesScreen({
    super.key,
    required this.data,
    required this.zoneId,
    required this.zoneName,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = data.exercises.where((e) => e.zonaId == zoneId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(zoneName)),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, i) {
          final e = exercises[i];
          return ListTile(
            title: Text(e.nombre),
            subtitle: Text('${e.series} series · ${e.repeticiones} reps'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(e.nombre),
                  content: Text(e.descripcion),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}