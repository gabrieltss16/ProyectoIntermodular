class Exercise {
  final String id;
  final String zonaId;
  final String nombre;
  final String descripcion;
  final int series;
  final int repeticiones;
  final String? imagen;

  Exercise({
    required this.id,
    required this.zonaId,
    required this.nombre,
    required this.descripcion,
    required this.series,
    required this.repeticiones,
    this.imagen,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      zonaId: json['zonaId'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      series: (json['series'] as num).toInt(),
      repeticiones: (json['repeticiones'] as num).toInt(),
      imagen: json['imagen'] as String?,
    );
  }
}