import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import 'zone_exercises_screen.dart';

class ZonesScreen extends StatelessWidget {
  final CatalogData data;
  final String? uid;

  const ZonesScreen({super.key, required this.data, required this.uid});

  Widget _animatedIn({required int index, required Widget child}) {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final zones = data.zones;

    if (zones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zonas articulares')),
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
                      child: Icon(Icons.category_outlined, size: 30, color: scheme.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text('No hay zonas cargadas todavía.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Zonas articulares')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecciona una zona para ver ejercicios detallados y crear rutinas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...zones.asMap().entries.map((entry) {
            final idx = entry.key;
            final z = entry.value;
            return _animatedIn(
              index: idx,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Text(z.nombre.isNotEmpty ? z.nombre[0].toUpperCase() : '?'),
                    ),
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