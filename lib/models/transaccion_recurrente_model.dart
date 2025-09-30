import 'package:uuid/uuid.dart';

class TransaccionRecurrente {
  String id;
  String descripcion;
  double monto;
  String tipo; // 'ingreso' o 'gasto'
  bool activa;
  DateTime fechaInicio;
  String frecuencia; // 'mensual', 'semanal', 'anual'
  String condicionFin; // 'numero_pagos', 'fecha_especifica', 'nunca'
  dynamic valorFin; // int para número de pagos o DateTime para fecha
  String categoriaId; // ID de la categoría asociada

  TransaccionRecurrente({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.tipo,
    required this.activa,
    required this.fechaInicio,
    required this.frecuencia,
    required this.condicionFin,
    this.valorFin,
    required this.categoriaId,
  });

  // Constructor factory para crear TransaccionRecurrente desde JSON
  factory TransaccionRecurrente.fromJson(Map<String, dynamic> json) {
    return TransaccionRecurrente(
      id: json['id'] as String,
      descripcion: json['descripcion'] as String,
      monto: (json['monto'] as num).toDouble(),
      tipo: json['tipo'] as String,
      activa: json['activa'] as bool,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      frecuencia: json['frecuencia'] as String,
      condicionFin: json['condicionFin'] as String,
      valorFin: json['valorFin'] != null
        ? (json['condicionFin'] == 'fecha_especifica'
            ? DateTime.parse(json['valorFin'] as String)
            : json['valorFin'] as int)
        : null,
      categoriaId: json['categoriaId'] as String? ?? '',
    );
  }

  // Método para convertir TransaccionRecurrente a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'tipo': tipo,
      'activa': activa,
      'fechaInicio': fechaInicio.toIso8601String(),
      'frecuencia': frecuencia,
      'condicionFin': condicionFin,
      'valorFin': valorFin is DateTime
        ? (valorFin as DateTime).toIso8601String()
        : valorFin,
      'categoriaId': categoriaId,
    };
  }

  // Constructor para crear una nueva transacción recurrente con ID único
  factory TransaccionRecurrente.nueva({
    required String descripcion,
    required double monto,
    required String tipo,
    required DateTime fechaInicio,
    required String frecuencia,
    required String condicionFin,
    dynamic valorFin,
    required String categoriaId,
  }) {
    return TransaccionRecurrente(
      id: const Uuid().v4(),
      descripcion: descripcion,
      monto: monto,
      tipo: tipo,
      activa: true,
      fechaInicio: fechaInicio,
      frecuencia: frecuencia,
      condicionFin: condicionFin,
      valorFin: valorFin,
      categoriaId: categoriaId,
    );
  }
}
