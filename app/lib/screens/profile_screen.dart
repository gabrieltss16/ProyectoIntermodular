import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/catalog_service.dart';
import '../services/user_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  final CatalogData data;
  final String uid;

  const ProfileScreen({
    super.key,
    required this.data,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = UserProfileRepository();

  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _objetivosCtrl = TextEditingController();
  String? _zonaPrincipalId;
  String? _nivelExperienciaValue = 'principiante';

  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _objetivosCtrl.dispose();
    super.dispose();
  }

  Future<UserProfile> _load() async {
    final profile = await _repo.getByUid(uid: widget.uid);

    if (!_loaded) {
      _nombreCtrl.text = profile.nombre ?? '';
      _nivelExperienciaValue = profile.nivelExperiencia ?? 'principiante';
      _objetivosCtrl.text = profile.objetivos ?? '';
      _edadCtrl.text = profile.edad?.toString() ?? '';
      _zonaPrincipalId = profile.zonaPrincipalId;
      _loaded = true;
    }

    return profile;
  }

  Future<void> _save() async {
    final nombre = _nombreCtrl.text.trim();
    final edadTxt = _edadCtrl.text.trim();
    final edad = edadTxt.isEmpty ? null : int.tryParse(edadTxt);
    final objetivos = _objetivosCtrl.text.trim();

    if (edadTxt.isNotEmpty && edad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edad inválida (usa números).')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _repo.upsert(
        uid: widget.uid,
        profile: UserProfile(
          nombre: nombre.isEmpty ? null : nombre,
          edad: edad,
          zonaPrincipalId: _zonaPrincipalId,
          nivelExperiencia: _nivelExperienciaValue,
          objetivos: objetivos.isEmpty ? null : objetivos,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final zones = widget.data.zones;
    final email = AuthService().currentUser()?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MI PERFIL'),
      ),
      body: FutureBuilder<UserProfile>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No se pudo cargar el perfil: ${snap.error}'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer.withValues(alpha: 0.6),
                          scheme.primaryContainer.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: scheme.primary,
                            child: Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información personal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                if (email != null) ...[  
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  'Personaliza tu perfil para mejores recomendaciones.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _nombreCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _edadCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Edad',
                            prefixIcon: const Icon(Icons.cake_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Nivel de experiencia',
                            prefixIcon: const Icon(Icons.trending_up_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _nivelExperienciaValue,
                              isExpanded: true,
                              hint: const Text('Selecciona tu nivel'),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'principiante',
                                  child: const Text('Principiante'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'intermedio',
                                  child: const Text('Intermedio'),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'avanzado',
                                  child: const Text('Avanzado'),
                                ),
                              ],
                              onChanged: (v) => setState(() => _nivelExperienciaValue = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Zona articular principal',
                            prefixIcon: const Icon(Icons.health_and_safety_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _zonaPrincipalId,
                              isExpanded: true,
                              hint: const Text('Selecciona una zona'),
                              items: zones
                                  .map(
                                    (z) => DropdownMenuItem<String>(
                                      value: z.id,
                                      child: Text(z.nombre),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _zonaPrincipalId = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _objetivosCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Objetivos personales',
                            hintText: 'Ej: Recuperarme de una lesión, mejorar flexibilidad...',
                            prefixIcon: const Icon(Icons.flag_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Guardar cambios'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
