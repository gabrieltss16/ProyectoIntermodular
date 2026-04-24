import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_bootstrap.dart';
import 'main_menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _enterMenu({required bool isGuest}) async {
    final data = await CatalogService().load();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainMenuScreen(
          data: data,
          isGuest: isGuest,
        ),
      ),
    );
  }

  Future<void> _showFirebaseNotReady() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Firebase no configurado'),
        content: Text(
          'Aún no está configurado Firebase en este proyecto.\n\n'
          'Puedes entrar en modo demo para probar la app, pero para cumplir RF01/RF06 '
          'necesitamos terminar la configuración (Firebase Auth + Firestore).',
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseBootstrap.tryInit();
      if (!FirebaseBootstrap.isReady) {
        await _showFirebaseNotReady();
        await _enterMenu(isGuest: false);
        return;
      }

      await AuthService().signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await _enterMenu(isGuest: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseBootstrap.tryInit();
      if (!FirebaseBootstrap.isReady) {
        await _showFirebaseNotReady();
        await _enterMenu(isGuest: false);
        return;
      }

      await AuthService().register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await _enterMenu(isGuest: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                FirebaseBootstrap.isReady
                    ? 'Inicia sesión con Firebase Authentication.'
                    : 'Si Firebase no está configurado todavía, podrás entrar en modo demo.\n'
                        'Objetivo 50%: completar Firebase Auth + Firestore.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Introduce un email.';
                  if (!v.contains('@')) return 'Email no válido.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Introduce una contraseña.';
                  if (v.length < 4) return 'Mínimo 4 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loading ? null : _register,
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
