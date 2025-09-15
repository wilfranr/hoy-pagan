
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/gasto_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ESTADO DE LA APLICACIÓN ---
  final double _ingresoMensual = 2000000.0;
  double _saldoDisponible = 0.0;
  List<Gasto> _listaDeGastos = [];
  final List<Gasto> _listaDePagosPendientes = [
    Gasto(nombre: 'Tarjeta de Crédito', monto: 250000, diaDePago: 25, pagado: false),
    Gasto(nombre: 'Suscripción App', monto: 20000, diaDePago: 28, pagado: false),
  ];

  // Formateador de moneda para la UI.
  final _currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
    // Se ejecuta después de que el primer frame es renderizado para tener contexto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      revisarPagosPendientes();
    });
  }

  // --- LÓGICA DE PERSISTENCIA ---

  /// Carga el estado (saldo y gastos) desde SharedPreferences.
  /// Si no hay datos, inicializa con valores por defecto.
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _saldoDisponible = prefs.getDouble('saldoDisponible') ?? _ingresoMensual;

      final gastosString = prefs.getString('listaDeGastos');
      if (gastosString != null) {
        final List<dynamic> gastosJson = jsonDecode(gastosString);
        _listaDeGastos = gastosJson.map((json) => Gasto.fromJson(json)).toList();
      } else {
        // Si no hay datos guardados, usar una lista de ejemplo.
        _listaDeGastos = [
          Gasto(nombre: 'Arriendo', monto: 850000, diaDePago: 1, pagado: false),
          Gasto(nombre: 'Servicios (Agua, Luz)', monto: 150000, diaDePago: 15, pagado: false),
          Gasto(nombre: 'Internet y TV', monto: 80000, diaDePago: 15, pagado: false),
          Gasto(nombre: 'Celular', monto: 45000, diaDePago: 20, pagado: false),
          Gasto(nombre: 'Gimnasio', monto: 60000, diaDePago: 5, pagado: false),
        ];
      }
    });
  }

  /// Guarda el estado actual en SharedPreferences.
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldoDisponible', _saldoDisponible);
    final List<Map<String, dynamic>> gastosJson = _listaDeGastos.map((gasto) => gasto.toJson()).toList();
    await prefs.setString('listaDeGastos', jsonEncode(gastosJson));
  }

  // --- LÓGICA DE NEGOCIO ---

  /// Procesa el evento de recibir el pago mensual.
  void _recibiMiPago() {
    setState(() {
      _saldoDisponible += _ingresoMensual;
      for (var gasto in _listaDeGastos) {
        gasto.pagado = false;
      }

      // Pagar automáticamente los gastos con día de pago 1.
      for (var gasto in _listaDeGastos) {
        if (gasto.diaDePago == 1 && !gasto.pagado) {
          if (_saldoDisponible >= gasto.monto) {
            _saldoDisponible -= gasto.monto;
            gasto.pagado = true;
          }
        }
      }
    });

    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Ingreso de ${_currencyFormatter.format(_ingresoMensual)} procesado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Revisa si hay pagos pendientes próximos y muestra una alerta en la consola.
  void revisarPagosPendientes() {
    final hoy = DateTime.now().day;
    for (var gasto in _listaDeGastos) {
      final diasParaPagar = gasto.diaDePago - hoy;
      if (!gasto.pagado && diasParaPagar >= 0 && diasParaPagar <= 2) {
        // Usamos print() como se solicitó para la depuración.
        print('ALERTA: El pago de ${gasto.nombre} vence pronto.');
      }
    }
  }

  /// Muestra el formulario para agregar un nuevo gasto.
  void _mostrarFormularioAgregarGasto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FormularioAgregarGasto(
          onGastoAgregado: (gasto) {
            setState(() {
              _listaDeGastos.add(gasto);
            });
            _saveData();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // --- CONSTRUCCIÓN DE LA UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Gastos'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSaldoCard(),
              const SizedBox(height: 24),
              _buildPagoButton(),
              const SizedBox(height: 24),
              const Text('Actividad reciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildGastosList(),
              const SizedBox(height: 16),
              const Divider(),
              _buildProximosPagosSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAgregarGasto,
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const Text('Saldo Disponible', style: TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            _currencyFormatter.format(_saldoDisponible),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPagoButton() {
    return ElevatedButton(
      onPressed: _recibiMiPago,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Recibí mi pago'),
    );
  }

  Widget _buildGastosList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listaDeGastos.length,
      itemBuilder: (context, index) {
        final gasto = _listaDeGastos[index];
        final textStyle = TextStyle(
          decoration: gasto.pagado ? TextDecoration.lineThrough : TextDecoration.none,
          color: gasto.pagado ? Colors.grey.shade600 : Colors.black87,
          fontStyle: gasto.pagado ? FontStyle.italic : FontStyle.normal,
        );

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: Checkbox(
              value: gasto.pagado,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    if (_saldoDisponible >= gasto.monto) {
                      gasto.pagado = true;
                      _saldoDisponible -= gasto.monto;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saldo insuficiente para pagar este gasto.'), backgroundColor: Colors.red),
                      );
                    }
                  } else {
                    gasto.pagado = false;
                    _saldoDisponible += gasto.monto;
                  }
                  _saveData();
                });
              },
            ),
            title: Text(gasto.nombre, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Paga el día ${gasto.diaDePago}', style: textStyle),
                if (gasto.descripcion != null && gasto.descripcion!.isNotEmpty)
                  Text(
                    gasto.descripcion!,
                    style: textStyle.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                if (gasto.categoria != null && gasto.categoria!.isNotEmpty)
                  Text(
                    'Categoría: ${gasto.categoria!}',
                    style: textStyle.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Text(
              _currencyFormatter.format(gasto.monto),
              style: textStyle.copyWith(fontSize: 15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProximosPagosSection() {
    return ExpansionTile(
      title: const Text('Próximos pagos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _listaDePagosPendientes.length,
          itemBuilder: (context, index) {
            final gasto = _listaDePagosPendientes[index];
            final textStyle = TextStyle(
              decoration: gasto.pagado ? TextDecoration.lineThrough : TextDecoration.none,
              color: gasto.pagado ? Colors.grey.shade600 : Colors.black87,
              fontStyle: gasto.pagado ? FontStyle.italic : FontStyle.normal,
            );
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: Checkbox(
                  value: gasto.pagado,
                  onChanged: (bool? value) {
                    // NOTE: This is a simplified version of the payment logic.
                    // A real app would have more complex state management.
                    setState(() {
                      gasto.pagado = value ?? false;
                    });
                  },
                ),
                title: Text(gasto.nombre, style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('Paga el día ${gasto.diaDePago}', style: textStyle),
                trailing: Text(
                  _currencyFormatter.format(gasto.monto),
                  style: textStyle.copyWith(fontSize: 15),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Formulario para agregar un nuevo gasto.
class _FormularioAgregarGasto extends StatefulWidget {
  final Function(Gasto) onGastoAgregado;

  const _FormularioAgregarGasto({required this.onGastoAgregado});

  @override
  State<_FormularioAgregarGasto> createState() => _FormularioAgregarGastoState();
}

class _FormularioAgregarGastoState extends State<_FormularioAgregarGasto> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  final _diaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _categoriaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _montoController.dispose();
    _diaController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Nuevo Gasto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del gasto *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto *',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El monto es obligatorio';
                  }
                  final monto = double.tryParse(value);
                  if (monto == null || monto <= 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diaController,
                decoration: const InputDecoration(
                  labelText: 'Día de pago (1-31) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El día de pago es obligatorio';
                  }
                  final dia = int.tryParse(value);
                  if (dia == null || dia < 1 || dia > 31) {
                    return 'Ingrese un día válido (1-31)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  border: OutlineInputBorder(),
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
          onPressed: _agregarGasto,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  void _agregarGasto() {
    if (_formKey.currentState!.validate()) {
      final gasto = Gasto(
        nombre: _nombreController.text.trim(),
        monto: double.parse(_montoController.text),
        diaDePago: int.parse(_diaController.text),
        pagado: false,
        descripcion: _descripcionController.text.trim().isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        categoria: _categoriaController.text.trim().isEmpty 
            ? null 
            : _categoriaController.text.trim(),
      );
      
      widget.onGastoAgregado(gasto);
    }
  }
}
