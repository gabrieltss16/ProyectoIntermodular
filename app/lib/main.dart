// Punto de entrada de la aplicación FisioIA.
// Aquí se arranca Flutter, se inicializa Firebase y se define el tema global.
import 'package:fisioia/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'services/firebase_bootstrap.dart';

// Paleta de colores definida como constantes globales del archivo.
// Se usan const para que el compilador las genere una sola vez (sin coste en runtime).
// Equivalente en Android: colors.xml o un objeto companion object con colores.
const _primaryBlue = Color(0xFF047CE3);    // Azul principal de la app
const _secondaryBlue = Color(0xFF5569A4);  // Azul secundario (texto de apoyo)
const _deepBlue = Color(0xFF020F70);       // Azul oscuro (títulos, nav bar)
const _backgroundBlue = Color(0xFFEDEEF4); // Fondo general de pantallas
const _surfaceBlue = Color(0xFFFFFFFF);    // Fondo de tarjetas (blanco)
const _softBlue = Color(0xFFDAE0EB);       // Contenedor suave (chips, bordes)

// main() es el punto de entrada de toda app Flutter (como 'fun main()' en Kotlin).
// Es async porque necesitamos esperar a que Firebase se inicialice antes de correr la UI.
Future<void> main() async {
  // OBLIGATORIO antes de cualquier await en main():
  // asegura que los bindings internos de Flutter estén listos
  // (equivale a setContentView antes de usar la UI en Android).
  WidgetsFlutterBinding.ensureInitialized();

  // Intenta inicializar Firebase. Si falla (no hay google-services.json),
  // la app sigue funcionando en modo demo gracias al patrón de FirebaseBootstrap.
  await FirebaseBootstrap.tryInit();

  // runApp inicia el motor de Flutter y muestra el widget raíz.
  // Desde aquí Flutter gestiona el ciclo de vida (equivale al Activity principal).
  runApp(const MyApp());
}

// MyApp es un StatelessWidget porque no tiene estado propio que cambie.
// En Android sería equivalente a la Application class: define el tema y la pantalla inicial.
// StatelessWidget = widget inmutable; StatefulWidget = widget con estado mutable.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Construye el tema global de Material Design 3.
  // ThemeData en Flutter = styles.xml + themes.xml en Android, pero más potente.
  ThemeData _buildTheme() {
    // ColorScheme.fromSeed genera automáticamente toda la paleta de colores
    // a partir de un color semilla, siguiendo las reglas de Material Design 3.
    final scheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: _primaryBlue,
      onPrimary: Colors.white,
      secondary: _secondaryBlue,
      onSecondary: Colors.white,
      tertiary: _deepBlue,
      onTertiary: Colors.white,
      surface: _surfaceBlue,
      onSurface: _deepBlue,
      primaryContainer: _softBlue,
      onPrimaryContainer: _deepBlue,
      secondaryContainer: _softBlue,
      onSecondaryContainer: _deepBlue,
      tertiaryContainer: _softBlue,
      onTertiaryContainer: _deepBlue,
      onSurfaceVariant: _secondaryBlue,
      surfaceContainerHighest: _softBlue,
      outlineVariant: const Color(0xFFB8C3D8),
      inverseSurface: _deepBlue,
      onInverseSurface: Colors.white,
      surfaceTint: _primaryBlue,
    );

    // ThemeData centraliza TODOS los estilos de la app en un solo lugar.
    // Cuando se accede desde cualquier widget con Theme.of(context).colorScheme,
    // se obtienen estos colores sin tener que pasarlos manualmente.
    return ThemeData(
      useMaterial3: true, // Activa Material Design 3 (componentes y tokens actuales)
      colorScheme: scheme.copyWith(
        primary: _primaryBlue,
        secondary: _secondaryBlue,
        tertiary: _deepBlue,
      ),
      scaffoldBackgroundColor: _backgroundBlue,
      iconTheme: const IconThemeData(size: 32),
      primaryIconTheme: const IconThemeData(size: 32),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: _deepBlue,
        displayColor: _deepBlue,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(size: 32, color: Colors.white),
        actionsIconTheme: const IconThemeData(size: 32, color: Colors.white),
        centerTitle: true,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(iconSize: 32),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _primaryBlue.withValues(alpha: 0.15),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(size: 32)),
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        height: 80,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
    );
  }

  // build() es el método que Flutter llama para "pintar" el widget.
  // Devuelve el árbol de widgets que representa la interfaz.
  // En Android equivale a onCreateView() o setContentView().
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisioIA',             // Nombre de la app (aparece en el task switcher)
      debugShowCheckedModeBanner: false, // Quita el banner rojo 'DEBUG' en producción
      theme: _buildTheme(),         // Aplica el tema global a toda la app
      home: const HomeScreen(),     // Pantalla inicial (equivale al LAUNCHER activity)
    );
  }
}


