import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/categoria_model.dart';
import '../../data/models/transaccion_model.dart';
import '../../data/models/transaccion_recurrente_model.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../../widgets/custom_switch.dart';
import 'package:kipu/src/features/firestore/application/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTransactionModal extends StatefulWidget {
  final String tipo;
  final bool allowTypeChange;

  const NewTransactionModal({
    super.key,
    required this.tipo,
    this.allowTypeChange = false,
  });

  @override
  State<NewTransactionModal> createState() => _NewTransactionModalState();
}

class _NewTransactionModalState extends State<NewTransactionModal> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  
  String _categoriaSeleccionada = '';
  String _tipoTransaccion = '';
  DateTime _fechaSeleccionada = DateTime.now();
  bool _esRecurrente = false;
  String _frecuenciaRecurrente = 'mensual';
  String _condicionFinRecurrente = 'nunca';
  int? _numeroPagos;
  DateTime? _fechaFin;
  String _tipoDeGasto = 'Servicio';
  Map<String, dynamic> _datosAdicionales = {};
  final Map<String, TextEditingController> _datosAdicionalesControllers = {};

  @override
  void initState() {
    super.initState();
    _tipoTransaccion = widget.tipo;
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    for (var controller in _datosAdicionalesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _tituloModal {
    switch (_tipoTransaccion) {
      case 'ingreso':
        return 'Nuevo Ingreso';
      case 'gasto':
        return 'Nuevo Gasto';
      case 'ahorro':
        return 'Nuevo Ahorro';
      case 'inversion':
        return 'Nueva Inversión';
      default:
        return 'Nueva Transacción';
    }
  }

  Color get _colorPrimario {
    switch (_tipoTransaccion) {
      case 'ingreso':
        return const Color(0xFF00C896);
      case 'gasto':
        return const Color(0xFFE53E3E);
      case 'ahorro':
        return const Color(0xFF3182CE);
      case 'inversion':
        return const Color(0xFF805AD5);
      default:
        return const Color(0xFF00C896);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: theme.iconTheme.color,
                    size: 24,
                  ),
                ),
                Text(
                  _tituloModal,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(width: 32), 
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de monto
                  TextFormField(
                    controller: _montoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo de categoría
                  _buildCategoriaField(isDark),
                  const SizedBox(height: 24),
                  
                  // Campo de descripción
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo de fecha
                  TextFormField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaSeleccionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setState(() {
                          _fechaSeleccionada = fecha;
                          _fechaController.text = DateFormat('yyyy-MM-dd').format(fecha);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarTransaccion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorPrimario,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Guardar ${_tipoTransaccion.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double parseMonto(String text) {
    // Remover caracteres no numéricos excepto punto y coma
    final cleanText = text.replaceAll(RegExp(r'[^\d.,]'), '');
    // Reemplazar coma por punto para decimales
    final normalizedText = cleanText.replaceAll(',', '.');
    return double.tryParse(normalizedText) ?? 0.0;
  }

  void _guardarTransaccion() {
    if (_user == null) return;

    if (_montoController.text.isEmpty || _categoriaSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos obligatorios')),
      );
      return;
    }

    final monto = parseMonto(_montoController.text);
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    if (_esRecurrente) {
      final transaccionRecurrente = TransaccionRecurrente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        descripcion: _descripcionController.text.isEmpty ? 'Sin descripción' : _descripcionController.text,
        monto: monto,
        tipo: _tipoTransaccion,
        activa: true,
        fechaInicio: _fechaSeleccionada,
        frecuencia: _frecuenciaRecurrente,
        condicionFin: _condicionFinRecurrente,
        valorFin: _condicionFinRecurrente == 'numero_pagos' 
            ? _numeroPagos 
            : _condicionFinRecurrente == 'fecha_especifica' 
                ? _fechaFin 
                : null,
        categoriaId: _categoriaSeleccionada,
        tipoDeGasto: _tipoDeGasto,
        datosAdicionales: _datosAdicionales,
      );
      _firestoreService.addRecurringTransaction(_user!.uid, transaccionRecurrente.toJson());
    } else {
      final transaccion = Transaccion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipo: _tipoTransaccion,
        monto: monto,
        descripcion: _descripcionController.text.isEmpty ? 'Sin descripción' : _descripcionController.text,
        fecha: _fechaSeleccionada,
        categoriaId: _categoriaSeleccionada,
      );
      _firestoreService.addTransaction(_user!.uid, transaccion.toJson());
    }

    Navigator.pop(context);
  }

  Widget _buildCategoriaField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getCategoriesStream(_user!.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var categories = snapshot.data!.docs.map((doc) {
                return Categoria.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
              }).where((cat) => cat.tipo == _tipoTransaccion).toList();

              return DropdownButtonFormField<String>(
                value: _categoriaSeleccionada.isEmpty ? null : _categoriaSeleccionada,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: Text(
                  'Seleccionar categoría',
                  style: TextStyle(
                    color: theme.hintColor,
                    fontFamily: 'Manrope',
                  ),
                ),
                items: categories.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria.id,
                    child: Row(
                      children: [
                        Icon(
                          IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                          size: 20,
                          color: _colorPrimario,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoria.nombre,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _categoriaSeleccionada = value ?? '';
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ... (El resto de los métodos _build... se mantienen igual)

}