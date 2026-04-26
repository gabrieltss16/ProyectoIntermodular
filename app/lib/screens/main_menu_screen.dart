import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'routines_screen.dart';
import 'zones_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final CatalogData data;
  final bool isGuest;

  const MainMenuScreen({super.key, required this.data, required this.isGuest});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (accepted == true) {
      await _logout();
    }
  }

  Widget _loginRequiredPage() {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sesión no disponible. Vuelve a iniciar sesión.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = (!widget.isGuest && FirebaseBootstrap.isReady) ? AuthService().currentUser()?.uid : null;
    if (widget.isGuest) {
      return RoutinesScreen(data: widget.data, uid: uid, isGuest: true);
    }

    final pages = <Widget>[
      ChatScreen(data: widget.data),
      RoutinesScreen(data: widget.data, uid: uid),
      ZonesScreen(data: widget.data, uid: uid),
      if (uid != null)
        ProfileScreen(data: widget.data, uid: uid)
      else
        _loginRequiredPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) async {
          if (index == 4) {
            await _confirmLogout();
            return;
          }
          setState(() => _selectedIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'IA',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_agenda_outlined),
            selectedIcon: Icon(Icons.view_agenda),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_run_outlined),
            selectedIcon: Icon(Icons.directions_run),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout_outlined),
            selectedIcon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
      ),
    );
  }
}
