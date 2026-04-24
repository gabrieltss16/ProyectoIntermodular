import 'package:flutter/material.dart';

import '../models/user_profile.dart';
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
  String? _zonaPrincipalId;

  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<UserProfile> _load() async {
    final profile = await _repo.getByUid(uid: widget.uid);

    if (!_loaded) {
      _nombreCtrl.text = profile.nombre ?? '';
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
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado.')),
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
    final zones = widget.data.zones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Guardar',
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
          ),
        ],
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _edadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Zona articular principal',
                    border: OutlineInputBorder(),
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
