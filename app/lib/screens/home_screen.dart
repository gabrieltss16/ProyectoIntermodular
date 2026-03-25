import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import 'zones_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FisioIA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () async {
                final data = await CatalogService().load();
                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ZonesScreen(data: data)),
                );
              },
              child: const Text('Entrar como invitado'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Iniciar sesión'),
                    content: Text('Próximamente: Firebase Auth'),
                  ),
                );
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}