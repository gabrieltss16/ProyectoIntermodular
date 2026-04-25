import 'package:flutter/material.dart';
import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'main_menu_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Firebase se inicializa en main.dart antes de mostrar HomeScreen
    // Si aún no está listo, simplemente no redirigimos
    if (!FirebaseBootstrap.isReady) {
      return;
    }

    final user = AuthService().currentUser();
    if (user != null) {
      // Usuario ya loggeado, ir a MainMenuScreen
      final data = await CatalogService().load();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainMenuScreen(data: data, isGuest: false),
        ),
        (route) => false,
      );
    }
  }

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
                  MaterialPageRoute(
                    builder: (_) => MainMenuScreen(
                      data: data,
                      isGuest: true,
                    ),
                  ),
                );
              },
              child: const Text('Entrar como invitado'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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