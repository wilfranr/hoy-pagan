import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaccion transaction;
  final List<Categoria> categorias;
  final Function(Transaccion) onTransactionUpdated;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.categorias,
    required this.onTransactionUpdated,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late DateTime _fechaSeleccionada;
  late String _categoriaSeleccionada;
  late String _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(text: _formatearMonto(widget.transaction.monto));
    _descripcionController = TextEditingController(text: widget.transaction.descripcion);
    _fechaSeleccionada = widget.transaction.fecha;
    _categoriaSeleccionada = widget.transaction.categoriaId;
    _tipoSeleccionado = widget.transaction.tipo;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return currencyFormat.format(monto);
  }

  String _formatearMonto(double monto) {
    return NumberFormat('#,##0', 'es_CO').format(monto);
  }

  String _limpiarMonto(String montoConFormato) {
    return montoConFormato.replaceAll('.', '').replaceAll(',', '.');
  }

  void _onMontoChanged(String value) {
    // Remover caracteres no numéricos excepto puntos y comas
    String cleanedValue = value.replaceAll(RegExp(r'[^\d.,]'), '');
    
    if (cleanedValue.isEmpty) {
      _montoController.text = '';
      _montoController.selection = TextSelection.collapsed(offset: 0);
      return;
    }

    // Convertir a número para formatear
    try {
      String numericValue = cleanedValue.replaceAll('.', '').replaceAll(',', '.');
      double monto = double.parse(numericValue);
      
      // Formatear con puntos de mil
      String formattedValue = _formatearMonto(monto);
      
      if (formattedValue != value) {
        _montoController.text = formattedValue;
        _montoController.selection = TextSelection.collapsed(offset: formattedValue.length);
      }
    } catch (e) {
      // Si hay error en el parsing, mantener el valor anterior
    }
  }

  IconData _getIconForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Icons.help;
    final categoria = widget.categorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return IconData(categoria.icono, fontFamily: 'MaterialIcons');
  }

  Color _getColorForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Colors.grey;
    final categoria = widget.categorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return categoria.tipo == 'ingreso' ? Colors.green : Colors.red;
  }

  String _obtenerNombreCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return 'Sin categoría';
    try {
      return widget.categorias.firstWhere((cat) => cat.id == categoriaId).nombre;
    } catch (e) {
      return 'Sin categoría';
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  void _guardarCambios() {
    final montoTexto = _montoController.text.trim();
    if (montoTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto es requerido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final monto = double.tryParse(_limpiarMonto(montoTexto)) ?? 0.0;
    
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto debe ser mayor a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transaccionActualizada = Transaccion(
      id: widget.transaction.id,
      tipo: _tipoSeleccionado,
      monto: monto,
      descripcion: _descripcionController.text.trim().isEmpty ? 'Sin descripción' : _descripcionController.text.trim(),
      fecha: _fechaSeleccionada,
      categoriaId: _categoriaSeleccionada,
    );

    widget.onTransactionUpdated(transaccionActualizada);
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transacción actualizada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriasFiltradas = widget.categorias.where((cat) => cat.tipo == _tipoSeleccionado).toList();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Editar Transacción'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _guardarCambios,
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de transacción
            _buildSectionTitle('Tipo de Transacción'),
            const SizedBox(height: 12),
            _buildDropdownField(
              value: _tipoSeleccionado,
              items: const [
                DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                DropdownMenuItem(value: 'gasto', child: Text('Gasto')),
                DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                DropdownMenuItem(value: 'inversion', child: Text('Inversión')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoSeleccionado = value!;
                  // Resetear categoría si no es compatible con el nuevo tipo
                  if (!widget.categorias.any((cat) => cat.id == _categoriaSeleccionada && cat.tipo == _tipoSeleccionado)) {
                    _categoriaSeleccionada = categoriasFiltradas.isNotEmpty ? categoriasFiltradas.first.id : '';
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Monto
            _buildSectionTitle('Monto'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _montoController,
              hintText: 'Ingresa el monto',
              prefixText: r'$ ',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _onMontoChanged,
            ),
            const SizedBox(height: 24),

            // Descripción
            _buildSectionTitle('Descripción'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descripcionController,
              hintText: 'Descripción de la transacción',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Fecha
            _buildSectionTitle('Fecha'),
            const SizedBox(height: 12),
            _buildDateField(),
            const SizedBox(height: 24),

            // Categoría
            _buildSectionTitle('Categoría'),
            const SizedBox(height: 12),
            _buildCategoryDropdown(categoriasFiltradas),
            const SizedBox(height: 40),

            // Botón guardar
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          prefixText: prefixText,
          prefixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          dropdownColor: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _seleccionarFecha,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Categoria> categorias) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoriaSeleccionada.isEmpty ? null : _categoriaSeleccionada,
          isExpanded: true,
          hint: Text(
            'Selecciona una categoría',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          items: categorias.map((categoria) {
            return DropdownMenuItem<String>(
              value: categoria.id,
              child: Row(
                children: [
                  Icon(
                    IconData(categoria.icono, fontFamily: 'MaterialIcons'),
                    color: categoria.tipo == 'ingreso' ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoria.nombre,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _categoriaSeleccionada = value ?? '';
            });
          },
          style: Theme.of(context).textTheme.bodyLarge,
          dropdownColor: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Guardar Cambios',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
