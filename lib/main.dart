import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'app_themes.dart';
import 'screens/theme_selector_screen.dart';

// Modelo de datos
class Categoria {
  String id;
  String nombre;
  String tipo; // 'ingreso' o 'gasto'
  int icono; // codePoint del IconData

  Categoria({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.icono,
  });

  // Constructor factory para crear Categoria desde JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      icono: json['icono'] as int,
    );
  }

  // Método para convertir Categoria a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'icono': icono,
    };
  }

  // Constructor para crear una nueva categoría con ID único
  factory Categoria.nueva({
    required String nombre,
    required String tipo,
    required int icono,
  }) {
    return Categoria(
      id: const Uuid().v4(),
      nombre: nombre,
      tipo: tipo,
      icono: icono,
    );
  }
}

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'KIPU',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables del estado
  double ingresoMensual = 2500000.0; // Ya no es constante
  double saldoDisponible = 0.0;
  List<Gasto> listaDeGastos = [];
  List<Transaccion> listaDeTransacciones = [];
  List<TransaccionRecurrente> listaDeTransaccionesRecurrentes = [];
  List<Categoria> listaDeCategorias = [];
  
  // Constante para el día de pago
  final int diaDePago = 1;
  

  // Función para obtener el ícono según la categoría del gasto
  IconData _getIconForGasto(String nombre) {
    if (nombre.toLowerCase().contains('alquiler') || nombre.toLowerCase().contains('arriendo')) {
      return Icons.home;
    } else if (nombre.toLowerCase().contains('servicios') || nombre.toLowerCase().contains('facturas')) {
      return Icons.receipt_long;
    } else if (nombre.toLowerCase().contains('supermercado') || nombre.toLowerCase().contains('comida')) {
      return Icons.shopping_cart;
    } else if (nombre.toLowerCase().contains('transporte')) {
      return Icons.directions_bus;
    } else if (nombre.toLowerCase().contains('internet') || nombre.toLowerCase().contains('telefonía')) {
      return Icons.wifi;
    } else {
      return Icons.payment;
    }
  }

  // Función para obtener el ícono según el tipo de transacción
  IconData _getIconForTransaccion(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Icons.arrow_downward;
      case 'gasto':
        return Icons.arrow_upward;
      case 'ahorro':
        return Icons.savings;
      case 'inversion':
        return Icons.trending_up;
      default:
        return Icons.payment;
    }
  }

  // Función para obtener el color según el tipo de transacción
  Color _getColorForTransaccion(String tipo) {
    switch (tipo) {
      case 'ingreso':
        return Colors.green;
      case 'gasto':
        return Colors.red;
      case 'ahorro':
        return Colors.blue;
      case 'inversion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Función para obtener el ícono de la categoría
  IconData _getIconForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Icons.help;
    final categoria = listaDeCategorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return IconData(categoria.icono, fontFamily: 'MaterialIcons');
  }

  // Función para obtener el color de la categoría
  Color _getColorForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Colors.grey;
    final categoria = listaDeCategorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return categoria.tipo == 'ingreso' ? Colors.green : Colors.red;
  }

  // Función para combinar gastos fijos y transacciones recientes agrupadas por fecha
  List<Map<String, dynamic>> _getCombinedItems() {
    List<Map<String, dynamic>> items = [];
    
    // Crear un mapa para agrupar transacciones por fecha
    Map<String, List<Map<String, dynamic>>> transaccionesPorFecha = {};
    
     // Procesar gastos fijos (no se agrupan por fecha)
     for (var gasto in listaDeGastos) {
       items.add({
         'isGasto': true,
         'isHeader': false,
         'titulo': gasto.nombre,
         'subtitulo': gasto.pagado 
           ? 'Pagado el día ${gasto.diaDePago} · ${_obtenerNombreCategoria(gasto.categoriaId)}'
           : 'Vence el día ${gasto.diaDePago} · ${_obtenerNombreCategoria(gasto.categoriaId)}',
         'monto': formatoMoneda(gasto.monto),
         'montoColor': gasto.pagado ? Colors.grey : Colors.black87,
         'icon': gasto.pagado ? Icons.check_circle : _getIconForCategoria(gasto.categoriaId),
         'color': gasto.pagado ? Colors.green : _getColorForCategoria(gasto.categoriaId),
         'pagado': gasto.pagado,
         'fecha': null,
       });
     }
    
    // Procesar transacciones y agruparlas por fecha
    final transaccionesRecientes = listaDeTransacciones
        .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
    
    for (var transaccion in transaccionesRecientes.take(20)) {
      String titulo = '';
      
      switch (transaccion.tipo) {
        case 'ingreso':
          titulo = 'Ingreso Extra';
          break;
        case 'gasto':
          titulo = 'Gasto Variable';
          break;
        case 'ahorro':
          titulo = 'Ahorro';
          break;
        case 'inversion':
          titulo = 'Inversión';
          break;
      }
      
      final fechaKey = DateFormat('dd/MM/yyyy').format(transaccion.fecha);
      final hora = DateFormat('HH:mm').format(transaccion.fecha);
      
      if (!transaccionesPorFecha.containsKey(fechaKey)) {
        transaccionesPorFecha[fechaKey] = [];
      }
      
      transaccionesPorFecha[fechaKey]!.add({
        'isGasto': false,
        'isHeader': false,
        'titulo': titulo,
        'subtitulo': '$hora · ${transaccion.descripcion}',
        'monto': transaccion.tipo == 'ingreso' ? '+${formatoMoneda(transaccion.monto)}' : formatoMoneda(transaccion.monto),
        'montoColor': transaccion.tipo == 'ingreso' ? Colors.green : Colors.red,
        'icon': _getIconForCategoria(transaccion.categoriaId),
        'color': _getColorForCategoria(transaccion.categoriaId),
        'pagado': false,
        'fecha': transaccion.fecha,
      });
    }
    
    // Añadir headers de fecha y transacciones agrupadas
    final fechasOrdenadas = transaccionesPorFecha.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)));
    
    for (var fecha in fechasOrdenadas) {
      // Añadir header de fecha
      final fechaObj = DateFormat('dd/MM/yyyy').parse(fecha);
      final diaSemana = DateFormat('EEEE', 'es').format(fechaObj);
      final mesAno = DateFormat('MMMM yyyy', 'es').format(fechaObj);
      
      items.add({
        'isGasto': false,
        'isHeader': true,
        'titulo': '$diaSemana, ${fechaObj.day} $mesAno',
        'subtitulo': '',
        'monto': '',
        'montoColor': Colors.black87,
        'icon': null,
        'color': Colors.grey,
        'pagado': false,
        'fecha': fechaObj,
      });
      
      // Añadir transacciones de esa fecha
      items.addAll(transaccionesPorFecha[fecha]!);
    }
    
    return items;
  }

  // Función para formatear moneda
  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return currencyFormat.format(monto);
  }

  // Función para inicializar categorías predeterminadas
  void _inicializarCategorias() {
    listaDeCategorias = [
      // Categorías de Ingresos
      Categoria.nueva(nombre: 'Salario', tipo: 'ingreso', icono: Icons.work.codePoint),
      Categoria.nueva(nombre: 'Bonificación', tipo: 'ingreso', icono: Icons.card_giftcard.codePoint),
      Categoria.nueva(nombre: 'Ventas', tipo: 'ingreso', icono: Icons.sell.codePoint),
      Categoria.nueva(nombre: 'Otros Ingresos', tipo: 'ingreso', icono: Icons.attach_money.codePoint),
      
      // Categorías de Gastos
      Categoria.nueva(nombre: 'Hogar', tipo: 'gasto', icono: Icons.home.codePoint),
      Categoria.nueva(nombre: 'Transporte', tipo: 'gasto', icono: Icons.directions_car.codePoint),
      Categoria.nueva(nombre: 'Alimentación', tipo: 'gasto', icono: Icons.restaurant.codePoint),
      Categoria.nueva(nombre: 'Salud', tipo: 'gasto', icono: Icons.medical_services.codePoint),
      Categoria.nueva(nombre: 'Entretenimiento', tipo: 'gasto', icono: Icons.movie.codePoint),
      Categoria.nueva(nombre: 'Educación', tipo: 'gasto', icono: Icons.school.codePoint),
      Categoria.nueva(nombre: 'Deudas', tipo: 'gasto', icono: Icons.credit_card.codePoint),
      
      // Categorías de Ahorro
      Categoria.nueva(nombre: 'Fondo de Emergencia', tipo: 'ahorro', icono: Icons.emergency.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Vivienda', tipo: 'ahorro', icono: Icons.home_work.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Vehículo', tipo: 'ahorro', icono: Icons.directions_car.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Educación', tipo: 'ahorro', icono: Icons.school.codePoint),
      Categoria.nueva(nombre: 'Vacaciones y Ocio', tipo: 'ahorro', icono: Icons.flight.codePoint),
      Categoria.nueva(nombre: 'Compras Grandes', tipo: 'ahorro', icono: Icons.shopping_bag.codePoint),
      Categoria.nueva(nombre: 'Metas Personales', tipo: 'ahorro', icono: Icons.flag.codePoint),
      Categoria.nueva(nombre: 'Ahorro General', tipo: 'ahorro', icono: Icons.savings.codePoint),
      
      // Categorías de Inversión
      Categoria.nueva(nombre: 'Renta Variable (Acciones)', tipo: 'inversion', icono: Icons.trending_up.codePoint),
      Categoria.nueva(nombre: 'Criptomonedas', tipo: 'inversion', icono: Icons.currency_bitcoin.codePoint),
      Categoria.nueva(nombre: 'Renta Fija (Bonos, CDT)', tipo: 'inversion', icono: Icons.account_balance.codePoint),
      Categoria.nueva(nombre: 'Bienes Raíces', tipo: 'inversion', icono: Icons.business.codePoint),
      Categoria.nueva(nombre: 'Fondos de Inversión / ETFs', tipo: 'inversion', icono: Icons.pie_chart.codePoint),
      Categoria.nueva(nombre: 'Plan de Retiro Voluntario', tipo: 'inversion', icono: Icons.account_balance_wallet.codePoint),
      Categoria.nueva(nombre: 'Materias Primas', tipo: 'inversion', icono: Icons.diamond.codePoint),
      Categoria.nueva(nombre: 'Emprendimientos / Negocios', tipo: 'inversion', icono: Icons.business_center.codePoint),
    ];
  }

  // Función para obtener el nombre de la categoría por ID
  String _obtenerNombreCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return 'Sin categoría';
    final categoria = listaDeCategorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return categoria.nombre;
  }

  // Función para guardar datos en SharedPreferences
  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Guardar saldo disponible
    await prefs.setDouble('saldo', saldoDisponible);
    
    // Guardar ingreso mensual
    await prefs.setDouble('ingresoMensual', ingresoMensual);
    
    
    // Convertir lista de gastos a JSON y guardar
    final gastosJson = jsonEncode(listaDeGastos.map((gasto) => gasto.toJson()).toList());
    await prefs.setString('gastos', gastosJson);
    
    // Convertir lista de transacciones a JSON y guardar
    final transaccionesJson = jsonEncode(listaDeTransacciones.map((transaccion) => transaccion.toJson()).toList());
    await prefs.setString('transacciones', transaccionesJson);
    
    // Convertir lista de categorías a JSON y guardar
    final categoriasJson = jsonEncode(listaDeCategorias.map((categoria) => categoria.toJson()).toList());
    await prefs.setString('categorias', categoriasJson);
    
    // Convertir lista de transacciones recurrentes a JSON y guardar
    final transaccionesRecurrentesJson = jsonEncode(listaDeTransaccionesRecurrentes.map((transaccion) => transaccion.toJson()).toList());
    await prefs.setString('transaccionesRecurrentes', transaccionesRecurrentesJson);
  }

  // Función para cargar datos desde SharedPreferences
  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cargar saldo disponible
    saldoDisponible = prefs.getDouble('saldo') ?? 0.0;
    
    // Cargar ingreso mensual
    ingresoMensual = prefs.getDouble('ingresoMensual') ?? 2500000.0;
    
    
    // Cargar lista de gastos
    final gastosJson = prefs.getString('gastos');
    if (gastosJson != null) {
      final List<dynamic> gastosList = jsonDecode(gastosJson);
      listaDeGastos = gastosList.map((json) => Gasto.fromJson(json)).toList();
    } else {
      // Si no hay datos guardados, la lista estará vacía
      listaDeGastos = [];
    }
    
    // Cargar lista de transacciones
    final transaccionesJson = prefs.getString('transacciones');
    if (transaccionesJson != null) {
      final List<dynamic> transaccionesList = jsonDecode(transaccionesJson);
      listaDeTransacciones = transaccionesList.map((json) => Transaccion.fromJson(json)).toList();
    } else {
      // Si no hay datos guardados, la lista estará vacía
      listaDeTransacciones = [];
    }
    
    // Cargar lista de categorías
    final categoriasJson = prefs.getString('categorias');
    if (categoriasJson != null) {
      final List<dynamic> categoriasList = jsonDecode(categoriasJson);
      listaDeCategorias = categoriasList.map((json) => Categoria.fromJson(json)).toList();
    } else {
      // Si no hay datos guardados, la lista estará vacía
      listaDeCategorias = [];
    }
    
    // Cargar lista de transacciones recurrentes
    final transaccionesRecurrentesJson = prefs.getString('transaccionesRecurrentes');
    if (transaccionesRecurrentesJson != null) {
      final List<dynamic> transaccionesRecurrentesList = jsonDecode(transaccionesRecurrentesJson);
      listaDeTransaccionesRecurrentes = transaccionesRecurrentesList.map((json) => TransaccionRecurrente.fromJson(json)).toList();
    } else {
      // Si no hay datos guardados, la lista estará vacía
      listaDeTransaccionesRecurrentes = [];
    }
    
    // Inicializar categorías si la lista está vacía
    if (listaDeCategorias.isEmpty) {
      _inicializarCategorias();
    }
    
    setState(() {});
  }

  // Función para verificar si es el día de pago y mostrar modal si es necesario
  void _verificarDiaDePago() {
    final now = DateTime.now();
    final mesActual = '${now.year}-${now.month}';
    
    // La verificación de pago ahora se maneja a través de transacciones recurrentes
  }

  // Función para verificar pagos de gastos individuales
  void _verificarPagosDeGastos() {
    final now = DateTime.now();
    
    // Iterar sobre la lista de gastos para encontrar el primer gasto que cumpla las condiciones
    for (var gasto in listaDeGastos) {
      // Solo procesar gastos no pagados
      if (!gasto.pagado) {
        // Condición A: Recordatorio (un día antes)
        if (now.day == gasto.diaDePago - 1) {
          _mostrarModalRecordatorio(gasto);
          break; // Detener la iteración para no abrumar al usuario
        }
        // Condición B: Confirmación de pago (en el día o después)
        else if (now.day >= gasto.diaDePago) {
          _mostrarModalConfirmacionPago(gasto);
          break; // Detener la iteración para no abrumar al usuario
        }
      }
    }
  }

  Future<void> _revisarTransaccionesRecurrentes() async {
    final hoy = DateTime.now();
    
    for (final transaccion in listaDeTransaccionesRecurrentes) {
      if (!transaccion.activa) continue;
      
      // Verificar si es el día correcto según la frecuencia
      bool esDiaCorrecto = false;
      
      switch (transaccion.frecuencia) {
        case 'semanal':
          // Verificar si es el mismo día de la semana
          esDiaCorrecto = hoy.weekday == transaccion.fechaInicio.weekday;
          break;
        case 'mensual':
          // Verificar si es el mismo día del mes
          esDiaCorrecto = hoy.day == transaccion.fechaInicio.day;
          break;
        case 'anual':
          // Verificar si es el mismo día y mes
          esDiaCorrecto = hoy.day == transaccion.fechaInicio.day && 
                         hoy.month == transaccion.fechaInicio.month;
          break;
      }
      
      if (esDiaCorrecto && hoy.isAfter(transaccion.fechaInicio.subtract(const Duration(days: 1)))) {
        // Verificar si ya se procesó esta transacción hoy
        final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
        final prefs = await SharedPreferences.getInstance();
        final yaProcesado = prefs.getBool(clave) ?? false;
        
        if (!yaProcesado) {
          if (transaccion.tipo == 'ingreso') {
            _mostrarDialogoIngresoRecurrente(transaccion);
          } else if (transaccion.tipo == 'gasto') {
            _mostrarDialogoGastoRecurrente(transaccion);
          }
        }
      }
    }
  }

  void _mostrarDialogoIngresoRecurrente(TransaccionRecurrente transaccion) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.arrow_downward,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('¿Ya recibiste tu ingreso?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaccion.descripcion}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monto: ${currencyFormat.format(transaccion.monto)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Frecuencia: ${_getFrecuenciaText(transaccion.frecuencia)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Marcar como procesado para no volver a mostrar hoy
                final hoy = DateTime.now();
                final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(clave, true);
              },
              child: const Text('Más tarde'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _procesarIngresoRecurrente(transaccion);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, ya lo recibí'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoGastoRecurrente(TransaccionRecurrente transaccion) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: const Color(0xFF2EA198),
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('¿Ya pagaste este gasto?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${transaccion.descripcion}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monto: ${currencyFormat.format(transaccion.monto)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Frecuencia: ${_getFrecuenciaText(transaccion.frecuencia)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Marcar como procesado para no volver a mostrar hoy
                final hoy = DateTime.now();
                final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(clave, true);
              },
              child: const Text('Más tarde'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _procesarGastoRecurrente(transaccion);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EA198),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, ya lo pagué'),
            ),
          ],
        );
      },
    );
  }

  void _procesarIngresoRecurrente(TransaccionRecurrente transaccion) async {
    // 1. Incrementar saldo disponible
    saldoDisponible += transaccion.monto;
    
    // 2. Crear nueva transacción
    final nuevaTransaccion = Transaccion(
      id: const Uuid().v4(),
      descripcion: transaccion.descripcion,
      monto: transaccion.monto,
      tipo: 'ingreso',
      fecha: DateTime.now(),
      categoriaId: transaccion.categoriaId,
    );
    
    // 3. Agregar a la lista de transacciones
    listaDeTransacciones.add(nuevaTransaccion);
    
    // 4. Guardar datos
    await _guardarDatos();
    
    // 5. Marcar como procesado para no volver a mostrar hoy
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(clave, true);
    
    // 6. Mostrar confirmación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingreso de ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(transaccion.monto)} registrado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    // 7. Actualizar UI
    setState(() {});
  }

  void _procesarGastoRecurrente(TransaccionRecurrente transaccion) async {
    // 1. Decrementar saldo disponible
    saldoDisponible -= transaccion.monto;
    
    // 2. Crear nueva transacción
    final nuevaTransaccion = Transaccion(
      id: const Uuid().v4(),
      descripcion: transaccion.descripcion,
      monto: transaccion.monto,
      tipo: 'gasto',
      fecha: DateTime.now(),
      categoriaId: transaccion.categoriaId,
    );
    
    // 3. Agregar a la lista de transacciones
    listaDeTransacciones.add(nuevaTransaccion);
    
    // 4. Guardar datos
    await _guardarDatos();
    
    // 5. Marcar como procesado para no volver a mostrar hoy
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(clave, true);
    
    // 6. Mostrar confirmación
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto de ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(transaccion.monto)} registrado'),
          backgroundColor: const Color(0xFF2EA198),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    // 7. Actualizar UI
    setState(() {});
  }

  String _getFrecuenciaText(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return 'Cada semana';
      case 'mensual':
        return 'Cada mes';
      case 'anual':
        return 'Cada año';
      default:
        return 'Cada mes';
    }
  }



  // Función para mostrar modal de recordatorio
  Future<void> _mostrarModalRecordatorio(Gasto gasto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe responder
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recordatorio de Pago Próximo'),
          content: Text('Mañana, ${gasto.diaDePago}, vence el pago de "${gasto.nombre}".'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar modal
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar modal de confirmación de pago
  Future<void> _mostrarModalConfirmacionPago(Gasto gasto) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe responder
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pago Realizado'),
          content: Text('¿Ya pagaste la factura de "${gasto.nombre}" por un valor de ${formatoMoneda(gasto.monto)}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar modal
              },
              child: const Text('Aún no'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar modal
                
                // Buscar el gasto correspondiente en la lista y actualizar su estado
                final index = listaDeGastos.indexWhere((g) => g.id == gasto.id);
                if (index != -1) {
                  listaDeGastos[index].pagado = true;
                  
                  // Restar el monto del saldo disponible
                  saldoDisponible -= gasto.monto;
                  
                  // Guardar los datos
                  await _guardarDatos();
                  
                  // Actualizar la UI
                  setState(() {});
                }
              },
              child: const Text('Sí, ya pagué'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el menú de transacciones
  void _mostrarMenuDeTransacciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle del modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                'Nueva Transacción',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opciones de transacciones
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Añadir Ingreso',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Registrar un ingreso adicional'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioDeTransaccion('ingreso');
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Registrar Gasto',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Registrar un gasto no planificado'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioDeTransaccion('gasto');
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.savings,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Registrar Ahorro',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Guardar dinero para el futuro'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioDeTransaccion('ahorro');
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Registrar Inversión',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Invertir dinero para crecer'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioDeTransaccion('inversion');
                },
              ),
              
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EA198).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Color(0xFF2EA198),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Programar Transferencia',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Configurar transferencias recurrentes'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioRecurrente();
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Función para mostrar el formulario de transacción recurrente
  void _mostrarFormularioRecurrente() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioRecurrenteScreen(
          listaDeCategorias: listaDeCategorias,
          onTransaccionGuardada: (nuevaTransaccion) {
            setState(() {
              listaDeTransaccionesRecurrentes.add(nuevaTransaccion);
            });
            _guardarDatos();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transferencia recurrente programada exitosamente'),
                backgroundColor: Color(0xFF2EA198),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  // Función para mostrar el formulario de transacción
  void _mostrarFormularioDeTransaccion(String tipo) {
    final TextEditingController montoController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    String? categoriaSeleccionada;
    // Estado local para ingresos recurrentes (sólo aplica cuando tipo == 'ingreso')
    bool esRecurrente = false;
    DateTime? fechaInicio;
    String? frecuenciaSeleccionada; // 'semanal', 'mensual', 'anual'
    String? condicionFinSeleccionada; // 'nunca', 'numero_pagos', 'fecha_especifica'
    final TextEditingController numeroPagosController = TextEditingController();
    DateTime? fechaFinSeleccionada;
    
    // Títulos dinámicos según el tipo
    String titulo = '';
    switch (tipo) {
      case 'ingreso':
        titulo = 'Nuevo Ingreso';
        break;
      case 'gasto':
        titulo = 'Nuevo Gasto';
        break;
      case 'ahorro':
        titulo = 'Nuevo Ahorro';
        break;
      case 'inversion':
        titulo = 'Nueva Inversión';
        break;
    }

    // Filtrar categorías según el tipo
    final categoriasFiltradas = listaDeCategorias.where((cat) => cat.tipo == tipo).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoriaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categoriasFiltradas.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria.id,
                          child: Row(
                            children: [
                              Icon(
                                IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                                size: 20,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(categoria.nombre),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          categoriaSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    if (tipo == 'ingreso' || tipo == 'gasto') ...[
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        title: const Text('¿Es un ingreso recurrente?'),
                        value: esRecurrente,
                        onChanged: (v) {
                          setState(() {
                            esRecurrente = v;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (esRecurrente) ...[
                        const SizedBox(height: 8),
                        // Fecha de inicio
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fecha de inicio',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              final hoy = DateTime.now();
                              final seleccionada = await showDatePicker(
                                context: context,
                                initialDate: fechaInicio ?? hoy,
                                firstDate: DateTime(hoy.year - 2),
                                lastDate: DateTime(hoy.year + 5),
                              );
                              if (seleccionada != null) {
                                setState(() {
                                  fechaInicio = DateTime(
                                    seleccionada.year,
                                    seleccionada.month,
                                    seleccionada.day,
                                  );
                                });
                              }
                            },
                            child: Text(
                              fechaInicio == null
                                  ? 'Seleccionar fecha'
                                  : DateFormat.yMMMMd('es').format(fechaInicio!),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Frecuencia
                        DropdownButtonFormField<String>(
                          value: frecuenciaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Repetir',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                            DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                            DropdownMenuItem(value: 'anual', child: Text('Anual')),
                          ],
                          onChanged: (v) {
                            setState(() {
                              frecuenciaSeleccionada = v;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Condición de finalización
                        DropdownButtonFormField<String>(
                          value: condicionFinSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Hasta',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'nunca', child: Text('Nunca')),
                            DropdownMenuItem(value: 'numero_pagos', child: Text('Número de pagos')),
                            DropdownMenuItem(value: 'fecha_especifica', child: Text('Fecha específica')),
                          ],
                          onChanged: (v) {
                            setState(() {
                              condicionFinSeleccionada = v;
                              // Limpiar valores al cambiar
                              numeroPagosController.text = '';
                              fechaFinSeleccionada = null;
                            });
                          },
                        ),
                        if (condicionFinSeleccionada == 'numero_pagos') ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: numeroPagosController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad de pagos',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        if (condicionFinSeleccionada == 'fecha_especifica') ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Fecha de finalización',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                final base = fechaInicio ?? DateTime.now();
                                final seleccionada = await showDatePicker(
                                  context: context,
                                  initialDate: fechaFinSeleccionada ?? base,
                                  firstDate: base,
                                  lastDate: DateTime(base.year + 10),
                                );
                                if (seleccionada != null) {
                                  setState(() {
                                    fechaFinSeleccionada = DateTime(
                                      seleccionada.year,
                                      seleccionada.month,
                                      seleccionada.day,
                                    );
                                  });
                                }
                              },
                              child: Text(
                                fechaFinSeleccionada == null
                                    ? 'Seleccionar fecha'
                                    : DateFormat.yMMMMd('es').format(fechaFinSeleccionada!),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validar campos
                    if (montoController.text.isEmpty || 
                        descripcionController.text.isEmpty || 
                        categoriaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor completa todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final monto = double.tryParse(montoController.text);
                    if (monto == null || monto <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingresa un monto válido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Lógica diferenciada para ingresos/gastos recurrentes
                    if ((tipo == 'ingreso' || tipo == 'gasto') && esRecurrente) {
                      // Validaciones adicionales
                      if (fechaInicio == null ||
                          frecuenciaSeleccionada == null ||
                          condicionFinSeleccionada == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Completa los campos de recurrencia'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      dynamic valorFin;
                      if (condicionFinSeleccionada == 'numero_pagos') {
                        final n = int.tryParse(numeroPagosController.text);
                        if (n == null || n <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ingresa un número de pagos válido'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        valorFin = n;
                      } else if (condicionFinSeleccionada == 'fecha_especifica') {
                        if (fechaFinSeleccionada == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selecciona la fecha de finalización'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (fechaInicio!.isAfter(fechaFinSeleccionada!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La fecha fin debe ser posterior a inicio'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        valorFin = fechaFinSeleccionada;
                      }

                      // Crear transacción recurrente
                      final nuevaRecurrente = TransaccionRecurrente.nueva(
                        descripcion: descripcionController.text,
                        monto: monto,
                        tipo: tipo,
                        fechaInicio: fechaInicio!,
                        frecuencia: frecuenciaSeleccionada!,
                        condicionFin: condicionFinSeleccionada!,
                        valorFin: valorFin,
                        categoriaId: categoriaSeleccionada!,
                      );

                      // Cerrar diálogo primero
                      Navigator.of(context).pop();

                      // Registrar en estado
                      setState(() {
                        listaDeTransaccionesRecurrentes.add(nuevaRecurrente);

                        // Si la fecha de inicio es hoy o anterior, registrar la primera instancia
                        final hoy = DateTime.now();
                        final inicio = DateTime(fechaInicio!.year, fechaInicio!.month, fechaInicio!.day);
                        final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
                        if (inicio.isBefore(hoySolo) || inicio.isAtSameMomentAs(hoySolo)) {
                          final primera = Transaccion(
                            id: const Uuid().v4(),
                            tipo: tipo,
                            monto: monto,
                            descripcion: descripcionController.text,
                            fecha: inicio,
                            categoriaId: categoriaSeleccionada!,
                          );
                          listaDeTransacciones.add(primera);
                          if (tipo == 'ingreso') {
                            saldoDisponible += monto;
                          } else {
                            // gasto
                            saldoDisponible -= monto;
                          }
                        }
                      });

                      await _guardarDatos();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$titulo recurrente programado'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      // Crear nueva transacción simple
                      final nuevaTransaccion = Transaccion.nueva(
                        tipo: tipo,
                        monto: monto,
                        descripcion: descripcionController.text,
                        categoriaId: categoriaSeleccionada!,
                      );

                      // Cerrar diálogo primero
                      Navigator.of(context).pop();

                      // Actualizar estado del widget principal
                      setState(() {
                        listaDeTransacciones.add(nuevaTransaccion);
                        
                        // Actualizar saldo según el tipo
                        if (tipo == 'ingreso') {
                          saldoDisponible += monto;
                        } else {
                          // Para gasto, ahorro e inversión se resta del saldo
                          saldoDisponible -= monto;
                        }
                      });

                      // Guardar datos
                      await _guardarDatos();

                      // Mostrar confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$titulo registrado exitosamente'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarDatos().then((_) {
      _verificarDiaDePago();
      _verificarPagosDeGastos();
      _revisarTransaccionesRecurrentes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header estilo Starling Bank
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2EA198), Color(0xFF0A3834)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Barra superior
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Personal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                            onSelected: (String value) {
                              if (value == 'configuracion') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConfiguracionScreen(
                                      ingresoMensual: ingresoMensual,
                                      listaDeGastos: listaDeGastos,
                                      listaDeCategorias: listaDeCategorias,
                                      listaDeTransaccionesRecurrentes: listaDeTransaccionesRecurrentes,
                                      onDatosActualizados: (nuevoIngreso, nuevosGastos, nuevasTransaccionesRecurrentes) {
                                        setState(() {
                                          ingresoMensual = nuevoIngreso;
                                          listaDeGastos = nuevosGastos;
                                          listaDeTransaccionesRecurrentes = nuevasTransaccionesRecurrentes;
                                        });
                                        _guardarDatos();
                                      },
                                    ),
                                  ),
                                );
                              } else if (value == 'categorias') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoriasScreen(
                                      listaDeCategorias: listaDeCategorias,
                                      onCategoriasActualizadas: (nuevasCategorias) {
                                        setState(() {
                                          listaDeCategorias = nuevasCategorias;
                                        });
                                        _guardarDatos();
                                      },
                                    ),
                                  ),
                                );
                              } else if (value == 'tema') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ThemeSelectorScreen(),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'configuracion',
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Mi Dinero'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'categorias',
                                child: Row(
                                  children: [
                                    Icon(Icons.category, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Categorías'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'tema',
                                child: Row(
                                  children: [
                                    Icon(Icons.palette, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Tema'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'perfil',
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey),
                                    SizedBox(width: 8),
                                    Text('Perfil'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Saldo principal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currencyFormat.format(saldoDisponible),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _mostrarMenuDeTransacciones,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Resumen de gastos
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Gastado este mes',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Gastado hoy',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormat.format(0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Header de transacciones
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gastos y Transacciones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buscar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Lista combinada de gastos y transacciones
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _getCombinedItems().length,
                            itemBuilder: (context, index) {
                              final item = _getCombinedItems()[index];
                              
                              // Si es un header de fecha
                              if (item['isHeader'] == true) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 20, bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['titulo'] as String,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (item['monto'] != null && (item['monto'] as String).isNotEmpty)
                                        Text(
                                          item['monto'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: item['montoColor'] as Color,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                              
                              // Si es una transacción o gasto normal
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).dividerColor),
                                ),
                                child: Row(
                                  children: [
                                    // Ícono
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: item['color']!.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: item['icon'] != null
                                          ? Icon(
                                              item['icon'] as IconData,
                                              color: item['color'] as Color,
                                              size: 20,
                                            )
                                          : null,
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Información del item
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['titulo'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: item['isGasto'] && item['pagado'] == true ? Theme.of(context).textTheme.bodySmall?.color : Theme.of(context).textTheme.bodyLarge?.color,
                                              decoration: item['isGasto'] && item['pagado'] == true ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['subtitulo'] as String,
                                            style: TextStyle(
                                              color: item['isGasto'] && item['pagado'] == true ? Colors.green : Theme.of(context).textTheme.bodySmall?.color,
                                              fontSize: 14,
                                              fontWeight: item['isGasto'] && item['pagado'] == true ? FontWeight.w500 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Monto
                                    Text(
                                      item['monto'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: item['montoColor'] as Color,
                                        fontSize: 16,
                                        decoration: item['isGasto'] && item['pagado'] == true ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Botón "Ver todas las transacciones"
                        if (listaDeTransacciones.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: TextButton(
                              onPressed: () {
                                // Aquí podrías navegar a una pantalla de todas las transacciones
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funcionalidad de ver todas las transacciones próximamente'),
                                    backgroundColor: Color(0xFF2EA198),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ver todas las transacciones',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        backgroundColor: Theme.of(context).cardColor,
        currentIndex: 2, // Home seleccionado
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Tarjetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Espacios',
          ),
        ],
      ),
    );
  }
}

// Pantalla de Configuración
class ConfiguracionScreen extends StatefulWidget {
  final double ingresoMensual;
  final List<Gasto> listaDeGastos;
  final List<Categoria> listaDeCategorias;
  final List<TransaccionRecurrente> listaDeTransaccionesRecurrentes;
  final Function(double, List<Gasto>, List<TransaccionRecurrente>) onDatosActualizados;

  const ConfiguracionScreen({
    super.key,
    required this.ingresoMensual,
    required this.listaDeGastos,
    required this.listaDeCategorias,
    required this.listaDeTransaccionesRecurrentes,
    required this.onDatosActualizados,
  });

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late double ingresoMensual;
  late List<Gasto> listaDeGastos;
  late List<TransaccionRecurrente> listaDeTransaccionesRecurrentes;
  final TextEditingController _ingresoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ingresoMensual = widget.ingresoMensual;
    listaDeGastos = List.from(widget.listaDeGastos);
    listaDeTransaccionesRecurrentes = List.from(widget.listaDeTransaccionesRecurrentes);
    _ingresoController.text = ingresoMensual.toString();
  }

  @override
  void dispose() {
    _ingresoController.dispose();
    super.dispose();
  }

  void _guardarIngreso() {
    final nuevoIngreso = double.tryParse(_ingresoController.text) ?? 0.0;
    if (nuevoIngreso > 0) {
      setState(() {
        ingresoMensual = nuevoIngreso;
      });
      widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingreso mensual actualizado'),
          backgroundColor: Color(0xFF2EA198),
        ),
      );
    }
  }

  void _eliminarGasto(Gasto gasto) {
    setState(() {
      listaDeGastos.removeWhere((g) => g.id == gasto.id);
    });
    widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
  }

  void _mostrarFormularioGasto({Gasto? gasto}) {
    // Si es un gasto existente, mostrar el formulario simple para edición
    if (gasto != null) {
      showDialog(
        context: context,
        builder: (context) => FormularioGastoScreen(
          gasto: gasto,
          listaDeCategorias: widget.listaDeCategorias,
          onGastoGuardado: (nuevoGasto) {
            setState(() {
              // Editar gasto existente
              final index = listaDeGastos.indexWhere((g) => g.id == gasto.id);
              if (index != -1) {
                listaDeGastos[index] = nuevoGasto;
              }
            });
            widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
          },
        ),
      );
    } else {
      // Para nuevos gastos, usar el formulario específico para gastos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FormularioGastoFijoScreen(
            listaDeCategorias: widget.listaDeCategorias,
            onTransaccionGuardada: (nuevaTransaccion) {
              // Convertir TransaccionRecurrente a Gasto para compatibilidad
              final nuevoGasto = Gasto.nuevo(
                nombre: nuevaTransaccion.descripcion,
                monto: nuevaTransaccion.monto,
                diaDePago: nuevaTransaccion.fechaInicio.day,
                esRecurrente: true,
                categoriaId: nuevaTransaccion.categoriaId,
              );
              
              setState(() {
                listaDeGastos.add(nuevoGasto);
                listaDeTransaccionesRecurrentes.add(nuevaTransaccion);
              });
              widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gasto fijo programado exitosamente'),
                  backgroundColor: Color(0xFF2EA198),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mi Dinero'),
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección 1: Ingreso Mensual
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingreso Mensual',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingreso actual: ${currencyFormat.format(ingresoMensual)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    NumericTextField(
                      controller: _ingresoController,
                      labelText: 'Nuevo ingreso mensual',
                      prefixText: '\$ ',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardarIngreso,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2EA198),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Guardar Ingreso'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección 2: Gastos Fijos
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gastos Fijos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${listaDeGastos.length} gastos',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (listaDeGastos.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No hay gastos configurados.\nToca el botón + para añadir uno.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listaDeGastos.length,
                        itemBuilder: (context, index) {
                          final gasto = listaDeGastos[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gasto.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${currencyFormat.format(gasto.monto)} - Día ${gasto.diaDePago}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (!gasto.esRecurrente && gasto.fechaVencimiento != null)
                                        Text(
                                          'Vence: ${DateFormat('dd/MM/yyyy').format(gasto.fechaVencimiento!)}',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _mostrarFormularioGasto(gasto: gasto),
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () => _eliminarGasto(gasto),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección 3: Ingresos Fijos
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ingresos Fijos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${listaDeTransaccionesRecurrentes.where((t) => t.tipo == 'ingreso').length} ingresos',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (listaDeTransaccionesRecurrentes.where((t) => t.tipo == 'ingreso').isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No hay ingresos fijos configurados.\nToca el botón + para añadir uno.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listaDeTransaccionesRecurrentes.where((t) => t.tipo == 'ingreso').length,
                        itemBuilder: (context, index) {
                          final transaccion = listaDeTransaccionesRecurrentes.where((t) => t.tipo == 'ingreso').toList()[index];
                          final categoria = widget.listaDeCategorias.firstWhere(
                            (cat) => cat.id == transaccion.categoriaId,
                            orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'ingreso', icono: Icons.help.codePoint),
                          );
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaccion.descripcion,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${currencyFormat.format(transaccion.monto)} - ${_getFrecuenciaText(transaccion.frecuencia)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Inicia: ${DateFormat('dd/MM/yyyy').format(transaccion.fechaInicio)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (transaccion.condicionFin != 'nunca')
                                        Text(
                                          'Hasta: ${_getCondicionFinText(transaccion.condicionFin, transaccion.valorFin)}',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Switch(
                                      value: transaccion.activa,
                                      onChanged: (value) {
                                        setState(() {
                                          transaccion.activa = value;
                                        });
                                        widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
                                      },
                                      activeColor: Colors.green,
                                    ),
                                    IconButton(
                                      onPressed: () => _eliminarTransaccionRecurrente(transaccion),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalSeleccionTipo,
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarModalSeleccionTipo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle del modal
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              Text(
                'Agregar Nuevo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              
              // Opción de Gasto Fijo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2EA198).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Color(0xFF2EA198),
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Gasto Fijo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Programar un gasto recurrente'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioGasto();
                },
              ),
              
              // Opción de Ingreso Fijo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Ingreso Fijo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Programar un ingreso recurrente'),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarFormularioIngresoFijo();
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _mostrarFormularioIngresoFijo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioIngresoFijoScreen(
          listaDeCategorias: widget.listaDeCategorias,
          onTransaccionGuardada: (nuevaTransaccion) {
            setState(() {
              listaDeTransaccionesRecurrentes.add(nuevaTransaccion);
            });
            widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ingreso fijo programado exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  void _eliminarTransaccionRecurrente(TransaccionRecurrente transaccion) {
    setState(() {
      listaDeTransaccionesRecurrentes.removeWhere((t) => t.id == transaccion.id);
    });
    widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
  }

  String _getFrecuenciaText(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return 'Cada semana';
      case 'mensual':
        return 'Cada mes';
      case 'anual':
        return 'Cada año';
      default:
        return 'Cada mes';
    }
  }

  String _getCondicionFinText(String condicion, dynamic valorFin) {
    switch (condicion) {
      case 'nunca':
        return 'Nunca';
      case 'numero_pagos':
        return '$valorFin pagos';
      case 'fecha_especifica':
        return DateFormat('dd/MM/yyyy').format(valorFin as DateTime);
      default:
        return 'Nunca';
    }
  }
}

// Formulario específico para Gastos Fijos
class FormularioGastoFijoScreen extends StatefulWidget {
  final List<Categoria> listaDeCategorias;
  final Function(TransaccionRecurrente) onTransaccionGuardada;

  const FormularioGastoFijoScreen({
    super.key,
    required this.listaDeCategorias,
    required this.onTransaccionGuardada,
  });

  @override
  State<FormularioGastoFijoScreen> createState() => _FormularioGastoFijoScreenState();
}

class _FormularioGastoFijoScreenState extends State<FormularioGastoFijoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroPagosController = TextEditingController();
  
  bool _activa = true;
  DateTime _fechaInicio = DateTime.now();
  String _frecuencia = 'mensual';
  String _condicionFin = 'nunca';
  DateTime? _fechaFin;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _montoController.text = '1';
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _numeroPagosController.dispose();
    super.dispose();
  }

  void _guardarGastoFijo() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _categoriaSeleccionada!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar campos condicionales
      if (_condicionFin == 'numero_pagos' && _numeroPagosController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa el número de pagos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_condicionFin == 'fecha_especifica' && _fechaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona la fecha de finalización'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Preparar valorFin
      dynamic valorFin;
      if (_condicionFin == 'numero_pagos') {
        valorFin = int.parse(_numeroPagosController.text);
      } else if (_condicionFin == 'fecha_especifica') {
        valorFin = _fechaFin;
      }

      // Crear nueva transacción recurrente de gasto
      final nuevaTransaccion = TransaccionRecurrente.nueva(
        descripcion: _descripcionController.text,
        monto: double.parse(_montoController.text),
        tipo: 'gasto',
        fechaInicio: _fechaInicio,
        frecuencia: _frecuencia,
        condicionFin: _condicionFin,
        valorFin: valorFin,
        categoriaId: _categoriaSeleccionada!,
      );

      // Actualizar el estado activo
      nuevaTransaccion.activa = _activa;

      widget.onTransaccionGuardada(nuevaTransaccion);
      Navigator.of(context).pop();
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _fechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Programar Gasto Fijo'),
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Texto introductorio
            Text(
              'Configura un gasto fijo que se repita automáticamente según el horario definido.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // Switch de activación
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Gasto Automático',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Switch(
                  value: _activa,
                  onChanged: (value) {
                    setState(() {
                      _activa = value;
                    });
                  },
                  activeColor: const Color(0xFF2EA198),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de monto
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto del Gasto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el monto';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Por favor ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Gasto',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Fecha de inicio
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Fecha de Inicio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(DateFormat('dd MMM yyyy', 'es').format(_fechaInicio)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: _seleccionarFechaInicio,
              ),
            ),
            const SizedBox(height: 20),

            // Frecuencia
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Repetir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getFrecuenciaText(_frecuencia)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Frecuencia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFrecuenciaOption('semanal', 'Cada semana'),
                          _buildFrecuenciaOption('mensual', 'Cada mes'),
                          _buildFrecuenciaOption('anual', 'Cada año'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Condición de finalización
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.schedule,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Hasta',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getCondicionFinText(_condicionFin)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Condición de Finalización',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCondicionFinOption('nunca', 'Nunca'),
                          _buildCondicionFinOption('numero_pagos', 'Número de pagos'),
                          _buildCondicionFinOption('fecha_especifica', 'Fecha específica'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Campo condicional para número de pagos
            if (_condicionFin == 'numero_pagos') ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _numeroPagosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repetir por',
                  suffixText: 'pagos',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de pagos';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
            ],

            // Campo condicional para fecha específica
            if (_condicionFin == 'fecha_especifica') ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF2EA198),
                  ),
                  title: const Text(
                    'Fecha de Finalización',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(_fechaFin != null 
                    ? DateFormat('dd MMM yyyy', 'es').format(_fechaFin!)
                    : 'Seleccionar fecha'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  onTap: _seleccionarFechaFin,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Categoría (solo gastos)
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: widget.listaDeCategorias.where((cat) => cat.tipo == 'gasto').map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                        size: 20,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(categoria.nombre),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarGastoFijo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA198),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Programar Gasto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrecuenciaOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _frecuencia == value ? const Icon(Icons.check, color: Color(0xFF2EA198)) : null,
      onTap: () {
        setState(() {
          _frecuencia = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCondicionFinOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _condicionFin == value ? const Icon(Icons.check, color: Color(0xFF2EA198)) : null,
      onTap: () {
        setState(() {
          _condicionFin = value;
          if (value == 'numero_pagos') {
            _fechaFin = null;
          } else if (value == 'fecha_especifica') {
            _numeroPagosController.clear();
          } else {
            _fechaFin = null;
            _numeroPagosController.clear();
          }
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFrecuenciaText(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return 'Cada semana';
      case 'mensual':
        return 'Cada mes';
      case 'anual':
        return 'Cada año';
      default:
        return 'Cada mes';
    }
  }

  String _getCondicionFinText(String condicion) {
    switch (condicion) {
      case 'nunca':
        return 'Nunca';
      case 'numero_pagos':
        return 'Número de pagos';
      case 'fecha_especifica':
        return 'Fecha específica';
      default:
        return 'Nunca';
    }
  }
}

// Formulario específico para Ingresos Fijos
class FormularioIngresoFijoScreen extends StatefulWidget {
  final List<Categoria> listaDeCategorias;
  final Function(TransaccionRecurrente) onTransaccionGuardada;

  const FormularioIngresoFijoScreen({
    super.key,
    required this.listaDeCategorias,
    required this.onTransaccionGuardada,
  });

  @override
  State<FormularioIngresoFijoScreen> createState() => _FormularioIngresoFijoScreenState();
}

class _FormularioIngresoFijoScreenState extends State<FormularioIngresoFijoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroPagosController = TextEditingController();
  
  bool _activa = true;
  DateTime _fechaInicio = DateTime.now();
  String _frecuencia = 'mensual';
  String _condicionFin = 'nunca';
  DateTime? _fechaFin;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _montoController.text = '1';
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _numeroPagosController.dispose();
    super.dispose();
  }

  void _guardarIngresoFijo() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _categoriaSeleccionada!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar campos condicionales
      if (_condicionFin == 'numero_pagos' && _numeroPagosController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa el número de pagos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_condicionFin == 'fecha_especifica' && _fechaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona la fecha de finalización'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Preparar valorFin
      dynamic valorFin;
      if (_condicionFin == 'numero_pagos') {
        valorFin = int.parse(_numeroPagosController.text);
      } else if (_condicionFin == 'fecha_especifica') {
        valorFin = _fechaFin;
      }

      // Crear nueva transacción recurrente de ingreso
      final nuevaTransaccion = TransaccionRecurrente.nueva(
        descripcion: _descripcionController.text,
        monto: double.parse(_montoController.text),
        tipo: 'ingreso',
        fechaInicio: _fechaInicio,
        frecuencia: _frecuencia,
        condicionFin: _condicionFin,
        valorFin: valorFin,
        categoriaId: _categoriaSeleccionada!,
      );

      // Actualizar el estado activo
      nuevaTransaccion.activa = _activa;

      widget.onTransaccionGuardada(nuevaTransaccion);
      Navigator.of(context).pop();
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _fechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Programar Ingreso Fijo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Texto introductorio
            const Text(
              'Configura un ingreso fijo que se repita automáticamente según el horario definido.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // Switch de activación
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Colors.green,
                ),
                title: const Text(
                  'Ingreso Automático',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Switch(
                  value: _activa,
                  onChanged: (value) {
                    setState(() {
                      _activa = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de monto
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto del Ingreso',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el monto';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Por favor ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Ingreso',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Fecha de inicio
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Colors.green,
                ),
                title: const Text(
                  'Fecha de Inicio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(DateFormat('dd MMM yyyy', 'es').format(_fechaInicio)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: _seleccionarFechaInicio,
              ),
            ),
            const SizedBox(height: 20),

            // Frecuencia
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Colors.green,
                ),
                title: const Text(
                  'Repetir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getFrecuenciaText(_frecuencia)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Frecuencia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFrecuenciaOption('semanal', 'Cada semana'),
                          _buildFrecuenciaOption('mensual', 'Cada mes'),
                          _buildFrecuenciaOption('anual', 'Cada año'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Condición de finalización
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.schedule,
                  color: Colors.green,
                ),
                title: const Text(
                  'Hasta',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getCondicionFinText(_condicionFin)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Condición de Finalización',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCondicionFinOption('nunca', 'Nunca'),
                          _buildCondicionFinOption('numero_pagos', 'Número de pagos'),
                          _buildCondicionFinOption('fecha_especifica', 'Fecha específica'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Campo condicional para número de pagos
            if (_condicionFin == 'numero_pagos') ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _numeroPagosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repetir por',
                  suffixText: 'pagos',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de pagos';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
            ],

            // Campo condicional para fecha específica
            if (_condicionFin == 'fecha_especifica') ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Fecha de Finalización',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(_fechaFin != null 
                    ? DateFormat('dd MMM yyyy', 'es').format(_fechaFin!)
                    : 'Seleccionar fecha'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  onTap: _seleccionarFechaFin,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Categoría (solo ingresos)
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: widget.listaDeCategorias.where((cat) => cat.tipo == 'ingreso').map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                        size: 20,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(categoria.nombre),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarIngresoFijo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Programar Ingreso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrecuenciaOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _frecuencia == value ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() {
          _frecuencia = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCondicionFinOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _condicionFin == value ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() {
          _condicionFin = value;
          if (value == 'numero_pagos') {
            _fechaFin = null;
          } else if (value == 'fecha_especifica') {
            _numeroPagosController.clear();
          } else {
            _fechaFin = null;
            _numeroPagosController.clear();
          }
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFrecuenciaText(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return 'Cada semana';
      case 'mensual':
        return 'Cada mes';
      case 'anual':
        return 'Cada año';
      default:
        return 'Cada mes';
    }
  }

  String _getCondicionFinText(String condicion) {
    switch (condicion) {
      case 'nunca':
        return 'Nunca';
      case 'numero_pagos':
        return 'Número de pagos';
      case 'fecha_especifica':
        return 'Fecha específica';
      default:
        return 'Nunca';
    }
  }
}

// Formulario para añadir/editar gastos
class FormularioGastoScreen extends StatefulWidget {
  final Gasto? gasto;
  final List<Categoria> listaDeCategorias;
  final Function(Gasto) onGastoGuardado;

  const FormularioGastoScreen({
    super.key,
    this.gasto,
    required this.listaDeCategorias,
    required this.onGastoGuardado,
  });

  @override
  State<FormularioGastoScreen> createState() => _FormularioGastoScreenState();
}

class _FormularioGastoScreenState extends State<FormularioGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  final _diaController = TextEditingController();
  bool _esRecurrente = true;
  DateTime? _fechaVencimiento;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    if (widget.gasto != null) {
      _nombreController.text = widget.gasto!.nombre;
      _montoController.text = widget.gasto!.monto.toString();
      _diaController.text = widget.gasto!.diaDePago.toString();
      _esRecurrente = widget.gasto!.esRecurrente;
      _fechaVencimiento = widget.gasto!.fechaVencimiento;
      _categoriaSeleccionada = widget.gasto!.categoriaId;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _montoController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  void _guardarGasto() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _categoriaSeleccionada!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final gasto = widget.gasto != null
          ? Gasto(
              id: widget.gasto!.id,
              nombre: _nombreController.text,
              monto: double.parse(_montoController.text),
              diaDePago: int.parse(_diaController.text),
              pagado: widget.gasto!.pagado,
              esRecurrente: _esRecurrente,
              fechaVencimiento: _fechaVencimiento,
              categoriaId: _categoriaSeleccionada!,
            )
          : Gasto.nuevo(
              nombre: _nombreController.text,
              monto: double.parse(_montoController.text),
              diaDePago: int.parse(_diaController.text),
              esRecurrente: _esRecurrente,
              fechaVencimiento: _fechaVencimiento,
              categoriaId: _categoriaSeleccionada!,
            );

      widget.onGastoGuardado(gasto);
      Navigator.of(context).pop();
    }
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaVencimiento = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gasto != null ? 'Editar Gasto' : 'Nuevo Gasto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del gasto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del gasto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NumericTextField(
                controller: _montoController,
                labelText: 'Monto',
                prefixText: '\$ ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Por favor ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              NumericTextField(
                controller: _diaController,
                labelText: 'Día de pago (1-31)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el día de pago';
                  }
                  final dia = int.tryParse(value);
                  if (dia == null || dia < 1 || dia > 31) {
                    return 'Por favor ingresa un día válido (1-31)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: widget.listaDeCategorias.where((cat) => cat.tipo == 'gasto').map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria.id,
                    child: Row(
                      children: [
                        Icon(
                          IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                          size: 20,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(categoria.nombre),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Gasto recurrente'),
                subtitle: const Text('Se repite cada mes'),
                value: _esRecurrente,
                onChanged: (value) {
                  setState(() {
                    _esRecurrente = value;
                    if (value) {
                      _fechaVencimiento = null;
                    }
                  });
                },
              ),
              if (!_esRecurrente) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha de vencimiento'),
                  subtitle: Text(_fechaVencimiento != null
                      ? DateFormat('dd/MM/yyyy').format(_fechaVencimiento!)
                      : 'Seleccionar fecha'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _seleccionarFecha,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardarGasto,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EA198),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.gasto != null ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}

// Widget de teclado numérico personalizado
class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onDone;

  const NumericKeyboard({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1: 1, 2, 3
          Row(
            children: [
              _buildKey(context, '1'),
              _buildKey(context, '2'),
              _buildKey(context, '3'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 2: 4, 5, 6
          Row(
            children: [
              _buildKey(context, '4'),
              _buildKey(context, '5'),
              _buildKey(context, '6'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 3: 7, 8, 9
          Row(
            children: [
              _buildKey(context, '7'),
              _buildKey(context, '8'),
              _buildKey(context, '9'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 4: ., 0, backspace
          Row(
            children: [
              _buildKey(context, '.'),
              _buildKey(context, '0'),
              _buildActionKey(
                context,
                icon: Icons.backspace,
                onPressed: onBackspace,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 5: Botón Done
          if (onDone != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA198),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Listo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onKeyPressed(value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla de Gestión de Categorías
class CategoriasScreen extends StatefulWidget {
  final List<Categoria> listaDeCategorias;
  final Function(List<Categoria>) onCategoriasActualizadas;

  const CategoriasScreen({
    super.key,
    required this.listaDeCategorias,
    required this.onCategoriasActualizadas,
  });

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  late List<Categoria> listaDeCategorias;

  @override
  void initState() {
    super.initState();
    listaDeCategorias = List.from(widget.listaDeCategorias);
  }

  void _eliminarCategoria(Categoria categoria) {
    setState(() {
      listaDeCategorias.removeWhere((c) => c.id == categoria.id);
    });
    widget.onCategoriasActualizadas(listaDeCategorias);
  }

  void _mostrarFormularioCategoria({Categoria? categoria}) {
    showDialog(
      context: context,
      builder: (context) => FormularioCategoriaScreen(
        categoria: categoria,
        onCategoriaGuardada: (nuevaCategoria) {
          setState(() {
            if (categoria != null) {
              // Editar categoría existente
              final index = listaDeCategorias.indexWhere((c) => c.id == categoria.id);
              if (index != -1) {
                listaDeCategorias[index] = nuevaCategoria;
              }
            } else {
              // Añadir nueva categoría
              listaDeCategorias.add(nuevaCategoria);
            }
          });
          widget.onCategoriasActualizadas(listaDeCategorias);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasIngresos = listaDeCategorias.where((cat) => cat.tipo == 'ingreso').toList();
    final categoriasGastos = listaDeCategorias.where((cat) => cat.tipo == 'gasto').toList();
    final categoriasAhorro = listaDeCategorias.where((cat) => cat.tipo == 'ahorro').toList();
    final categoriasInversion = listaDeCategorias.where((cat) => cat.tipo == 'inversion').toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categorías de Ingresos
            _buildCategoriaSection(
              'Categorías de Ingresos',
              categoriasIngresos,
              Colors.green,
              Icons.arrow_downward,
            ),
            
            const SizedBox(height: 24),
            
            // Categorías de Gastos
            _buildCategoriaSection(
              'Categorías de Gastos',
              categoriasGastos,
              Colors.red,
              Icons.arrow_upward,
            ),
            
            const SizedBox(height: 24),
            
            // Categorías de Ahorro
            _buildCategoriaSection(
              'Categorías de Ahorro',
              categoriasAhorro,
              Colors.blue,
              Icons.savings,
            ),
            
            const SizedBox(height: 24),
            
            // Categorías de Inversión
            _buildCategoriaSection(
              'Categorías de Inversión',
              categoriasInversion,
              Colors.orange,
              Icons.trending_up,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCategoria(),
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoriaSection(String titulo, List<Categoria> categorias, MaterialColor color, IconData icono) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categorias.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No hay categorías de ${titulo.toLowerCase()}.\nToca el botón + para añadir una.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                          color: color[600],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            categoria.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _mostrarFormularioCategoria(categoria: categoria),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _eliminarCategoria(categoria),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Formulario para añadir/editar categorías
class FormularioCategoriaScreen extends StatefulWidget {
  final Categoria? categoria;
  final Function(Categoria) onCategoriaGuardada;

  const FormularioCategoriaScreen({
    super.key,
    this.categoria,
    required this.onCategoriaGuardada,
  });

  @override
  State<FormularioCategoriaScreen> createState() => _FormularioCategoriaScreenState();
}

class _FormularioCategoriaScreenState extends State<FormularioCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  String _tipoSeleccionado = 'gasto';
  int _iconoSeleccionado = Icons.category.codePoint;

  // Lista de íconos disponibles
  final List<IconData> _iconosDisponibles = [
    Icons.category,
    Icons.home,
    Icons.directions_car,
    Icons.restaurant,
    Icons.medical_services,
    Icons.movie,
    Icons.school,
    Icons.credit_card,
    Icons.work,
    Icons.card_giftcard,
    Icons.sell,
    Icons.attach_money,
    Icons.shopping_cart,
    Icons.sports,
    Icons.travel_explore,
    Icons.pets,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nombreController.text = widget.categoria!.nombre;
      _tipoSeleccionado = widget.categoria!.tipo;
      _iconoSeleccionado = widget.categoria!.icono;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardarCategoria() {
    if (_formKey.currentState!.validate()) {
      final categoria = widget.categoria != null
          ? Categoria(
              id: widget.categoria!.id,
              nombre: _nombreController.text,
              tipo: _tipoSeleccionado,
              icono: _iconoSeleccionado,
            )
          : Categoria.nueva(
              nombre: _nombreController.text,
              tipo: _tipoSeleccionado,
              icono: _iconoSeleccionado,
            );

      widget.onCategoriaGuardada(categoria);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoria != null ? 'Editar Categoría' : 'Nueva Categoría'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                  DropdownMenuItem(value: 'inversion', child: Text('Inversión')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _tipoSeleccionado = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Seleccionar ícono:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iconosDisponibles.map((icono) {
                      final isSelected = icono.codePoint == _iconoSeleccionado;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _iconoSeleccionado = icono.codePoint;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2EA198) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2EA198) : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icono,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardarCategoria,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EA198),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.categoria != null ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}

// Widget de campo de texto con teclado numérico personalizado
class NumericTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? prefixText;
  final String? Function(String?)? validator;
  final bool enabled;

  const NumericTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixText,
    this.validator,
    this.enabled = true,
  });

  @override
  State<NumericTextField> createState() => _NumericTextFieldState();
}

class _NumericTextFieldState extends State<NumericTextField> {
  bool _showKeyboard = false;

  void _toggleKeyboard() {
    setState(() {
      _showKeyboard = !_showKeyboard;
    });
  }

  void _onKeyPressed(String value) {
    if (value == '.') {
      // Solo permitir un punto decimal
      if (!widget.controller.text.contains('.')) {
        widget.controller.text += value;
      }
    } else {
      widget.controller.text += value;
    }
  }

  void _onBackspace() {
    if (widget.controller.text.isNotEmpty) {
      widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          readOnly: true, // Hacer el campo de solo lectura para usar nuestro teclado
          onTap: _toggleKeyboard,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixText: widget.prefixText,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_showKeyboard ? Icons.keyboard_hide : Icons.keyboard),
              onPressed: _toggleKeyboard,
            ),
          ),
          validator: widget.validator,
        ),
        if (_showKeyboard)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: NumericKeyboard(
              onKeyPressed: _onKeyPressed,
              onBackspace: _onBackspace,
              onDone: () {
                setState(() {
                  _showKeyboard = false;
                });
              },
            ),
          ),
      ],
    );
  }
}

// Pantalla del Formulario de Transacciones Recurrentes
class FormularioRecurrenteScreen extends StatefulWidget {
  final List<Categoria> listaDeCategorias;
  final Function(TransaccionRecurrente) onTransaccionGuardada;

  const FormularioRecurrenteScreen({
    super.key,
    required this.listaDeCategorias,
    required this.onTransaccionGuardada,
  });

  @override
  State<FormularioRecurrenteScreen> createState() => _FormularioRecurrenteScreenState();
}

class _FormularioRecurrenteScreenState extends State<FormularioRecurrenteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numeroPagosController = TextEditingController();
  
  bool _activa = true;
  DateTime _fechaInicio = DateTime.now();
  String _frecuencia = 'mensual';
  String _condicionFin = 'nunca';
  DateTime? _fechaFin;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _montoController.text = '1';
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _numeroPagosController.dispose();
    super.dispose();
  }

  void _guardarTransaccion() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSeleccionada == null || _categoriaSeleccionada!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validar campos condicionales
      if (_condicionFin == 'numero_pagos' && _numeroPagosController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor ingresa el número de pagos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_condicionFin == 'fecha_especifica' && _fechaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona la fecha de finalización'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Determinar el tipo basado en la categoría seleccionada
      final categoria = widget.listaDeCategorias.firstWhere((cat) => cat.id == _categoriaSeleccionada);
      final tipo = categoria.tipo;

      // Preparar valorFin
      dynamic valorFin;
      if (_condicionFin == 'numero_pagos') {
        valorFin = int.parse(_numeroPagosController.text);
      } else if (_condicionFin == 'fecha_especifica') {
        valorFin = _fechaFin;
      }

      // Crear nueva transacción recurrente
      final nuevaTransaccion = TransaccionRecurrente.nueva(
        descripcion: _descripcionController.text,
        monto: double.parse(_montoController.text),
        tipo: tipo,
        fechaInicio: _fechaInicio,
        frecuencia: _frecuencia,
        condicionFin: _condicionFin,
        valorFin: valorFin,
        categoriaId: _categoriaSeleccionada!,
      );

      // Actualizar el estado activo
      nuevaTransaccion.activa = _activa;

      widget.onTransaccionGuardada(nuevaTransaccion);
      Navigator.of(context).pop();
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaInicio = fecha;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _fechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        _fechaFin = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Programar Transferencia'),
        backgroundColor: const Color(0xFF2EA198),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Texto introductorio
            const Text(
              'Configura una transferencia automática en un horario definido.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),

            // Switch de activación
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Transferencia Automática',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Switch(
                  value: _activa,
                  onChanged: (value) {
                    setState(() {
                      _activa = value;
                    });
                  },
                  activeColor: const Color(0xFF2EA198),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tipo de transferencia
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.swap_horiz,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Tipo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text('Monto fijo'),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de monto
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Transferir',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el monto';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Por favor ingresa un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Fecha de inicio
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Fecha de Inicio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(DateFormat('dd MMM yyyy', 'es').format(_fechaInicio)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: _seleccionarFechaInicio,
              ),
            ),
            const SizedBox(height: 20),

            // Frecuencia
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Repetir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getFrecuenciaText(_frecuencia)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Frecuencia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFrecuenciaOption('semanal', 'Cada semana'),
                          _buildFrecuenciaOption('mensual', 'Cada mes'),
                          _buildFrecuenciaOption('anual', 'Cada año'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Condición de finalización
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.schedule,
                  color: Color(0xFF2EA198),
                ),
                title: const Text(
                  'Hasta',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(_getCondicionFinText(_condicionFin)),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Seleccionar Condición de Finalización',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCondicionFinOption('nunca', 'Nunca'),
                          _buildCondicionFinOption('numero_pagos', 'Número de pagos'),
                          _buildCondicionFinOption('fecha_especifica', 'Fecha específica'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Campo condicional para número de pagos
            if (_condicionFin == 'numero_pagos') ...[
              const SizedBox(height: 20),
              TextFormField(
                controller: _numeroPagosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repetir por',
                  suffixText: 'pagos',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el número de pagos';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
            ],

            // Campo condicional para fecha específica
            if (_condicionFin == 'fecha_especifica') ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF2EA198),
                  ),
                  title: const Text(
                    'Fecha de Finalización',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(_fechaFin != null 
                    ? DateFormat('dd MMM yyyy', 'es').format(_fechaFin!)
                    : 'Seleccionar fecha'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  onTap: _seleccionarFechaFin,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Categoría
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: widget.listaDeCategorias.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria.id,
                  child: Row(
                    children: [
                      Icon(
                        IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                        size: 20,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(categoria.nombre),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una categoría';
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarTransaccion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EA198),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrecuenciaOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _frecuencia == value ? const Icon(Icons.check, color: Color(0xFF2EA198)) : null,
      onTap: () {
        setState(() {
          _frecuencia = value;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCondicionFinOption(String value, String text) {
    return ListTile(
      title: Text(text),
      trailing: _condicionFin == value ? const Icon(Icons.check, color: Color(0xFF2EA198)) : null,
      onTap: () {
        setState(() {
          _condicionFin = value;
          if (value == 'numero_pagos') {
            _fechaFin = null;
          } else if (value == 'fecha_especifica') {
            _numeroPagosController.clear();
          } else {
            _fechaFin = null;
            _numeroPagosController.clear();
          }
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFrecuenciaText(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return 'Cada semana';
      case 'mensual':
        return 'Cada mes';
      case 'anual':
        return 'Cada año';
      default:
        return 'Cada mes';
    }
  }

  String _getCondicionFinText(String condicion) {
    switch (condicion) {
      case 'nunca':
        return 'Nunca';
      case 'numero_pagos':
        return 'Número de pagos';
      case 'fecha_especifica':
        return 'Fecha específica';
      default:
        return 'Nunca';
    }
  }
}
