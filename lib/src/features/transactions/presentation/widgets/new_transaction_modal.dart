import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/categoria_model.dart';
import '../../data/models/transaccion_model.dart';
import '../../data/models/transaccion_recurrente_model.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../../widgets/custom_switch.dart';

class NewTransactionModal extends StatefulWidget {
  final String tipo;
  final List<Categoria> categorias;
  final Function(Transaccion) onSaveTransaction;
  final Future<void> Function(TransaccionRecurrente)?
  onSaveRecurringTransaction;
  final bool allowTypeChange;

  const NewTransactionModal({
    super.key,
    required this.tipo,
    required this.categorias,
    required this.onSaveTransaction,
    this.onSaveRecurringTransaction,
    this.allowTypeChange = false,
  });

  @override
  State<NewTransactionModal> createState() => _NewTransactionModalState();
}

class _NewTransactionModalState extends State<NewTransactionModal> {
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
    super.dispose();
  }

  List<Categoria> get _categoriasFiltradas {
    return widget.categorias
        .where((cat) => cat.tipo == _tipoTransaccion)
        .toList();
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
                const SizedBox(width: 32), // Espacio para centrar el título
              ],
            ),
          ),

          // Contenido del formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo Monto
                  _buildMontoField(isDark),
                  const SizedBox(height: 24),

                  // Selector de Tipo (solo si se permite cambiar)
                  if (widget.allowTypeChange) ...[
                    _buildTipoField(isDark),
                    const SizedBox(height: 24),
                  ],

                  // Campo Categoría
                  _buildCategoriaField(isDark),
                  const SizedBox(height: 24),

                  // Campo Fecha
                  _buildFechaField(isDark),
                  const SizedBox(height: 24),

                  // Campo Descripción
                  _buildDescripcionField(isDark),
                  const SizedBox(height: 24),

                  // Switch para transacción recurrente
                  _buildRecurrenteSwitch(isDark),

                  // Campos adicionales para transacción recurrente
                  if (_esRecurrente) ...[
                    const SizedBox(height: 16),
                    _buildFrecuenciaField(isDark),
                    const SizedBox(height: 16),
                    _buildCondicionFinField(isDark),
                    if (_condicionFinRecurrente == 'numero_pagos') ...[
                      const SizedBox(height: 16),
                      _buildNumeroPagosField(isDark),
                    ],
                    if (_condicionFinRecurrente == 'fecha_especifica') ...[
                      const SizedBox(height: 16),
                      _buildFechaFinField(isDark),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // Footer con botón de guardar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _guardarTransaccion(),
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

  Widget _buildMontoField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: _montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [ThousandsSeparatorInputFormatter()],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: theme.hintColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: theme.hintColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipoField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Transacción',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _tipoTransaccion,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
              DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
              DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
              DropdownMenuItem(value: 'inversion', child: Text('Inversión')),
            ],
            onChanged: (String? value) {
              setState(() {
                _tipoTransaccion = value ?? 'gasto';
                _categoriaSeleccionada =
                    ''; // Limpiar categoría al cambiar tipo
              });
            },
          ),
        ),
      ],
    );
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
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _categoriaSeleccionada.isEmpty
                ? null
                : _categoriaSeleccionada,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: Text(
              'Seleccionar categoría',
              style: TextStyle(color: theme.hintColor, fontFamily: 'Manrope'),
            ),
            items: _categoriasFiltradas.map((categoria) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildFechaField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: _fechaController,
            readOnly: true,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: theme.hintColor,
                size: 20,
              ),
            ),
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaSeleccionada,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                locale: const Locale('es', 'ES'),
              );
              if (fecha != null) {
                setState(() {
                  _fechaSeleccionada = fecha;
                  _fechaController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(fecha);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescripcionField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (Opcional)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: _descripcionController,
            maxLines: 3,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Café con amigos',
              hintStyle: TextStyle(
                color: theme.hintColor,
                fontFamily: 'Manrope',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenteSwitch(bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat, color: _colorPrimario, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transacción Recurrente',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Manrope',
                  ),
                ),
                Text(
                  'Programar para repetirse automáticamente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          CustomSwitch(
            value: _esRecurrente,
            onChanged: (value) {
              setState(() {
                _esRecurrente = value;
              });
            },
            activeColor: _colorPrimario,
          ),
        ],
      ),
    );
  }

  Widget _buildFrecuenciaField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frecuencia',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _frecuenciaRecurrente,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
              DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
              DropdownMenuItem(value: 'anual', child: Text('Anual')),
            ],
            onChanged: (String? value) {
              setState(() {
                _frecuenciaRecurrente = value ?? 'mensual';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCondicionFinField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condición de Fin',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonFormField<String>(
            value: _condicionFinRecurrente,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'nunca', child: Text('Nunca')),
              DropdownMenuItem(
                value: 'numero_pagos',
                child: Text('Número de pagos'),
              ),
              DropdownMenuItem(
                value: 'fecha_especifica',
                child: Text('Fecha específica'),
              ),
            ],
            onChanged: (String? value) {
              setState(() {
                _condicionFinRecurrente = value ?? 'nunca';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumeroPagosField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de Pagos',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: 'Ej: 12',
              hintStyle: TextStyle(
                color: theme.hintColor,
                fontFamily: 'Manrope',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _numeroPagos = int.tryParse(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFechaFinField(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Fin',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            readOnly: true,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Manrope',
            ),
            decoration: InputDecoration(
              hintText: 'Seleccionar fecha',
              hintStyle: TextStyle(
                color: theme.hintColor,
                fontFamily: 'Manrope',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: Icon(
                Icons.calendar_today,
                color: theme.hintColor,
                size: 20,
              ),
            ),
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate:
                    _fechaFin ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                locale: const Locale('es', 'ES'),
              );
              if (fecha != null) {
                setState(() {
                  _fechaFin = fecha;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _guardarTransaccion() async {
    if (_montoController.text.isEmpty || _categoriaSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
        ),
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
      if (widget.onSaveRecurringTransaction != null) {
        // Validaciones adicionales para transacciones recurrentes
        if (_condicionFinRecurrente == 'numero_pagos' &&
            (_numeroPagos == null || _numeroPagos! <= 0)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor ingresa un número válido de pagos'),
            ),
          );
          return;
        }

        if (_condicionFinRecurrente == 'fecha_especifica' &&
            _fechaFin == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor selecciona una fecha de fin'),
            ),
          );
          return;
        }

        final transaccionRecurrente = TransaccionRecurrente(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          descripcion: _descripcionController.text.isEmpty
              ? 'Sin descripción'
              : _descripcionController.text,
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
        );
        await widget.onSaveRecurringTransaction!(transaccionRecurrente);
      }
    } else {
      final transaccion = Transaccion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipo: _tipoTransaccion,
        monto: monto,
        descripcion: _descripcionController.text.isEmpty
            ? 'Sin descripción'
            : _descripcionController.text,
        fecha: _fechaSeleccionada,
        categoriaId: _categoriaSeleccionada,
      );
      widget.onSaveTransaction(transaccion);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
