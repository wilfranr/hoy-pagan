

/// Modelo de datos para representar un gasto.
///
/// Incluye métodos para la serialización y deserialización JSON,
/// lo que facilita su almacenamiento en `shared_preferences`.
class Gasto {
  String nombre;
  double monto;
  int diaDePago;
  bool pagado;
  String? descripcion;
  String? categoria;

  Gasto({
    required this.nombre,
    required this.monto,
    required this.diaDePago,
    required this.pagado,
    this.descripcion,
    this.categoria,
  });

  /// Convierte la instancia de Gasto a un mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'monto': monto,
      'diaDePago': diaDePago,
      'pagado': pagado,
      'descripcion': descripcion,
      'categoria': categoria,
    };
  }

  /// Crea una instancia de Gasto a partir de un mapa (JSON).
  factory Gasto.fromJson(Map<String, dynamic> json) {
    // Se asegura de que el monto se lea como double, incluso si viene como int.
    final monto = json['monto'] is int ? (json['monto'] as int).toDouble() : json['monto'];
    
    return Gasto(
      nombre: json['nombre'],
      monto: monto,
      diaDePago: json['diaDePago'],
      pagado: json['pagado'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
    );
  }
}
