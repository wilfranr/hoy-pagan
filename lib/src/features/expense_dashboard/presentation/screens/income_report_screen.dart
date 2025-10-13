import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';
import 'package:kipu/src/features/expense_dashboard/presentation/screens/income_category_detail_screen.dart';

class IncomeReportScreen extends StatefulWidget {
  final List<Transaccion> listaDeTransacciones;
  final List<Categoria> listaDeCategorias;

  const IncomeReportScreen({
    super.key,
    required this.listaDeTransacciones,
    required this.listaDeCategorias,
  });

  @override
  State<IncomeReportScreen> createState() => _IncomeReportScreenState();
}

class _IncomeReportScreenState extends State<IncomeReportScreen> {
  String _selectedPeriod = 'Mes';

  // Métodos para calcular datos dinámicamente
  List<Transaccion> get _ingresos {
    return _procesarIngresos();
  }

  double get _totalIngresado {
    return _ingresos.fold(0.0, (sum, item) => sum + item.monto);
  }

  Map<String, double> get _ingresosPorCategoria {
    Map<String, double> ingresosPorCategoria = {};
    for (var ingreso in _ingresos) {
      final categoriaNombre = _obtenerNombreCategoria(ingreso.categoriaId);
      ingresosPorCategoria.update(
        categoriaNombre,
        (value) => value + ingreso.monto,
        ifAbsent: () => ingreso.monto,
      );
    }
    return ingresosPorCategoria;
  }

  List<double> get _monthlyData {
    return _generateMonthlyData();
  }

  // Calcular ingresos del período anterior para comparación
  double get _ingresosPeriodoAnterior {
    final ahora = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'Semana':
        final inicioSemanaAnterior = ahora.subtract(Duration(days: ahora.weekday - 1 + 7));
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.isAfter(inicioSemanaAnterior.subtract(const Duration(days: 1))) &&
                t.fecha.isBefore(inicioSemanaAnterior.add(const Duration(days: 7))))
            .fold(0.0, (sum, item) => sum + item.monto);
            
      case 'Año':
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.year == ahora.year - 1)
            .fold(0.0, (sum, item) => sum + item.monto);
            
      default: // Mes
        final mesAnterior = ahora.month == 1 ? 12 : ahora.month - 1;
        final anoAnterior = ahora.month == 1 ? ahora.year - 1 : ahora.year;
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.month == mesAnterior &&
                t.fecha.year == anoAnterior)
            .fold(0.0, (sum, item) => sum + item.monto);
    }
  }

  // Calcular porcentaje de variación
  double get _porcentajeVariacion {
    if (_ingresosPeriodoAnterior == 0) return 0.0;
    return ((_totalIngresado - _ingresosPeriodoAnterior) / _ingresosPeriodoAnterior) * 100;
  }

  // Determinar si la variación es positiva (buena para ingresos)
  bool get _esVariacionPositiva {
    return _porcentajeVariacion > 0; // Para ingresos, aumento es bueno
  }

  List<Transaccion> _procesarIngresos() {
    final ahora = DateTime.now();
    
    // Filtrar ingresos según el período seleccionado
    switch (_selectedPeriod) {
      case 'Semana':
        final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
                t.fecha.isBefore(inicioSemana.add(const Duration(days: 7))))
            .toList();
      case 'Año':
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.year == ahora.year)
            .toList();
      default: // Mes
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.month == ahora.month &&
                t.fecha.year == ahora.year)
            .toList();
    }
  }

  List<double> _generateMonthlyData() {
    return List.generate(6, (index) {
      final mes = DateTime.now().month - (5 - index);
      final ano = DateTime.now().year;
      if (mes <= 0) {
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.month == mes + 12 &&
                t.fecha.year == ano - 1)
            .fold(0.0, (sum, item) => sum + item.monto);
      } else {
        return widget.listaDeTransacciones
            .where((t) =>
                t.tipo == 'ingreso' &&
                t.fecha.month == mes &&
                t.fecha.year == ano)
            .fold(0.0, (sum, item) => sum + item.monto);
      }
    });
  }

  String _obtenerNombreCategoria(String categoriaId) {
    try {
      return widget.listaDeCategorias.firstWhere((c) => c.id == categoriaId).nombre;
    } catch (e) {
      return 'Sin Categoría';
    }
  }

  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return currencyFormat.format(monto);
  }

  String _getMonthName(int monthIndex) {
    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN'];
    return months[monthIndex];
  }

  void _navigateToCategoryDetail(String categoriaNombre, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomeCategoryDetailScreen(
          categoriaNombre: categoriaNombre,
          listaDeTransacciones: widget.listaDeTransacciones,
          listaDeCategorias: widget.listaDeCategorias,
          periodoSeleccionado: _selectedPeriod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedCategorias = _ingresosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Ingresos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance para el botón de atrás
                ],
              ),
            ),

            // Selector de período
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: ['Semana', 'Mes', 'Año'].map((period) {
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
                                ? (isDark ? Theme.of(context).primaryColor : Colors.white)
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
            ),

            // Contenido principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Resumen de ingresos
                    _buildIncomeSummary(isDark),
                    const SizedBox(height: 24),
                    
                    // Gráfico
                    _buildChart(isDark),
                    const SizedBox(height: 24),
                    
                    // Categorías
                    _buildCategoriesSection(sortedCategorias, isDark),
                    const SizedBox(height: 20), // Espacio inferior reducido
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSummary(bool isDark) {
    return Container(
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
          Text(
            'Ingresos totales',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatoMoneda(_totalIngresado),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'vs ${_selectedPeriod.toLowerCase()} anterior',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_porcentajeVariacion >= 0 ? '+' : ''}${_porcentajeVariacion.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _esVariacionPositiva ? Theme.of(context).primaryColor : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    return Container(
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
          Text(
            'Tendencia de Ingresos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _getMonthName(value.toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _monthlyData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(List<MapEntry<String, double>> sortedCategorias, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: sortedCategorias.asMap().entries.map((entry) {
              final index = entry.key;
              final categoria = entry.value;
              final isLast = index == sortedCategorias.length - 1;
              
              return GestureDetector(
                onTap: () => _navigateToCategoryDetail(categoria.key, isDark),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: isLast ? null : Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          categoria.key,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatoMoneda(categoria.value),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
