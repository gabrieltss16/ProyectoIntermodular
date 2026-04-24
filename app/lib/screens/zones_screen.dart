import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import 'zone_exercises_screen.dart';

class ZonesScreen extends StatelessWidget {
  final CatalogData data;
  final String? uid;

  const ZonesScreen({super.key, required this.data, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zonas articulares')),
      body: ListView.builder(
        itemCount: data.zones.length,
        itemBuilder: (context, index) {
          final z = data.zones[index];
          return ListTile(
            title: Text(z.nombre),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ZoneExercisesScreen(
                    data: data,
                    zoneId: z.id,
                    zoneName: z.nombre,
                    uid: uid,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}