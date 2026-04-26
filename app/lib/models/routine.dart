class Routine {
  final String id;
  final String nombre;
  final String descripcion;
  final bool creadaPorIA;
  final DateTime createdAt;
  final List<String> exerciseIds;

  Routine({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creadaPorIA,
    required this.createdAt,
    required this.exerciseIds,
  });

  factory Routine.create({
    required String nombre,
    required String descripcion,
    required bool creadaPorIA,
    required List<String> exerciseIds,
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final safeName = nombre.trim().isEmpty ? 'Rutina sin nombre' : nombre.trim();
    return Routine(
      id: id,
      nombre: safeName,
      descripcion: descripcion,
      creadaPorIA: creadaPorIA,
      createdAt: DateTime.now(),
      exerciseIds: List.unmodifiable(exerciseIds),
    );
  }

  Routine copyWith({
    String? nombre,
    String? descripcion,
    bool? creadaPorIA,
    DateTime? createdAt,
    List<String>? exerciseIds,
  }) {
    final nextName = (nombre ?? this.nombre).trim();
    return Routine(
      id: id,
      nombre: nextName.isEmpty ? 'Rutina sin nombre' : nextName,
      descripcion: descripcion ?? this.descripcion,
      creadaPorIA: creadaPorIA ?? this.creadaPorIA,
      createdAt: createdAt ?? this.createdAt,
      exerciseIds: List.unmodifiable(exerciseIds ?? this.exerciseIds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'creadaPorIA': creadaPorIA,
      'createdAt': createdAt.toIso8601String(),
      'exerciseIds': exerciseIds,
    };
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    final rawName = ((json['nombre'] as String?) ?? '').trim();
    return Routine(
      id: json['id'] as String,
      nombre: rawName.isEmpty ? 'Rutina sin nombre' : rawName,
      descripcion: (json['descripcion'] as String?) ?? '',
      creadaPorIA: (json['creadaPorIA'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      exerciseIds: ((json['exerciseIds'] as List?) ?? const <dynamic>[]).cast<String>(),
    );
  }
}
