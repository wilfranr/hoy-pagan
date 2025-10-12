import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:kipu/src/shared/utils/formatters.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_recurrente_model.dart';
import 'package:kipu/src/features/transactions/data/models/gasto_model.dart';
import 'package:kipu/src/features/transactions/presentation/widgets/new_transaction_modal.dart';
import 'package:kipu/src/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:kipu/src/features/theme_selector/presentation/screens/theme_selector_screen.dart';
import 'package:kipu/src/features/user_profile/presentation/screens/registro_usuario_screen.dart';
import 'package:kipu/src/features/expense_dashboard/presentation/screens/expenses_report_screen.dart';
import 'package:kipu/widgets/kipu_confirmation_dialog.dart';

// Widget personalizado para botón 3D con efecto de profundidad
class Button3D extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const Button3D({
    super.key,
    required this.onPressed,
    required this.icon,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.blue,
    this.size = 56.0,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pressAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _borderRadiusAnimation = Tween<double>(
      begin: 28.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              children: [
                // Sombra base
                Positioned(
                  top: 3,
                  left: 0,
                  child: Container(
                    width: widget.size,
                    height: widget.size - 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                // Botón principal
                Positioned(
                  top: 0,
                  left: 0,
                  child: Transform.translate(
                    offset: Offset(0, _translateAnimation.value),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
                        color: widget.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.size * 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2; // 2 = Inicio

  // Variables del estado
  double ingresoMensual = 2500000.0;
  double saldoDisponible = 0.0;
  List<Gasto> listaDeGastos = [];
  List<Transaccion> listaDeTransacciones = [];
  List<TransaccionRecurrente> listaDeTransaccionesRecurrentes = [];
  List<Categoria> listaDeCategorias = [];
  final int diaDePago = 1;

  // Controladores de animación para los botones
  late AnimationController _ingresoAnimationController;
  late AnimationController _gastoAnimationController;
  late AnimationController _ahorroAnimationController;
  late AnimationController _inversionAnimationController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores de animación con duración más larga
    _ingresoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _gastoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _ahorroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _inversionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cargarDatos().then((_) {
      _verificarPagosDeGastos();
      _revisarTransaccionesRecurrentes();
    });
  }

  @override
  void dispose() {
    _ingresoAnimationController.dispose();
    _gastoAnimationController.dispose();
    _ahorroAnimationController.dispose();
    _inversionAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleUserMenuSelection(String value) {
    switch (value) {
      case 'perfil':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RegistroUsuarioScreen(),
          ),
        );
        break;
      case 'configuracion':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfiguracionScreen(
              ingresoMensual: ingresoMensual,
              listaDeGastos: listaDeGastos,
              listaDeCategorias: listaDeCategorias,
              listaDeTransaccionesRecurrentes: listaDeTransaccionesRecurrentes,
              onDatosActualizados: (nuevoIngreso, nuevosGastos, nuevasRecurrentes) {
                setState(() {
                  ingresoMensual = nuevoIngreso;
                  listaDeGastos = nuevosGastos;
                  listaDeTransaccionesRecurrentes = nuevasRecurrentes;
                });
              },
            ),
          ),
        );
        break;
      case 'categorias':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriasScreen(
              listaDeCategorias: listaDeCategorias,
              onCategoriasActualizadas: (nuevasCategorias) {
                setState(() {
                  listaDeCategorias = nuevasCategorias;
                });
              },
            ),
          ),
        );
        break;
      case 'tema':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ThemeSelectorScreen(),
          ),
        );
        break;
      case 'cerrar_sesion':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes agregar la lógica para cerrar sesión
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- Métodos de Lógica y Datos ---

  IconData _getIconForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Icons.help;
    try {
      final categoria = listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return IconData(categoria.icono, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.help;
    }
  }

  Color _getColorForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Colors.grey;
    try {
      final categoria = listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return categoria.tipo == 'ingreso' ? Colors.green : Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getCombinedItems() {
    List<Map<String, dynamic>> items = [];
    Map<String, List<Map<String, dynamic>>> transaccionesPorFecha = {};

    for (var gasto in listaDeGastos) {
      items.add({
        'isGasto': true,
        'isHeader': false,
        'titulo': gasto.nombre,
        'subtitulo': gasto.pagado
            ? 'Pagado el día ${gasto.diaDePago} · ${_obtenerNombreCategoria(gasto.categoriaId)}'
            : 'Vence el día ${gasto.diaDePago} · ${_obtenerNombreCategoria(gasto.categoriaId)}',
        'monto': formatoMoneda(gasto.monto),
        'montoColor': gasto.pagado ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
        'icon': gasto.pagado ? Icons.check_circle : _getIconForCategoria(gasto.categoriaId),
        'color': gasto.pagado ? Colors.green : _getColorForCategoria(gasto.categoriaId),
        'pagado': gasto.pagado,
        'fecha': null,
      });
    }

    final transaccionesRecientes = listaDeTransacciones.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));

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
      final hora = DateFormat('h:mm a', 'es').format(transaccion.fecha);

      if (!transaccionesPorFecha.containsKey(fechaKey)) {
        transaccionesPorFecha[fechaKey] = [];
      }

      final nombreCategoria = _obtenerNombreCategoria(transaccion.categoriaId);
      final subtitulo = transaccion.descripcion == 'Sin descripción' 
          ? hora
          : '${transaccion.descripcion} - $hora';
      
      transaccionesPorFecha[fechaKey]!.add({
        'isGasto': false,
        'isHeader': false,
        'titulo': titulo,
        'subtitulo': subtitulo,
        'monto': transaccion.tipo == 'ingreso' ? '+${formatoMoneda(transaccion.monto)}' : formatoMoneda(transaccion.monto),
        'montoColor': transaccion.tipo == 'ingreso' ? Colors.green : Colors.red,
        'icon': _getIconForCategoria(transaccion.categoriaId),
        'color': _getColorForCategoria(transaccion.categoriaId),
        'pagado': false,
        'fecha': transaccion.fecha,
        'transaccion': transaccion,
      });
    }

    final fechasOrdenadas = transaccionesPorFecha.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)));

    for (var fecha in fechasOrdenadas) {
      final fechaObj = DateFormat('dd/MM/yyyy').parse(fecha);
      final diaSemana = DateFormat('EEEE', 'es').format(fechaObj);
      final mesAno = DateFormat('MMMM yyyy', 'es').format(fechaObj);

      items.add({
        'isGasto': false,
        'isHeader': true,
        'titulo': '$diaSemana, ${fechaObj.day} de ${mesAno.toLowerCase()}',
        'subtitulo': '',
        'monto': '',
        'montoColor': Colors.black87,
        'icon': null,
        'color': Colors.grey,
        'pagado': false,
        'fecha': fechaObj,
      });
      // Ordenar transacciones del día por hora (más reciente primero)
      final transaccionesOrdenadas = transaccionesPorFecha[fecha]!
          ..sort((a, b) => b['fecha'].compareTo(a['fecha']));
      items.addAll(transaccionesOrdenadas);
    }
    return items;
  }

  void _inicializarCategorias() {
    listaDeCategorias = [
      Categoria.nueva(nombre: 'Salario', tipo: 'ingreso', icono: Icons.work.codePoint),
      Categoria.nueva(nombre: 'Bonificación', tipo: 'ingreso', icono: Icons.card_giftcard.codePoint),
      Categoria.nueva(nombre: 'Ventas', tipo: 'ingreso', icono: Icons.sell.codePoint),
      Categoria.nueva(nombre: 'Otros Ingresos', tipo: 'ingreso', icono: Icons.attach_money.codePoint),
      Categoria.nueva(nombre: 'Hogar', tipo: 'gasto', icono: Icons.home.codePoint),
      Categoria.nueva(nombre: 'Transporte', tipo: 'gasto', icono: Icons.directions_car.codePoint),
      Categoria.nueva(nombre: 'Alimentación', tipo: 'gasto', icono: Icons.restaurant.codePoint),
      Categoria.nueva(nombre: 'Salud', tipo: 'gasto', icono: Icons.medical_services.codePoint),
      Categoria.nueva(nombre: 'Entretenimiento', tipo: 'gasto', icono: Icons.movie.codePoint),
      Categoria.nueva(nombre: 'Educación', tipo: 'gasto', icono: Icons.school.codePoint),
      Categoria.nueva(nombre: 'Deudas', tipo: 'gasto', icono: Icons.credit_card.codePoint),
      Categoria.nueva(nombre: 'Fondo de Emergencia', tipo: 'ahorro', icono: Icons.emergency.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Vivienda', tipo: 'ahorro', icono: Icons.home_work.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Vehículo', tipo: 'ahorro', icono: Icons.directions_car.codePoint),
      Categoria.nueva(nombre: 'Ahorro para Educación', tipo: 'ahorro', icono: Icons.school.codePoint),
      Categoria.nueva(nombre: 'Vacaciones y Ocio', tipo: 'ahorro', icono: Icons.flight.codePoint),
      Categoria.nueva(nombre: 'Compras Grandes', tipo: 'ahorro', icono: Icons.shopping_bag.codePoint),
      Categoria.nueva(nombre: 'Metas Personales', tipo: 'ahorro', icono: Icons.flag.codePoint),
      Categoria.nueva(nombre: 'Ahorro General', tipo: 'ahorro', icono: Icons.savings.codePoint),
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

  String _obtenerNombreCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return 'Sin categoría';
    try {
      final categoria = listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return categoria.nombre;
    } catch (e) {
      return 'Sin categoría';
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo', saldoDisponible);
    await prefs.setDouble('ingresoMensual', ingresoMensual);
    await prefs.setString('gastos', jsonEncode(listaDeGastos.map((g) => g.toJson()).toList()));
    await prefs.setString('transacciones', jsonEncode(listaDeTransacciones.map((t) => t.toJson()).toList()));
    await prefs.setString('categorias', jsonEncode(listaDeCategorias.map((c) => c.toJson()).toList()));
    await prefs.setString('transaccionesRecurrentes', jsonEncode(listaDeTransaccionesRecurrentes.map((t) => t.toJson()).toList()));
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    saldoDisponible = prefs.getDouble('saldo') ?? 0.0;
    ingresoMensual = prefs.getDouble('ingresoMensual') ?? 2500000.0;

    final gastosJson = prefs.getString('gastos');
    if (gastosJson != null) {
      listaDeGastos = (jsonDecode(gastosJson) as List).map((json) => Gasto.fromJson(json)).toList();
    } else {
      listaDeGastos = [];
    }

    final transaccionesJson = prefs.getString('transacciones');
    if (transaccionesJson != null) {
      listaDeTransacciones = (jsonDecode(transaccionesJson) as List).map((json) => Transaccion.fromJson(json)).toList();
    } else {
      listaDeTransacciones = [];
    }

    final categoriasJson = prefs.getString('categorias');
    if (categoriasJson != null) {
      listaDeCategorias = (jsonDecode(categoriasJson) as List).map((json) => Categoria.fromJson(json)).toList();
    } else {
      listaDeCategorias = [];
    }

    final transaccionesRecurrentesJson = prefs.getString('transaccionesRecurrentes');
    if (transaccionesRecurrentesJson != null) {
      listaDeTransaccionesRecurrentes = (jsonDecode(transaccionesRecurrentesJson) as List).map((json) => TransaccionRecurrente.fromJson(json)).toList();
    } else {
      listaDeTransaccionesRecurrentes = [];
    }

    if (listaDeCategorias.isEmpty) {
      _inicializarCategorias();
    }
    setState(() {});
  }

  void _verificarPagosDeGastos() {
    final now = DateTime.now();
    for (var gasto in listaDeGastos) {
      if (!gasto.pagado) {
        if (now.day == gasto.diaDePago - 1) {
          _mostrarModalRecordatorio(gasto);
          break;
        } else if (now.day >= gasto.diaDePago) {
          _mostrarModalConfirmacionPago(gasto);
          break;
        }
      }
    }
  }

  Future<void> _revisarTransaccionesRecurrentes() async {
    final hoy = DateTime.now();
    for (final transaccion in listaDeTransaccionesRecurrentes) {
      if (!transaccion.activa) continue;
      bool esDiaCorrecto = false;
      switch (transaccion.frecuencia) {
        case 'semanal':
          esDiaCorrecto = hoy.weekday == transaccion.fechaInicio.weekday;
          break;
        case 'mensual':
          esDiaCorrecto = hoy.day == transaccion.fechaInicio.day;
          break;
        case 'anual':
          esDiaCorrecto = hoy.day == transaccion.fechaInicio.day && hoy.month == transaccion.fechaInicio.month;
          break;
      }
      if (esDiaCorrecto && hoy.isAfter(transaccion.fechaInicio.subtract(const Duration(days: 1)))) {
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

  // --- Métodos de UI (Dialogs, Modals, etc.) ---

  void _mostrarDialogoIngresoRecurrente(TransaccionRecurrente transaccion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KipuPromptDialog(
          mascotImagePath: 'assets/images/ingreso_recurrente.png',
          descripcion: transaccion.descripcion,
          monto: formatoMoneda(transaccion.monto),
          frecuencia: transaccion.frecuencia,
          textoBotonSi: 'Sí',
          textoBotonNo: 'No',
          onConfirmar: () => _procesarIngresoRecurrente(transaccion, true),
          onCancelar: () => _procesarIngresoRecurrente(transaccion, false),
        );
      },
    );
  }

  void _mostrarDialogoGastoRecurrente(TransaccionRecurrente transaccion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KipuPromptDialog(
          mascotImagePath: 'assets/images/gasto_recurrente.png',
          descripcion: transaccion.descripcion,
          monto: formatoMoneda(transaccion.monto),
          frecuencia: transaccion.frecuencia,
          textoBotonSi: 'Sí',
          textoBotonNo: 'No',
          onConfirmar: () => _procesarGastoRecurrente(transaccion, true),
          onCancelar: () => _procesarGastoRecurrente(transaccion, false),
        );
      },
    );
  }

  void _procesarIngresoRecurrente(TransaccionRecurrente transaccion, bool recibido) async {
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    
    // Marcar como procesado para este día
    await prefs.setBool(clave, true);
    
    if (recibido) {
      // Crear transacción de ingreso
      final nuevaTransaccion = Transaccion(
        id: const Uuid().v4(),
        descripcion: transaccion.descripcion,
        monto: transaccion.monto,
        tipo: 'ingreso',
        fecha: hoy,
        categoriaId: transaccion.categoriaId,
      );
      
      setState(() {
        listaDeTransacciones.add(nuevaTransaccion);
        saldoDisponible += transaccion.monto;
      });
      
      await _guardarDatos();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingreso recurrente registrado: ${formatoMoneda(transaccion.monto)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _procesarGastoRecurrente(TransaccionRecurrente transaccion, bool pagado) async {
    final hoy = DateTime.now();
    final clave = 'transaccion_${transaccion.id}_${hoy.year}_${hoy.month}_${hoy.day}';
    final prefs = await SharedPreferences.getInstance();
    
    // Marcar como procesado para este día
    await prefs.setBool(clave, true);
    
    if (pagado) {
      // Crear transacción de gasto
      final nuevaTransaccion = Transaccion(
        id: const Uuid().v4(),
        descripcion: transaccion.descripcion,
        monto: transaccion.monto,
        tipo: 'gasto',
        fecha: hoy,
        categoriaId: transaccion.categoriaId,
      );
      
      setState(() {
        listaDeTransacciones.add(nuevaTransaccion);
        saldoDisponible -= transaccion.monto;
      });
      
      await _guardarDatos();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto recurrente registrado: ${formatoMoneda(transaccion.monto)}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _mostrarModalRecordatorio(Gasto gasto) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recordatorio de Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mañana vence el pago de:'),
              const SizedBox(height: 8),
              Text('${gasto.nombre}'),
              const SizedBox(height: 8),
              Text('Monto: ${formatoMoneda(gasto.monto)}'),
              const SizedBox(height: 8),
              Text('Día de pago: ${gasto.diaDePago}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarModalConfirmacionPago(Gasto gasto) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KipuPromptDialog(
          mascotImagePath: 'assets/images/gasto_recurrente.png',
          descripcion: gasto.nombre,
          monto: formatoMoneda(gasto.monto),
          frecuencia: 'Día de pago: ${gasto.diaDePago}',
          textoBotonSi: 'Sí, ya pagué',
          textoBotonNo: 'No',
          onConfirmar: () => _marcarGastoComoPagado(gasto),
          onCancelar: () {},
        );
      },
    );
  }

  void _actualizarTransaccion(Transaccion transaccionActualizada) {
    setState(() {
      final index = listaDeTransacciones.indexWhere((t) => t.id == transaccionActualizada.id);
      if (index != -1) {
        listaDeTransacciones[index] = transaccionActualizada;
        _guardarDatos();
      }
    });
  }

  void _marcarGastoComoPagado(Gasto gasto) {
    setState(() {
      gasto.pagado = true;
    });
    _guardarDatos();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gasto marcado como pagado: ${gasto.nombre}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarMenuDeTransacciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nueva Transacción',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTransactionOption(
                        icon: Icons.add_circle_outline,
                        title: 'Ingreso',
                        subtitle: 'Dinero que recibes',
                        color: Colors.green,
                        animationController: _ingresoAnimationController,
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarFormularioDeTransaccion('ingreso');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTransactionOption(
                        icon: Icons.remove_circle_outline,
                        title: 'Gasto',
                        subtitle: 'Dinero que gastas',
                        color: Colors.red,
                        animationController: _gastoAnimationController,
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarFormularioDeTransaccion('gasto');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTransactionOption(
                        icon: Icons.savings_outlined,
                        title: 'Ahorro',
                        subtitle: 'Dinero que guardas',
                        color: Colors.blue,
                        animationController: _ahorroAnimationController,
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarFormularioDeTransaccion('ahorro');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTransactionOption(
                        icon: Icons.trending_up,
                        title: 'Inversión',
                        subtitle: 'Dinero que inviertes',
                        color: Colors.purple,
                        animationController: _inversionAnimationController,
                        onTap: () {
                          Navigator.pop(context);
                          _mostrarFormularioDeTransaccion('inversion');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarFormularioRecurrente();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.repeat, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Text(
                          'Transacción Recurrente',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildTransactionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required AnimationController animationController,
  }) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Calcular el tamaño del patrón basado en la animación (más dramático)
        final patternSize = 15.0 + (10.0 * animationController.value);
        
        return GestureDetector(
          onTapDown: (_) {
            animationController.forward();
          },
          onTapUp: (_) async {
            // Mantener la animación por más tiempo para apreciarla mejor
            await Future.delayed(const Duration(milliseconds: 300));
            animationController.reverse();
            await Future.delayed(const Duration(milliseconds: 200));
            onTap();
          },
          onTapCancel: () {
            animationController.reverse();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.8 + (0.2 * animationController.value)),
                width: 1 + (2 * animationController.value),
              ),
              // Gradiente radial que cambia con la animación
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  color.withOpacity(0.36 + (0.3 * animationController.value)),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.95],
              ),
              // Efecto de patrón usando boxShadow que cambia con la animación
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.073 + (0.1 * animationController.value)),
                  blurRadius: patternSize,
                  spreadRadius: patternSize * 0.1,
                ),
                // Sombra adicional para el efecto de profundidad
                BoxShadow(
                  color: color.withOpacity(0.1 * animationController.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon, 
                  color: color.withOpacity(0.8 + (0.2 * animationController.value)), 
                  size: 32 + (8 * animationController.value),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8 + (0.2 * animationController.value)),
                    fontSize: 14 + (4 * animationController.value),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12 + (1 * animationController.value),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarFormularioRecurrente() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return NewTransactionModal(
          tipo: 'gasto', // Por defecto gasto, pero el usuario puede cambiar
          categorias: listaDeCategorias,
          onSaveTransaction: _crearTransaccion,
          onSaveRecurringTransaction: _crearTransaccionRecurrente,
          allowTypeChange: true, // Permitir cambiar el tipo
        );
      },
    );
  }

  void _mostrarFormularioDeTransaccion(String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return NewTransactionModal(
          tipo: tipo,
          categorias: listaDeCategorias,
          onSaveTransaction: _crearTransaccion,
          onSaveRecurringTransaction: _crearTransaccionRecurrente,
        );
      },
    );
  }

  void _crearTransaccion(Transaccion transaccion) {
    setState(() {
      listaDeTransacciones.add(transaccion);
      
      // Actualizar saldo según el tipo de transacción
      if (transaccion.tipo == 'ingreso') {
        saldoDisponible += transaccion.monto;
      } else if (transaccion.tipo == 'gasto') {
        saldoDisponible -= transaccion.monto;
      } else if (transaccion.tipo == 'ahorro' || transaccion.tipo == 'inversion') {
        saldoDisponible -= transaccion.monto;
      }
    });

    _guardarDatos();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${transaccion.tipo.toUpperCase()} agregado exitosamente'),
        backgroundColor: transaccion.tipo == 'ingreso' ? Colors.green : Colors.orange,
      ),
    );
  }

  void _crearTransaccionRecurrente(TransaccionRecurrente transaccionRecurrente) {
    setState(() {
      listaDeTransaccionesRecurrentes.add(transaccionRecurrente);
    });

    _guardarDatos();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transacción recurrente ${transaccionRecurrente.tipo.toUpperCase()} creada exitosamente'),
        backgroundColor: transaccionRecurrente.tipo == 'ingreso' ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<int> _contarPendientesRecurrentes() async {
    // Implementación del conteo
    return 0;
  }

  // --- Widget Build Methods ---

  Widget _buildHomeTab(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header con gradiente
          _buildGradientHeader(context, currencyFormat),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transacciones recientes
                  _buildRecentTransactions(context),
                  const SizedBox(height: 100), // Espacio extra para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Button3D(
        onPressed: _mostrarMenuDeTransacciones,
        icon: Icons.add,
        primaryColor: Theme.of(context).primaryColor,
        secondaryColor: Theme.of(context).primaryColor.withOpacity(0.8),
        size: 56.0,
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, NumberFormat currencyFormat) {
    // Calcular gastos del mes y del día
    final now = DateTime.now();
    final gastosDelMes = listaDeTransacciones
        .where((t) => t.tipo == 'gasto' && 
                     t.fecha.year == now.year && 
                     t.fecha.month == now.month)
        .fold<double>(0.0, (sum, t) => sum + t.monto);
    
    final gastosDelDia = listaDeTransacciones
        .where((t) => t.tipo == 'gasto' && 
                     t.fecha.year == now.year && 
                     t.fecha.month == now.month &&
                     t.fecha.day == now.day)
        .fold<double>(0.0, (sum, t) => sum + t.monto);

    return Container(
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
              // Header superior
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
                        Text('Personal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleUserMenuSelection(value);
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'perfil',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Mi Perfil'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'configuracion',
                        child: Row(
                          children: [
                            Icon(Icons.settings, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Configuración'),
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
                        value: 'cerrar_sesion',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Balance principal
              Center(
                child: Text(
                  currencyFormat.format(saldoDisponible), 
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
              const SizedBox(height: 30),
              // Tarjetas de gastos
              Row(
                children: [
                  Expanded(
                    child: _buildExpenseCard(
                      context,
                      'Gastado este mes',
                      currencyFormat.format(gastosDelMes),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildExpenseCard(
                      context,
                      'Gastado hoy',
                      currencyFormat.format(gastosDelDia),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(BuildContext context, NumberFormat currencyFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(
            context,
            'Balance',
            currencyFormat.format(saldoDisponible),
            Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBalanceCard(
            context,
            'Ingresos',
            currencyFormat.format(ingresoMensual),
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecentTransactions(BuildContext context) {
    // Agrupar transacciones por día
    Map<String, List<Transaccion>> transaccionesPorDia = {};
    
    for (var transaccion in listaDeTransacciones) {
      final fechaKey = DateFormat('dd/MM/yyyy').format(transaccion.fecha);
      if (!transaccionesPorDia.containsKey(fechaKey)) {
        transaccionesPorDia[fechaKey] = [];
      }
      transaccionesPorDia[fechaKey]!.add(transaccion);
    }
    
    // Ordenar fechas de más reciente a más antigua
    final fechasOrdenadas = transaccionesPorDia.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)));
    
    // Tomar solo los primeros 3 días
    final fechasParaMostrar = fechasOrdenadas.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transacciones Recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...fechasParaMostrar.map((fecha) {
          final fechaObj = DateFormat('dd/MM/yyyy').parse(fecha);
          final diaSemana = DateFormat('EEEE', 'es').format(fechaObj);
          final mesAno = DateFormat('MMMM yyyy', 'es').format(fechaObj);
          final transaccionesDelDia = transaccionesPorDia[fecha]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del día
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  '$diaSemana, ${fechaObj.day} de ${mesAno.toLowerCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              // Transacciones del día (ordenadas por hora, más reciente primero)
              ...() {
                final transaccionesOrdenadas = transaccionesDelDia.toList()
                  ..sort((a, b) => b.fecha.compareTo(a.fecha));
                return transaccionesOrdenadas.map((transaction) => _buildTransactionItem(context, transaction));
              }(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaccion transaction) {
    final isIncome = transaction.tipo == 'ingreso';
    final amountColor = isIncome ? Theme.of(context).primaryColor : Colors.red;
    final amountPrefix = isIncome ? '+' : '-';
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    
    // Usar el icono de la categoría
    final iconData = _getIconForCategoria(transaction.categoriaId);
    final color = _getColorForCategoria(transaction.categoriaId);
    
    String description;
    
    // Mantener descripciones específicas para casos especiales, pero usar categoría como respaldo
    if (transaction.descripcion.toLowerCase().contains('comida') || 
        transaction.descripcion.toLowerCase().contains('restaurante')) {
      description = 'Restaurante local';
    } else if (transaction.descripcion.toLowerCase().contains('transporte') ||
               transaction.descripcion.toLowerCase().contains('metro')) {
      description = 'Metro';
    } else {
      description = transaction.descripcion == 'Sin descripción' 
          ? _obtenerNombreCategoria(transaction.categoriaId)
          : transaction.descripcion;
    }
    
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Editar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTransactionScreen(
                transaction: transaction,
                categorias: listaDeCategorias,
                onTransactionUpdated: _actualizarTransaccion,
              ),
            ),
          );
          return false; // No eliminar el elemento, solo navegar
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                iconData,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _obtenerNombreCategoria(transaction.categoriaId),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.descripcion == 'Sin descripción' 
                        ? DateFormat('h:mm a', 'es').format(transaction.fecha)
                        : '${transaction.descripcion} - ${DateFormat('h:mm a', 'es').format(transaction.fecha)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${currencyFormat.format(transaction.monto)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: amountColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const Center(child: Text('Pagos')), // Placeholder
      ExpensesReportScreen(listaDeTransacciones: listaDeTransacciones, listaDeCategorias: listaDeCategorias), // Gastos
      _buildHomeTab(context), // Inicio
      const Center(child: Text('Tarjetas')), // Placeholder
      const Center(child: Text('Espacios')), // Placeholder
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.swap_horiz, 'Pagos', 0),
                _buildNavItem(context, Icons.bar_chart, 'Gastos', 1),
                _buildNavItem(context, Icons.home, 'Inicio', 2),
                _buildNavItem(context, Icons.credit_card, 'Tarjetas', 3),
                _buildNavItem(context, Icons.grid_view, 'Espacios', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodySmall?.color;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantallas de Configuración y Formularios (código omitido por brevedad, pero debe estar aquí)
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
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Configuración")));
  }
}

class CategoriasScreen extends StatefulWidget {
  final List<Categoria> listaDeCategorias;
  final Function(List<Categoria>) onCategoriasActualizadas;

  const CategoriasScreen({
    super.key,
    required this.listaDeCategorias,
    required this.onCategoriasActualizadas,
  });

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Categorías")));
  }
}

class FormularioGastoScreen extends StatefulWidget {
  // ...
  @override
  _FormularioGastoScreenState createState() => _FormularioGastoScreenState();
}

class _FormularioGastoScreenState extends State<FormularioGastoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Formulario Gasto")));
  }
}

class FormularioRecurrenteScreen extends StatefulWidget {
  // ...
  @override
  _FormularioRecurrenteScreenState createState() => _FormularioRecurrenteScreenState();
}

class _FormularioRecurrenteScreenState extends State<FormularioRecurrenteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Formulario Recurrente")));
  }
}

class FormularioGastoFijoScreen extends StatefulWidget {
  // ...
  @override
  _FormularioGastoFijoScreenState createState() => _FormularioGastoFijoScreenState();
}

class _FormularioGastoFijoScreenState extends State<FormularioGastoFijoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Formulario Gasto Fijo")));
  }
}
