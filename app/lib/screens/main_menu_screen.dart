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
  late final PageController _pageController;

  Widget _navIcon({
    required int index,
    required IconData inactive,
    required IconData active,
  }) {
    final selected = _selectedIndex == index;
    return AnimatedScale(
      scale: selected ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Icon(selected ? active : inactive),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      return Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (!mounted) return;
            setState(() => _selectedIndex = index);
          },
          children: [
            ZonesScreen(data: widget.data, uid: null),
            RoutinesScreen(
              data: widget.data,
              uid: null,
              isGuest: true,
              onGuestBack: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
            _loginRequiredPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              _confirmLogout();
              return;
            }
            if (_selectedIndex == index) return;
            setState(() => _selectedIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            );
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: _navIcon(index: 0, inactive: Icons.directions_run_outlined, active: Icons.directions_run),
              selectedIcon: _navIcon(index: 0, inactive: Icons.directions_run_outlined, active: Icons.directions_run),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: _navIcon(index: 1, inactive: Icons.view_agenda_outlined, active: Icons.view_agenda),
              selectedIcon: _navIcon(index: 1, inactive: Icons.view_agenda_outlined, active: Icons.view_agenda),
              label: 'Rutinas',
            ),
            NavigationDestination(
              icon: _navIcon(index: 2, inactive: Icons.logout_outlined, active: Icons.logout),
              selectedIcon: _navIcon(index: 2, inactive: Icons.logout_outlined, active: Icons.logout),
              label: 'Salir',
            ),
          ],
        ),
      );
    }

    final pages = <Widget>[
      ZonesScreen(data: widget.data, uid: uid),
      RoutinesScreen(data: widget.data, uid: uid),
      ChatScreen(data: widget.data),
      if (uid != null)
        ProfileScreen(data: widget.data, uid: uid)
      else
        _loginRequiredPage(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (!mounted) return;
          setState(() => _selectedIndex = index);
        },
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) async {
          if (index == 4) {
            await _confirmLogout();
            return;
          }
          if (_selectedIndex == index) return;
          setState(() => _selectedIndex = index);
          await _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          );
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: _navIcon(index: 0, inactive: Icons.directions_run_outlined, active: Icons.directions_run),
            selectedIcon: _navIcon(index: 0, inactive: Icons.directions_run_outlined, active: Icons.directions_run),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: _navIcon(index: 1, inactive: Icons.view_agenda_outlined, active: Icons.view_agenda),
            selectedIcon: _navIcon(index: 1, inactive: Icons.view_agenda_outlined, active: Icons.view_agenda),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: _navIcon(index: 2, inactive: Icons.smart_toy_outlined, active: Icons.smart_toy),
            selectedIcon: _navIcon(index: 2, inactive: Icons.smart_toy_outlined, active: Icons.smart_toy),
            label: 'IA',
          ),
          NavigationDestination(
            icon: _navIcon(index: 3, inactive: Icons.person_outline, active: Icons.person),
            selectedIcon: _navIcon(index: 3, inactive: Icons.person_outline, active: Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: _navIcon(index: 4, inactive: Icons.logout_outlined, active: Icons.logout),
            selectedIcon: _navIcon(index: 4, inactive: Icons.logout_outlined, active: Icons.logout),
            label: 'Salir',
          ),
        ],
      ),
    );
  }
}
