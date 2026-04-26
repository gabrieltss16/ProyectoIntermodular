import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'routines_screen.dart';
import 'zones_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final CatalogData data;
  final bool isGuest;

  const MainMenuScreen({super.key, required this.data, required this.isGuest});

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _openChat(BuildContext context) async {
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El chat de IA requiere iniciar sesión. En modo invitado está desactivado.'),
        ),
      );
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso médico'),
        content: const Text(
          'El asistente de IA ofrece información orientativa y no sustituye el diagnóstico '
          'ni la opinión de un profesional sanitario. Si tienes dolor intenso o síntomas '
          'preocupantes, consulta a un especialista.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );

    if (accepted != true) return;
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = (!isGuest && FirebaseBootstrap.isReady) ? AuthService().currentUser()?.uid : null;
    final isAuthed = uid != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FisioIA'),
        actions: [
          if (!isGuest)
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZonesScreen(data: data, uid: uid),
                  ),
                );
              },
              child: const Text('Explorar ejercicios por zona'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _openChat(context),
              child: const Text('Asistente (IA)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isGuest
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('En modo invitado no puedes guardar rutinas. Inicia sesión para desbloquearlo.'),
                        ),
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoutinesScreen(
                            data: data,
                            uid: uid,
                          ),
                        ),
                      );
                    },
              child: const Text('Mis rutinas'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                final currentUid = uid;
                if (currentUid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inicia sesión para editar tu perfil.'),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      data: data,
                      uid: currentUid,
                    ),
                  ),
                );
              },
              child: const Text('Mi perfil'),
            ),
            const Spacer(),
            Text(
              isGuest
                  ? 'Modo invitado · sin guardar rutinas'
                  : (FirebaseBootstrap.isReady && isAuthed)
                      ? 'Sesión iniciada · rutinas en Firestore'
                      : 'Sesión iniciada · Firebase no listo',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
