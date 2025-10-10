import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';

class ExpenseDashboardScreen extends StatefulWidget {
  final List<Transaccion> listaDeTransacciones;
  final List<Categoria> listaDeCategorias;

  const ExpenseDashboardScreen({
    super.key,
    required this.listaDeTransacciones,
    required this.listaDeCategorias,
  });

  @override
  State<ExpenseDashboardScreen> createState() => _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState extends State<ExpenseDashboardScreen> {
  late List<Transaccion> _gastos;
  late double _totalGastado;
  late Map<String, double> _gastosPorCategoria;

  @override
  void initState() {
    super.initState();
    _procesarDatos();
  }

  void _procesarDatos() {
    final ahora = DateTime.now();
    // Filtrar solo los gastos de este mes
    _gastos = widget.listaDeTransacciones
        .where((t) =>
            t.tipo == 'gasto' &&
            t.fecha.month == ahora.month &&
            t.fecha.year == ahora.year)
        .toList();

    // Calcular el total gastado
    _totalGastado = _gastos.fold(0.0, (sum, item) => sum + item.monto);

    // Agrupar gastos por categoría
    _gastosPorCategoria = {};
    for (var gasto in _gastos) {
      final categoriaNombre = _obtenerNombreCategoria(gasto.categoriaId);
      _gastosPorCategoria.update(
        categoriaNombre,
        (value) => value + gasto.monto,
        ifAbsent: () => gasto.monto,
      );
    }
  }

  String _obtenerNombreCategoria(String categoriaId) {
    try {
      return widget.listaDeCategorias.firstWhere((c) => c.id == categoriaId).nombre;
    } catch (e) {
      return 'Sin Categoría';
    }
  }

  IconData _obtenerIconoCategoria(String categoriaId) {
    try {
      final categoria = widget.listaDeCategorias.firstWhere((c) => c.id == categoriaId);
      return IconData(categoria.icono, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.help_outline;
    }
  }

  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return currencyFormat.format(monto);
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategorias = _gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Gastos'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildResumenCard(),
          const SizedBox(height: 24),
          _buildChartPlaceholder(),
          const SizedBox(height: 24),
          _buildGastosPorCategoriaList(sortedCategorias),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Gastado este Mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              formatoMoneda(_totalGastado),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribución de Gastos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Gráfica Próximamente',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGastosPorCategoriaList(List<MapEntry<String, double>> sortedCategorias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desglose por Categoría',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (sortedCategorias.isEmpty)
          const Center(child: Text('No hay gastos este mes.'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategorias.length,
            itemBuilder: (context, index) {
              final entry = sortedCategorias[index];
              final categoriaNombre = entry.key;
              final monto = entry.value;
              final porcentaje = _totalGastado > 0 ? (monto / _totalGastado) * 100 : 0;
              final categoriaId = widget.listaDeCategorias.firstWhere((c) => c.nombre == categoriaNombre, orElse: () => Categoria.nueva(nombre: '', tipo: '', icono: 0)).id;

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(_obtenerIconoCategoria(categoriaId), color: Theme.of(context).colorScheme.primary),
                  title: Text(categoriaNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${porcentaje.toStringAsFixed(1)}% del total'),
                  trailing: Text(
                    formatoMoneda(monto),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
      ],
    );
  }
}
