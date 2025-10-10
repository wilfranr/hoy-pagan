class Usuario {
  final String nombre;
  final String email;
  final String telefono;
  final String estado;
  final String ciudad;
  final DateTime fechaNacimiento;

  Usuario({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.estado,
    required this.ciudad,
    required this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'estado': estado,
      'ciudad': ciudad,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      estado: json['estado'],
      ciudad: json['ciudad'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
    );
  }

  Usuario copyWith({
    String? nombre,
    String? email,
    String? telefono,
    String? estado,
    String? ciudad,
    DateTime? fechaNacimiento,
  }) {
    return Usuario(
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      estado: estado ?? this.estado,
      ciudad: ciudad ?? this.ciudad,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    );
  }
}

