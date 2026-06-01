import 'package:fisioia/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'services/firebase_bootstrap.dart';

const _primaryBlue = Color(0xFF047CE3);
const _secondaryBlue = Color(0xFF5569A4);
const _deepBlue = Color(0xFF020F70);
const _backgroundBlue = Color(0xFFEDEEF4);
const _surfaceBlue = Color(0xFFFFFFFF);
const _softBlue = Color(0xFFDAE0EB);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.tryInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme() {
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

    return ThemeData(
      useMaterial3: true,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisioIA',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }
}


