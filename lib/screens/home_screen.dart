import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../utils/formatters.dart';
import '../models/categoria_model.dart';
import '../models/transaccion_model.dart';
import '../models/transaccion_recurrente_model.dart';
import '../models/gasto_model.dart';
import '../widgets/transaction_list_item.dart';
import 'theme_selector_screen.dart';

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
        .toList() // Asegurarse de que es una lista mutable
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
        'transaccion': transaccion,
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
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    
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
                transaccion.descripcion,
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
                'Frecuencia: ${getFrecuenciaText(transaccion.frecuencia)}',
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
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    
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
                transaccion.descripcion,
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
                'Frecuencia: ${getFrecuenciaText(transaccion.frecuencia)}',
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
    final messenger = ScaffoldMessenger.of(context);
    await _guardarDatos();
    
    // 5. Marcar como procesado para no volver a mostrar hoy
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(clave, true);
    
    // 6. Mostrar confirmación
    messenger.showSnackBar(
      SnackBar(
        content: Text('Ingreso de ${NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0).format(transaccion.monto)} registrado'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
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
    final messenger = ScaffoldMessenger.of(context);
    await _guardarDatos();
    
    // 5. Marcar como procesado para no volver a mostrar hoy
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(clave, true);
    
    // 6. Mostrar confirmación
    messenger.showSnackBar(
      SnackBar(
        content: Text('Gasto de ${NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0).format(transaccion.monto)} registrado'),
        backgroundColor: const Color(0xFF2EA198),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // 7. Actualizar UI
    setState(() {});
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
                    color: Colors.green.withValues(alpha: 0.1),
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
                    color: Colors.red.withValues(alpha: 0.1),
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
                    color: Colors.blue.withValues(alpha: 0.1),
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
                    color: Colors.orange.withValues(alpha: 0.1),
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
                    color: const Color(0xFF2EA198).withValues(alpha: 0.1),
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
            
            if (!mounted) return;
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
        return StatefulBuilder( // Usar StatefulBuilder para manejar el estado interno del diálogo
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: montoController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: r'$ ',
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
                        setStateDialog(() {
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
                        title: Text(tipo == 'ingreso' ? '¿Es un ingreso recurrente?' : '¿Es un gasto recurrente?'),
                        value: esRecurrente,
                        onChanged: (v) {
                          setStateDialog(() {
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
                                setStateDialog(() {
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
                            setStateDialog(() {
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
                            setStateDialog(() {
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
                                  setStateDialog(() {
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

                    final monto = parseMonto(montoController.text);
                    if (monto <= 0) {
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
                          } else { // gasto
                            saldoDisponible -= monto;
                          }
                        }
                      });

                      await _guardarDatos();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$titulo recurrente programado'),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else { // Crear nueva transacción simple
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
                        } else { // Para gasto, ahorro e inversión se resta del saldo
                          saldoDisponible -= monto;
                        }
                      });

                      // Guardar datos
                      await _guardarDatos();

                      // Mostrar confirmación
                      if (!mounted) return;
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
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white.withValues(alpha: 0.15),
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
                                  currencyFormat.format(0), // TODO: Implementar cálculo real
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
                              color: Colors.white.withValues(alpha: 0.15),
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
                                  currencyFormat.format(0), // TODO: Implementar cálculo real
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
                              } else if (item['isGasto'] == true) { // Si es un gasto fijo
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
                                          color: item['color']!.withValues(alpha: 0.1),
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
                              } else { // Si es una transacción variable
                                return TransactionListItem(
                                  transaction: item['transaccion'] as Transaccion,
                                  categorias: listaDeCategorias,
                                );
                              }
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
      )
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
      if (!mounted) return;
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
    } else { // Para nuevos gastos, usar el formulario específico para gastos
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
              });
              widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
            },
          ),
        ),
      );
    }
  }

  void _eliminarTransaccionRecurrente(TransaccionRecurrente transaccion) {
    setState(() {
      listaDeTransaccionesRecurrentes.removeWhere((t) => t.id == transaccion.id);
    });
    widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Dinero'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Ingreso Mensual
            Text(
              'Ingreso Mensual',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingresoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ingreso Mensual',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _guardarIngreso,
                  child: const Text('Guardar'),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Sección de Gastos Fijos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gastos Fijos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2EA198)),
                  onPressed: () => _mostrarFormularioGasto(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listaDeGastos.isEmpty)
              const Center(child: Text('No tienes gastos fijos configurados.')),
            ...listaDeGastos.map((gasto) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(gasto.nombre),
                subtitle: Text('Día de pago: ${gasto.diaDePago}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(formatoMoneda(gasto.monto)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: () => _mostrarFormularioGasto(gasto: gasto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _eliminarGasto(gasto),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 30),
            
            // Sección de Transacciones Recurrentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transacciones Recurrentes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2EA198)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormularioGastoFijoScreen(
                          listaDeCategorias: widget.listaDeCategorias,
                          onTransaccionGuardada: (nuevaTransaccion) {
                            setState(() {
                              listaDeTransaccionesRecurrentes.add(nuevaTransaccion);
                            });
                            widget.onDatosActualizados(ingresoMensual, listaDeGastos, listaDeTransaccionesRecurrentes);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listaDeTransaccionesRecurrentes.isEmpty)
              const Center(child: Text('No tienes transacciones recurrentes.')),
            ...listaDeTransaccionesRecurrentes.map((transaccion) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(transaccion.descripcion),
                subtitle: Text('${getFrecuenciaText(transaccion.frecuencia)} - Inicia: ${DateFormat('dd/MM/yy').format(transaccion.fechaInicio)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${transaccion.tipo == 'ingreso' ? '+' : '-'}${formatoMoneda(transaccion.monto)}',
                      style: TextStyle(
                        color: transaccion.tipo == 'ingreso' ? Colors.green : Colors.red,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _eliminarTransaccionRecurrente(transaccion),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Pantalla para formulario de Gasto Fijo (Transacción Recurrente)
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
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String _tipo = 'gasto';
  DateTime _fechaInicio = DateTime.now();
  String _frecuencia = 'mensual';
  String? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final categoriasFiltradas = widget.listaDeCategorias.where((c) => c.tipo == _tipo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto Fijo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                    _categoriaSeleccionada = null; // Resetear categoría
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: categoriasFiltradas.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.nombre));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Día de pago'),
                subtitle: Text(DateFormat('d \'de\' MMMM', 'es').format(_fechaInicio)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final nuevaFecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (nuevaFecha != null) {
                    setState(() {
                      _fechaInicio = nuevaFecha;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _frecuencia,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: const [
                  DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                  DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                  DropdownMenuItem(value: 'anual', child: Text('Anual')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frecuencia = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final nuevaTransaccion = TransaccionRecurrente.nueva(
                        descripcion: _descripcionController.text,
                        monto: double.parse(_montoController.text),
                        tipo: _tipo,
                        fechaInicio: _fechaInicio,
                        frecuencia: _frecuencia,
                        condicionFin: 'nunca', // Simplificado
                        valorFin: null,
                        categoriaId: _categoriaSeleccionada!,
                      );
                      widget.onTransaccionGuardada(nuevaTransaccion);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Guardar Gasto Fijo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla para formulario de Gasto (edición)
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
  late TextEditingController _nombreController;
  late TextEditingController _montoController;
  late int _diaDePago;
  late bool _esRecurrente;
  DateTime? _fechaVencimiento;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.gasto?.nombre ?? '');
    _montoController = TextEditingController(text: widget.gasto?.monto.toString() ?? '');
    _diaDePago = widget.gasto?.diaDePago ?? 1;
    _esRecurrente = widget.gasto?.esRecurrente ?? true;
    _fechaVencimiento = widget.gasto?.fechaVencimiento;
    _categoriaSeleccionada = widget.gasto?.categoriaId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriasDeGasto = widget.listaDeCategorias.where((c) => c.tipo == 'gasto').toList();

    return AlertDialog(
      title: Text(widget.gasto == null ? 'Nuevo Gasto' : 'Editar Gasto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
              ),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Ingresa un monto' : null,
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categoriasDeGasto.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.nombre));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
              ),
              SwitchListTile(
                title: const Text('Gasto recurrente (fijo)'),
                value: _esRecurrente,
                onChanged: (value) {
                  setState(() {
                    _esRecurrente = value;
                    if (value) {
                      _fechaVencimiento = null;
                    } else {
                      _diaDePago = DateTime.now().day;
                    }
                  });
                },
              ),
              if (_esRecurrente)
                TextFormField(
                  initialValue: _diaDePago.toString(),
                  decoration: const InputDecoration(labelText: 'Día de pago (1-31)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _diaDePago = int.tryParse(value) ?? 1;
                  },
                )
              else
                ListTile(
                  title: const Text('Fecha de vencimiento'),
                  subtitle: Text(_fechaVencimiento == null ? 'No establecida' : DateFormat('dd/MM/yyyy').format(_fechaVencimiento!)),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: _fechaVencimiento ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (fecha != null) {
                      setState(() {
                        _fechaVencimiento = fecha;
                      });
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final nuevoGasto = Gasto(
                id: widget.gasto?.id ?? const Uuid().v4(),
                nombre: _nombreController.text,
                monto: double.parse(_montoController.text),
                diaDePago: _diaDePago,
                pagado: widget.gasto?.pagado ?? false,
                esRecurrente: _esRecurrente,
                fechaVencimiento: _fechaVencimiento,
                categoriaId: _categoriaSeleccionada!,
              );
              widget.onGastoGuardado(nuevoGasto);
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Pantalla de Categorías
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
  late List<Categoria> _listaDeCategorias;

  @override
  void initState() {
    super.initState();
    _listaDeCategorias = List.from(widget.listaDeCategorias);
  }

  void _eliminarCategoria(Categoria categoria) {
    setState(() {
      _listaDeCategorias.removeWhere((c) => c.id == categoria.id);
    });
    widget.onCategoriasActualizadas(_listaDeCategorias);
  }

  void _mostrarFormularioCategoria({Categoria? categoria}) {
    showDialog(
      context: context,
      builder: (context) => FormularioCategoriaScreen(
        categoria: categoria,
        onCategoriaGuardada: (nuevaCategoria) {
          setState(() {
            if (categoria == null) {
              _listaDeCategorias.add(nuevaCategoria);
            } else {
              final index = _listaDeCategorias.indexWhere((c) => c.id == categoria.id);
              if (index != -1) {
                _listaDeCategorias[index] = nuevaCategoria;
              }
            }
          });
          widget.onCategoriasActualizadas(_listaDeCategorias);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Categorías'),
      ),
      body: ListView.builder(
        itemCount: _listaDeCategorias.length,
        itemBuilder: (context, index) {
          final categoria = _listaDeCategorias[index];
          return ListTile(
            leading: Icon(IconData(categoria.icono, fontFamily: 'MaterialIcons')),
            title: Text(categoria.nombre),
            subtitle: Text(categoria.tipo),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => _mostrarFormularioCategoria(categoria: categoria),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _eliminarCategoria(categoria),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioCategoria(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Pantalla para formulario de Categoría
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
  late TextEditingController _nombreController;
  String _tipo = 'gasto';
  int _icono = Icons.help.codePoint;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.categoria?.nombre ?? '');
    _tipo = widget.categoria?.tipo ?? 'gasto';
    _icono = widget.categoria?.icono ?? Icons.help.codePoint;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoria == null ? 'Nueva Categoría' : 'Editar Categoría'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Ingresa un nombre' : null,
              ),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                  DropdownMenuItem(value: 'inversion', child: Text('Inversión')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              // Selector de ícono (simplificado)
              ListTile(
                title: const Text('Ícono'),
                trailing: Icon(IconData(_icono, fontFamily: 'MaterialIcons')),
                onTap: () async {
                  // Aquí se podría abrir un selector de íconos más completo
                  // Por simplicidad, usamos un diálogo con algunos íconos de ejemplo
                  final nuevoIcono = await showDialog<int>(
                    context: context,
                    builder: (context) => IconSelectorDialog(),
                  );
                  if (nuevoIcono != null) {
                    setState(() {
                      _icono = nuevoIcono;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final nuevaCategoria = Categoria(
                id: widget.categoria?.id ?? const Uuid().v4(),
                nombre: _nombreController.text,
                tipo: _tipo,
                icono: _icono,
              );
              widget.onCategoriaGuardada(nuevaCategoria);
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Diálogo para seleccionar un ícono
class IconSelectorDialog extends StatelessWidget {
  final List<IconData> _iconos = [
    Icons.home, Icons.shopping_cart, Icons.receipt_long, Icons.directions_bus,
    Icons.wifi, Icons.payment, Icons.work, Icons.sell, Icons.attach_money,
    Icons.medical_services, Icons.movie, Icons.school, Icons.credit_card,
    Icons.emergency, Icons.savings, Icons.trending_up, Icons.currency_bitcoin,
  ];

  IconSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Ícono'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _iconos.length,
          itemBuilder: (context, index) {
            final icono = _iconos[index];
            return InkWell(
              onTap: () => Navigator.pop(context, icono.codePoint),
              child: Icon(icono, size: 30),
            );
          },
        ),
      ),
    );
  }
}

// Formulario para transacciones recurrentes (simplificado)
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
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String _tipo = 'gasto';
  DateTime _fechaInicio = DateTime.now();
  String _frecuencia = 'mensual';
  String? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final categoriasFiltradas = widget.listaDeCategorias.where((c) => c.tipo == _tipo).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programar Transferencia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Ingresa un monto' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                    _categoriaSeleccionada = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: categoriasFiltradas.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.nombre));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fecha de inicio'),
                subtitle: Text(DateFormat.yMMMMd('es').format(_fechaInicio)),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaInicio = fecha;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _frecuencia,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: const [
                  DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                  DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                  DropdownMenuItem(value: 'anual', child: Text('Anual')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frecuencia = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final nuevaTransaccion = TransaccionRecurrente.nueva(
                        descripcion: _descripcionController.text,
                        monto: double.parse(_montoController.text),
                        tipo: _tipo,
                        fechaInicio: _fechaInicio,
                        frecuencia: _frecuencia,
                        condicionFin: 'nunca', // Simplificado
                        valorFin: null,
                        categoriaId: _categoriaSeleccionada!,
                      );
                      widget.onTransaccionGuardada(nuevaTransaccion);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}