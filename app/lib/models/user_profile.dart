class UserProfile {
  final String? nombre;
  final int? edad;
  final String? zonaPrincipalId;
  final String? nivelExperiencia;
  final String? objetivos;

  const UserProfile({
    required this.nombre,
    required this.edad,
    required this.zonaPrincipalId,
    this.nivelExperiencia,
    this.objetivos,
  });

  factory UserProfile.empty() {
    return const UserProfile(
      nombre: null,
      edad: null,
      zonaPrincipalId: null,
      nivelExperiencia: null,
      objetivos: null,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final edadRaw = json['edad'];
    final edad = (edadRaw is num) ? edadRaw.toInt() : null;

    return UserProfile(
      nombre: json['nombre'] as String?,
      edad: edad,
      zonaPrincipalId: json['zonaPrincipalId'] as String?,
      nivelExperiencia: json['nivelExperiencia'] as String?,
      objetivos: json['objetivos'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'edad': edad,
      'zonaPrincipalId': zonaPrincipalId,
      'nivelExperiencia': nivelExperiencia,
      'objetivos': objetivos,
    };
  }

  UserProfile copyWith({
    String? nombre,
    int? edad,
    String? zonaPrincipalId,
    String? nivelExperiencia,
    String? objetivos,
  }) {
    return UserProfile(
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      zonaPrincipalId: zonaPrincipalId ?? this.zonaPrincipalId,
      nivelExperiencia: nivelExperiencia ?? this.nivelExperiencia,
      objetivos: objetivos ?? this.objetivos,
    );
  }
}
