class UserProfile {
  final String? nombre;
  final int? edad;
  final String? zonaPrincipalId;

  const UserProfile({
    required this.nombre,
    required this.edad,
    required this.zonaPrincipalId,
  });

  factory UserProfile.empty() {
    return const UserProfile(nombre: null, edad: null, zonaPrincipalId: null);
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final edadRaw = json['edad'];
    final edad = (edadRaw is num) ? edadRaw.toInt() : null;

    return UserProfile(
      nombre: json['nombre'] as String?,
      edad: edad,
      zonaPrincipalId: json['zonaPrincipalId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'edad': edad,
      'zonaPrincipalId': zonaPrincipalId,
    };
  }

  UserProfile copyWith({
    String? nombre,
    int? edad,
    String? zonaPrincipalId,
  }) {
    return UserProfile(
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      zonaPrincipalId: zonaPrincipalId ?? this.zonaPrincipalId,
    );
  }
}
