import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';
import 'package:kipu/widgets/kipu_colors.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoriaNombre;
  final List<Transaccion> listaDeTransacciones;
  final List<Categoria> listaDeCategorias;
  final String periodoSeleccionado;

  const CategoryDetailScreen({
    super.key,
    required this.categoriaNombre,
    required this.listaDeTransacciones,
    required this.listaDeCategorias,
    required this.periodoSeleccionado,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _sortBy = 'fecha'; // fecha, monto
  bool _sortAscending = false;
  String _selectedPeriod = 'Mes';

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.periodoSeleccionado;
  }

  // Obtener transacciones filtradas por categoría y período
  List<Transaccion> get _transaccionesFiltradas {
    final ahora = DateTime.now();
    List<Transaccion> transacciones = [];

    // Filtrar por período
    switch (_selectedPeriod) {
      case 'Semana':
        final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
                t.fecha.isBefore(inicioSemana.add(const Duration(days: 7))))
            .toList();
        break;
      case 'Ano':
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.year == ahora.year)
            .toList();
        break;
      default: // Mes
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.month == ahora.month &&
                t.fecha.year == ahora.year)
            .toList();
    }

    // Filtrar por categoría
    final categoriaId = _obtenerCategoriaId(widget.categoriaNombre);
    transacciones = transacciones
        .where((t) => t.categoriaId == categoriaId)
        .toList();

    // Ordenar
    transacciones.sort((a, b) {
      switch (_sortBy) {
        case 'monto':
          return _sortAscending 
              ? a.monto.compareTo(b.monto)
              : b.monto.compareTo(a.monto);
        default: // fecha
          return _sortAscending 
              ? a.fecha.compareTo(b.fecha)
              : b.fecha.compareTo(a.fecha);
      }
    });

    return transacciones;
  }

  double get _totalCategoria {
    return _transaccionesFiltradas.fold(0.0, (sum, item) => sum + item.monto);
  }

  // Calcular gastos de la categoría en el período anterior
  double get _totalCategoriaPeriodoAnterior {
    final ahora = DateTime.now();
    List<Transaccion> transacciones = [];

    // Filtrar por período anterior
    switch (_selectedPeriod) {
      case 'Semana':
        final inicioSemanaAnterior = ahora.subtract(Duration(days: ahora.weekday - 1 + 7));
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.isAfter(inicioSemanaAnterior.subtract(const Duration(days: 1))) &&
                t.fecha.isBefore(inicioSemanaAnterior.add(const Duration(days: 7))))
            .toList();
        break;
      case 'Ano':
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.year == ahora.year - 1)
            .toList();
        break;
      default: // Mes
        final mesAnterior = ahora.month == 1 ? 12 : ahora.month - 1;
        final anoAnterior = ahora.month == 1 ? ahora.year - 1 : ahora.year;
        transacciones = widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'gasto' &&
                t.fecha.month == mesAnterior &&
                t.fecha.year == anoAnterior)
            .toList();
    }

    // Filtrar por categoría
    final categoriaId = _obtenerCategoriaId(widget.categoriaNombre);
    transacciones = transacciones
        .where((t) => t.categoriaId == categoriaId)
        .toList();

    return transacciones.fold(0.0, (sum, item) => sum + item.monto);
  }

  // Calcular porcentaje de variación para la categoría
  double get _porcentajeVariacionCategoria {
    if (_totalCategoriaPeriodoAnterior == 0) return 0.0;
    return ((_totalCategoria - _totalCategoriaPeriodoAnterior) / _totalCategoriaPeriodoAnterior) * 100;
  }

  // Determinar si la variación es positiva (buena para gastos)
  bool get _esVariacionCategoriaPositiva {
    return _porcentajeVariacionCategoria < 0; // Para gastos, disminución es buena
  }

  String _obtenerCategoriaId(String categoriaNombre) {
    try {
      return widget.listaDeCategorias.firstWhere((c) => c.nombre == categoriaNombre).id;
    } catch (e) {
      return '';
    }
  }

  IconData _obtenerIconoCategoria(String categoriaNombre) {
    try {
      final categoria = widget.listaDeCategorias.firstWhere((c) => c.nombre == categoriaNombre);
      return IconData(categoria.icono, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return currencyFormat.format(monto);
  }

  String formatoFecha(DateTime fecha) {
    return DateFormat('dd MMM yyyy', 'es').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transacciones = _transaccionesFiltradas;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Row(
          children: [
            Icon(
              _obtenerIconoCategoria(widget.categoriaNombre),
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.categoriaNombre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.sort,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onSelected: (value) {
              setState(() {
                if (value == 'fecha') {
                  _sortBy = 'fecha';
                  _sortAscending = !_sortAscending;
                } else if (value == 'monto') {
                  _sortBy = 'monto';
                  _sortAscending = !_sortAscending;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'fecha',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: _sortBy == 'fecha' ? Colors.red : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Ordenar por fecha'),
                    if (_sortBy == 'fecha') ...[
                      const SizedBox(width: 8),
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'monto',
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: _sortBy == 'monto' ? KipuColors.tealKipu : null,
                    ),
                    const SizedBox(width: 8),
                    Text('Ordenar por monto'),
                    if (_sortBy == 'monto') ...[
                      const SizedBox(width: 8),
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de período
          _buildPeriodSelector(isDark),
          
          // Resumen de la categoría
          _buildCategorySummary(isDark),
          
          // Lista de transacciones
          Expanded(
            child: transacciones.isEmpty
                ? _buildEmptyState(isDark)
                : _buildTransactionsList(transacciones, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: ['Semana', 'Mes', 'Ano'].map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? Colors.red : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorySummary(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total ${_selectedPeriod.toLowerCase()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '${_transaccionesFiltradas.length} transacciones',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatoMoneda(_totalCategoria),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'vs ${_selectedPeriod.toLowerCase()} anterior',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_porcentajeVariacionCategoria >= 0 ? '+' : ''}${_porcentajeVariacionCategoria.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _esVariacionCategoriaPositiva ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron gastos en ${widget.categoriaNombre}\npara el período ${_selectedPeriod.toLowerCase()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaccion> transacciones, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transacciones.length,
      itemBuilder: (context, index) {
        final transaccion = transacciones[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt,
                color: Colors.red,
                size: 24,
              ),
            ),
            title: Text(
              transaccion.descripcion.isNotEmpty 
                  ? transaccion.descripcion 
                  : 'Gasto en ${widget.categoriaNombre}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  formatoFecha(transaccion.fecha),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Text(
              formatoMoneda(transaccion.monto),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
