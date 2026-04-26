import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/email_validator.dart';
import '../services/firebase_bootstrap.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _showFirebaseNotReady() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Firebase no configurado'),
        content: Text(
          'Aún no está configurado Firebase en este proyecto.\n\n'
          'Para registrarte necesitamos terminar la configuración (Firebase Auth + Firestore).',
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_confirmPasswordCtrl.text != _passwordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseBootstrap.tryInit();
      if (!FirebaseBootstrap.isReady) {
        await _showFirebaseNotReady();
        return;
      }

      await AuthService().register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await AuthService().sendEmailVerification();
      await AuthService().signOut();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Verifica tu correo'),
          content: Text(
            'Te hemos enviado un correo de verificación. Confirma tu email y después inicia sesión.',
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.45),
              const Color(0xFFF4F8FF),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FirebaseBootstrap.isReady
                        ? 'Guarda rutinas, usa IA personalizada y sincroniza tu progreso.'
                        : 'Para registrarte necesitamos terminar la configuración de Firebase.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'tu@email.com',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: AppEmailValidator.validate,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Introduce una contraseña.';
                              if (v.length < 6) return 'Mínimo 6 caracteres.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Repetir contraseña',
                              prefixIcon: Icon(Icons.verified_user_outlined),
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Repite la contraseña.';
                              if (v != _passwordCtrl.text) return 'No coincide con la contraseña.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Crear cuenta'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
