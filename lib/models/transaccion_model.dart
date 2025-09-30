import 'package:uuid/uuid.dart';

class Transaccion {
  String id;
  String tipo; // 'ingreso', 'gasto', 'ahorro', 'inversion'
  double monto;
  String descripcion;
  DateTime fecha;
  String categoriaId; // ID de la categoría asociada

  Transaccion({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.categoriaId,
  });

  // Constructor factory para crear Transaccion desde JSON
  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      categoriaId: json['categoriaId'] as String? ?? '', // Compatibilidad con datos existentes
    );
  }

  // Método para convertir Transaccion a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'categoriaId': categoriaId,
    };
  }

  // Constructor para crear una nueva transacción con ID único
  factory Transaccion.nueva({
    required String tipo,
    required double monto,
    required String descripcion,
    required String categoriaId,
  }) {
    return Transaccion(
      id: const Uuid().v4(),
      tipo: tipo,
      monto: monto,
      descripcion: descripcion,
      fecha: DateTime.now(),
      categoriaId: categoriaId,
    );
  }
}
