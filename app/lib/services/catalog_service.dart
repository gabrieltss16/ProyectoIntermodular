import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise.dart';
import '../models/zone.dart';

class CatalogData {
  final List<Zone> zones;
  final List<Exercise> exercises;

  CatalogData({required this.zones, required this.exercises});
}

class CatalogService {
  Future<CatalogData> load() async {
    final raw = await rootBundle.loadString('assets/exercises.json');
    final jsonMap = jsonDecode(raw) as Map<String, dynamic>;

    final zonesJson = (jsonMap['zones'] as List).cast<Map<String, dynamic>>();
    final exercisesJson =
        (jsonMap['exercises'] as List).cast<Map<String, dynamic>>();

    final zones = zonesJson.map(Zone.fromJson).toList();
    final exercises = exercisesJson.map(Exercise.fromJson).toList();

    return CatalogData(zones: zones, exercises: exercises);
  }
}