import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/catalog_service.dart';

class RoutineEditorScreen extends StatefulWidget {
  final CatalogData data;
  final Routine? initial;
  final bool creadaPorIA;

  const RoutineEditorScreen({
    super.key,
    required this.data,
    required this.initial,
    required this.creadaPorIA,
  });

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _zoneFilterId;
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameCtrl.text = initial?.nombre ?? '';
    _descCtrl.text = initial?.descripcion ?? '';
    _selectedIds = [...(initial?.exerciseIds ?? const <String>[])];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _toggle(String exerciseId) {
    setState(() {
      if (_selectedIds.contains(exerciseId)) {
        _selectedIds.remove(exerciseId);
      } else {
        _selectedIds.add(exerciseId);
      }
    });
  }

  void _moveUp(String exerciseId) {
    final idx = _selectedIds.indexOf(exerciseId);
    if (idx <= 0) return;
    setState(() {
      final tmp = _selectedIds[idx - 1];
      _selectedIds[idx - 1] = _selectedIds[idx];
      _selectedIds[idx] = tmp;
    });
  }

  void _moveDown(String exerciseId) {
    final idx = _selectedIds.indexOf(exerciseId);
    if (idx < 0 || idx >= _selectedIds.length - 1) return;
    setState(() {
      final tmp = _selectedIds[idx + 1];
      _selectedIds[idx + 1] = _selectedIds[idx];
      _selectedIds[idx] = tmp;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos 1 ejercicio.')),
      );
      return;
    }

    final routine = widget.initial == null
        ? Routine.create(
            nombre: _nameCtrl.text.trim(),
            descripcion: _descCtrl.text.trim(),
            creadaPorIA: widget.creadaPorIA,
            exerciseIds: _selectedIds,
          )
        : widget.initial!.copyWith(
            nombre: _nameCtrl.text.trim(),
            descripcion: _descCtrl.text.trim(),
            exerciseIds: _selectedIds,
          );

    Navigator.pop(context, routine);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.data.exercises
        .where((e) => _zoneFilterId == null || e.zonaId == _zoneFilterId)
        .toList();

    final byId = {for (final e in widget.data.exercises) e.id: e};
    final selected = _selectedIds.map((id) => byId[id]).whereType<Exercise>().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'NUEVA RUTINA' : 'EDITAR RUTINA'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Introduce un nombre.';
                if (v.trim().length < 3) return 'Mínimo 3 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Filtrar por zona (opcional)'),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _zoneFilterId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                    ...widget.data.zones.map(
                      (z) => DropdownMenuItem<String?>(
                        value: z.id,
                        child: Text(z.nombre),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _zoneFilterId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Ejercicios', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...exercises.map(
              (e) => CheckboxListTile(
                value: _selectedIds.contains(e.id),
                title: Text(e.nombre),
                subtitle: Text('${e.series} series · ${e.repeticiones} reps'),
                onChanged: (_) => _toggle(e.id),
              ),
            ),
            const SizedBox(height: 16),
            Text('Orden', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (selected.isEmpty)
              const Text('Selecciona ejercicios para definir el orden.')
            else
              ...selected.map(
                (e) => Card(
                  child: ListTile(
                    title: Text(e.nombre),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Subir',
                          onPressed: () => _moveUp(e.id),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: 'Bajar',
                          onPressed: () => _moveDown(e.id),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
