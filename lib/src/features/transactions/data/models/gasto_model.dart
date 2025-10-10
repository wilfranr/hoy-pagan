import 'package:uuid/uuid.dart';

class Gasto {
  String id;
  String nombre;
  double monto;
  int diaDePago;
  bool pagado;
  bool esRecurrente;
  DateTime? fechaVencimiento;
  String categoriaId; // ID de la categoría asociada

  Gasto({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.diaDePago,
    required this.pagado,
    this.esRecurrente = true,
    this.fechaVencimiento,
    required this.categoriaId,
  });

  // Constructor factory para crear Gasto desde JSON
  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      monto: (json['monto'] as num).toDouble(),
      diaDePago: json['diaDePago'] as int,
      pagado: json['pagado'] as bool,
      esRecurrente: json['esRecurrente'] as bool? ?? true,
      fechaVencimiento: json['fechaVencimiento'] != null
        ? DateTime.parse(json['fechaVencimiento'] as String)
        : null,
      categoriaId: json['categoriaId'] as String? ?? '', // Compatibilidad con datos existentes
    );
  }

  // Método para convertir Gasto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'monto': monto,
      'diaDePago': diaDePago,
      'pagado': pagado,
      'esRecurrente': esRecurrente,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'categoriaId': categoriaId,
    };
  }

  // Constructor para crear un nuevo gasto con ID único
  factory Gasto.nuevo({
    required String nombre,
    required double monto,
    required int diaDePago,
    bool esRecurrente = true,
    DateTime? fechaVencimiento,
    required String categoriaId,
  }) {
    return Gasto(
      id: const Uuid().v4(),
      nombre: nombre,
      monto: monto,
      diaDePago: diaDePago,
      pagado: false,
      esRecurrente: esRecurrente,
      fechaVencimiento: fechaVencimiento,
      categoriaId: categoriaId,
    );
  }
}