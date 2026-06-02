import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

// RoutineStorage implementa la persistencia LOCAL de rutinas usando SharedPreferences.
// SharedPreferences = clave-valor en disco (equivale a SharedPreferences en Android/Kotlin).
// Se usa cuando no hay sesión activa o Firebase no está disponible.
class RoutineStorage {
  // Clave bajo la que se guarda el JSON de todas las rutinas del dispositivo.
  // El sufijo '_v1' permite migrar el formato en el futuro sin perder datos.
  static const _key = 'routines_v1';

  // Lee las rutinas del almacenamiento local.
  // jsonDecode convierte el String guardado en un objeto Dart (List o Map).
  Future<List<Routine>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return <Routine>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Routine>[];  // Protección ante datos corruptos

    final routines = decoded
        .whereType<Map>()           // Filtra entradas que no sean Map (datos corruptos)
        .map((m) => m.cast<String, dynamic>())
        .map(Routine.fromJson)
        .toList();

    // Ordenamos aquí porque SharedPreferences no soporta orderBy como Firestore.
    routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return routines;
  }

  // Guarda o actualiza una rutina en la lista local.
  // Si ya existe (mismo id), la reemplaza; si no, la añade al final.
  Future<void> upsert(Routine routine) async {
    final routines = await list();
    final idx = routines.indexWhere((r) => r.id == routine.id);
    if (idx >= 0) {
      routines[idx] = routine; // Actualiza
    } else {
      routines.add(routine);   // Inserta
    }

    // Serializa toda la lista a JSON y la guarda como String.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(routines.map((r) => r.toJson()).toList()));
  }

  // Elimina la rutina con el ID dado reescribiendo la lista sin ella.
  Future<void> deleteById(String id) async {
    final routines = await list();
    routines.removeWhere((r) => r.id == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(routines.map((r) => r.toJson()).toList()));
  }
}
