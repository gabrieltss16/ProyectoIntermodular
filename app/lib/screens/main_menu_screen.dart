import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';

import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'routines_screen.dart';
import 'zones_screen.dart';

// MainMenuScreen es la pantalla principal de navegación.
// Implementa un patrón NavigationBar + PageView:
//   - NavigationBar (bottom nav) muestra los íconos y etiquetas
//   - PageView contiene todas las pantallas hijas preconstruidas
//   - Al cambiar de pestaña, se anima a la página correspondiente
// En Android sería equivalente a MainActivity con un BottomNavigationView + ViewPager2.
class MainMenuScreen extends StatefulWidget {
  final CatalogData data;   // Catálogo de ejercicios y zonas (cargado una sola vez)
  final bool isGuest;       // true = modo invitado (sin rutinas de nube ni perfil)

  const MainMenuScreen({super.key, required this.data, required this.isGuest});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0; // Índice de la pestaña activa (empieza en 0 = Explorar)
  late final PageController _pageController; // Controla la animación entre páginas

  // Crea el icono de la barra de navegación con animación de escala al seleccionarlo.
  Widget _navAssetIcon({required int index, required String assetPath}) {
    final selected = _selectedIndex == index;
    return AnimatedScale(
      scale: selected ? 1.08 : 1.0, // Escala ligera al estar activo
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Image.asset(
        assetKey(assetPath),
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
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
        actionsAlignment: MainAxisAlignment.center,
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
              icon: _navAssetIcon(index: 0, assetPath: 'images/iconos/diana.png'),
              selectedIcon: _navAssetIcon(index: 0, assetPath: 'images/iconos/diana.png'),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: _navAssetIcon(index: 1, assetPath: 'images/iconos/libroEjercicios.png'),
              selectedIcon: _navAssetIcon(index: 1, assetPath: 'images/iconos/libroEjercicios.png'),
              label: 'Rutinas',
            ),
            NavigationDestination(
              icon: _navAssetIcon(index: 2, assetPath: 'images/iconos/salida.png'),
              selectedIcon: _navAssetIcon(index: 2, assetPath: 'images/iconos/salida.png'),
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
            icon: _navAssetIcon(index: 0, assetPath: 'images/iconos/diana.png'),
            selectedIcon: _navAssetIcon(index: 0, assetPath: 'images/iconos/diana.png'),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: _navAssetIcon(index: 1, assetPath: 'images/iconos/libroEjercicios.png'),
            selectedIcon: _navAssetIcon(index: 1, assetPath: 'images/iconos/libroEjercicios.png'),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: _navAssetIcon(index: 2, assetPath: 'images/iconos/chat.png'),
            selectedIcon: _navAssetIcon(index: 2, assetPath: 'images/iconos/chat.png'),
            label: 'IA',
          ),
          NavigationDestination(
            icon: _navAssetIcon(index: 3, assetPath: 'images/iconos/persona2.png'),
            selectedIcon: _navAssetIcon(index: 3, assetPath: 'images/iconos/persona2.png'),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: _navAssetIcon(index: 4, assetPath: 'images/iconos/salida.png'),
            selectedIcon: _navAssetIcon(index: 4, assetPath: 'images/iconos/salida.png'),
            label: 'Salir',
          ),
        ],
      ),
    );
  }
}
