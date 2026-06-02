import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';

import '../services/auth_service.dart';
import '../services/catalog_service.dart';
import '../services/firebase_bootstrap.dart';
import 'login_screen.dart';
import 'main_menu_screen.dart';

// HomeScreen es la pantalla de bienvenida (la primera que ve el usuario).
// Es StatefulWidget porque necesita comprobar sesión activa en initState()
// y potencialmente navegar a MainMenuScreen si ya hay sesión.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Comprueba si ya hay sesión activa al abrir la app.
    // Si la hay, salta directamente al menú principal sin mostrar esta pantalla.
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (!FirebaseBootstrap.isReady) {
      return; // Sin Firebase no hay sesión que comprobar
    }

    final user = AuthService().currentUser();
    if (user == null) return; // No hay sesión: queda en HomeScreen

    // Hay sesión activa: carga el catálogo y navega al menú.
    final data = await CatalogService().load();
    if (!mounted) return; // Protección: widget puede haberse desmontado

    // pushAndRemoveUntil navega a MainMenuScreen y elimina HomeScreen de la pila.
    // Así el botón "atrás" del dispositivo no vuelve a HomeScreen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainMenuScreen(data: data, isGuest: false),
      ),
      (route) => false, // Elimina TODAS las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.55),
              const Color(0xFFF4F8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        assetKey('images/logo/logoapp.jpg'),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'FisioIA',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu rutina de recuperación,\nen una sola app',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Explora ejercicios por zona, guarda tus rutinas y usa el asistente IA para recomendaciones personalizadas.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
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
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Entrar como invitado'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
