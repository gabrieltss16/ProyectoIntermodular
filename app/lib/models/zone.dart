class Zone {
  final String id;
  final String nombre;

  Zone({required this.id, required this.nombre});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
    );
  }
}