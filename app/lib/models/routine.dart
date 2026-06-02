// Modelo de datos para una rutina de ejercicios.
// En Dart los modelos son clases normales con campos final (inmutables).
// Equivalente a una data class en Kotlin.
class Routine {
  final String id;            // Identificador único (microsegundos como String)
  final String nombre;        // Nombre de la rutina (nunca vacío, validado en create())
  final String descripcion;   // Descripción opcional
  final bool creadaPorIA;     // true si la generó el asistente IA
  final DateTime createdAt;   // Fecha de creación para ordenar en Firestore
  final List<String> exerciseIds; // IDs de los ejercicios incluidos (lista inmutable)

  Routine({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creadaPorIA,
    required this.createdAt,
    required this.exerciseIds,
  });

  // Constructor con nombre 'create': factory que genera el ID y valida el nombre.
  // Los factory constructors en Dart son como métodos estáticos de creación en Kotlin.
  // Esto evita que se creen rutinas con ID nulo o nombre vacío.
  factory Routine.create({
    required String nombre,
    required String descripcion,
    required bool creadaPorIA,
    required List<String> exerciseIds,
  }) {
    // ID único basado en microsegundos: prácticamente imposible que colisionen.
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    // Validación en capa de modelo: si el nombre llega vacío, asignamos un valor por defecto.
    final safeName = nombre.trim().isEmpty ? 'Rutina sin nombre' : nombre.trim();
    return Routine(
      id: id,
      nombre: safeName,
      descripcion: descripcion,
      creadaPorIA: creadaPorIA,
      createdAt: DateTime.now(), // Marca la fecha de creación en el momento exacto
      // List.unmodifiable() crea una lista de solo lectura.
      // Evita que el código externo modifique los exerciseIds accidentalmente.
      exerciseIds: List.unmodifiable(exerciseIds),
    );
  }

  // copyWith es el patrón estándar en Dart/Flutter para "modificar" un objeto inmutable.
  // Como los campos son final, no podemos cambiarlos directamente.
  // En su lugar, creamos un objeto nuevo con los campos que queremos cambiar.
  // Equivale al método copy() de las data class en Kotlin.
  Routine copyWith({
    String? nombre,
    String? descripcion,
    bool? creadaPorIA,
    DateTime? createdAt,
    List<String>? exerciseIds,
  }) {
    final nextName = (nombre ?? this.nombre).trim();
    return Routine(
      id: id, // El ID nunca cambia al editar
      nombre: nextName.isEmpty ? 'Rutina sin nombre' : nextName,
      descripcion: descripcion ?? this.descripcion,
      creadaPorIA: creadaPorIA ?? this.creadaPorIA,
      createdAt: createdAt ?? this.createdAt,
      exerciseIds: List.unmodifiable(exerciseIds ?? this.exerciseIds),
    );
  }

  // Serializa la rutina a un mapa JSON para guardarla en Firestore o SharedPreferences.
  // En Android sería equivalente a implementar Parcelable o usar Gson/Moshi.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'creadaPorIA': creadaPorIA,
      'createdAt': createdAt.toIso8601String(), // Guarda la fecha como String ISO 8601
      'exerciseIds': exerciseIds,
    };
  }

  // Deserializa desde un mapa JSON. El operador 'as Type?' hace un cast con null-safety.
  // Si el campo no existe en el JSON, el operador ?? asigna el valor por defecto.
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
