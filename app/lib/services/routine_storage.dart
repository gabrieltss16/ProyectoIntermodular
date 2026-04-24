import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/routine.dart';

class RoutineStorage {
  static const _key = 'routines_v1';

  Future<List<Routine>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return <Routine>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Routine>[];

    final routines = decoded
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .map(Routine.fromJson)
        .toList();

    routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return routines;
  }

  Future<void> upsert(Routine routine) async {
    final routines = await list();
    final idx = routines.indexWhere((r) => r.id == routine.id);
    if (idx >= 0) {
      routines[idx] = routine;
    } else {
      routines.add(routine);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(routines.map((r) => r.toJson()).toList()));
  }

  Future<void> deleteById(String id) async {
    final routines = await list();
    routines.removeWhere((r) => r.id == id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(routines.map((r) => r.toJson()).toList()));
  }
}
