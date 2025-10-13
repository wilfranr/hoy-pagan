import 'package:uuid/uuid.dart';

class PagoPendiente {
  String id;
  String transaccionRecurrenteId; // ID de la transacción recurrente que lo generó
  String descripcion;
  double montoEstimado; // Monto estimado de la transacción recurrente
  double montoReal; // Monto real que se pagó (puede ser diferente)
  DateTime fechaVencimiento;
  String referencia; // Número de referencia, factura, etc.
  bool pagado;
  DateTime? fechaPago;
  String tipoDeGasto;
  Map<String, dynamic> datosFijos; // Datos que no cambian (empresa, contrato, etc.)
  Map<String, dynamic> datosVariables; // Datos que cambian cada mes (monto, fecha, referencia)
  String categoriaId;

  PagoPendiente({
    required this.id,
    required this.transaccionRecurrenteId,
    required this.descripcion,
    required this.montoEstimado,
    this.montoReal = 0.0,
    required this.fechaVencimiento,
    this.referencia = '',
    this.pagado = false,
    this.fechaPago,
    required this.tipoDeGasto,
    this.datosFijos = const {},
    this.datosVariables = const {},
    required this.categoriaId,
  });

  // Constructor factory para crear PagoPendiente desde JSON
  factory PagoPendiente.fromJson(Map<String, dynamic> json) {
    return PagoPendiente(
      id: json['id'] as String,
      transaccionRecurrenteId: json['transaccionRecurrenteId'] as String,
      descripcion: json['descripcion'] as String,
      montoEstimado: (json['montoEstimado'] as num).toDouble(),
      montoReal: (json['montoReal'] as num?)?.toDouble() ?? 0.0,
      fechaVencimiento: DateTime.parse(json['fechaVencimiento'] as String),
      referencia: json['referencia'] as String? ?? '',
      pagado: json['pagado'] as bool? ?? false,
      fechaPago: json['fechaPago'] != null 
        ? DateTime.parse(json['fechaPago'] as String)
        : null,
      tipoDeGasto: json['tipoDeGasto'] as String,
      datosFijos: Map<String, dynamic>.from(json['datosFijos'] ?? {}),
      datosVariables: Map<String, dynamic>.from(json['datosVariables'] ?? {}),
      categoriaId: json['categoriaId'] as String,
    );
  }

  // Método para convertir PagoPendiente a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaccionRecurrenteId': transaccionRecurrenteId,
      'descripcion': descripcion,
      'montoEstimado': montoEstimado,
      'montoReal': montoReal,
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'referencia': referencia,
      'pagado': pagado,
      'fechaPago': fechaPago?.toIso8601String(),
      'tipoDeGasto': tipoDeGasto,
      'datosFijos': datosFijos,
      'datosVariables': datosVariables,
      'categoriaId': categoriaId,
    };
  }

  // Constructor para crear un nuevo pago pendiente desde una transacción recurrente
  factory PagoPendiente.desdeTransaccionRecurrente({
    required String transaccionRecurrenteId,
    required String descripcion,
    required double montoEstimado,
    required DateTime fechaVencimiento,
    required String tipoDeGasto,
    required Map<String, dynamic> datosFijos,
    required String categoriaId,
  }) {
    return PagoPendiente(
      id: const Uuid().v4(),
      transaccionRecurrenteId: transaccionRecurrenteId,
      descripcion: descripcion,
      montoEstimado: montoEstimado,
      fechaVencimiento: fechaVencimiento,
      tipoDeGasto: tipoDeGasto,
      datosFijos: datosFijos,
      categoriaId: categoriaId,
    );
  }

  // Método para marcar como pagado
  void marcarComoPagado({required double montoReal, required String referencia}) {
    pagado = true;
    fechaPago = DateTime.now();
    this.montoReal = montoReal;
    this.referencia = referencia;
  }

  // Método para obtener el monto a mostrar (real si está pagado, estimado si no)
  double get montoActual => pagado ? montoReal : montoEstimado;

  // Método para verificar si vence hoy
  bool get venceHoy {
    final hoy = DateTime.now();
    return fechaVencimiento.year == hoy.year &&
           fechaVencimiento.month == hoy.month &&
           fechaVencimiento.day == hoy.day;
  }

  // Método para verificar si está vencido
  bool get estaVencido {
    return !pagado && DateTime.now().isAfter(fechaVencimiento);
  }
}
