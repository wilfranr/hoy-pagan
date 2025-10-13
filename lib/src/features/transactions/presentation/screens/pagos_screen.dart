import 'package:flutter/material.dart';
import 'package:kipu/src/shared/utils/formatters.dart';
import 'package:kipu/src/features/transactions/data/models/gasto_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';

class PagosScreen extends StatefulWidget {
  final List<Gasto> listaDeGastos;
  final List<Categoria> listaDeCategorias;

  const PagosScreen({
    super.key,
    required this.listaDeGastos,
    required this.listaDeCategorias,
  });

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  // Color azul de Pagos de la paleta Kipu
  static const Color colorAzulPagos = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar funcionalidad para agregar nuevo pago
        },
        backgroundColor: colorAzulPagos,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    // Filtrar gastos que no están pagados
    final gastosPendientes = widget.listaDeGastos.where((gasto) => !gasto.pagado).toList();
    
    if (gastosPendientes.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumenCard(),
          const SizedBox(height: 24),
          _buildProximosVencimientos(gastosPendientes),
          const SizedBox(height: 24),
          _buildCategoriasSection(gastosPendientes),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo_kipu.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          Text(
            '¡Todo en orden! No tienes pagos próximos.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    final gastosDelMes = widget.listaDeGastos
        .where((gasto) => !gasto.pagado)
        .fold<double>(0.0, (sum, gasto) => sum + gasto.monto);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Pagos del Mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatoMoneda(gastosDelMes),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximosVencimientos(List<Gasto> gastosPendientes) {
    // Ordenar gastos por día de pago
    gastosPendientes.sort((a, b) => a.diaDePago.compareTo(b.diaDePago));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos Vencimientos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gastosPendientes.length,
            itemBuilder: (context, index) {
              final gasto = gastosPendientes[index];
              final hoy = DateTime.now().day;
              final venceHoy = gasto.diaDePago == hoy;
              
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  shape: venceHoy 
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: colorAzulPagos,
                          width: 2,
                        ),
                      )
                    : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getIconForCategoria(gasto.categoriaId),
                              color: _getColorForCategoria(gasto.categoriaId),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gasto.nombre,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatoMoneda(gasto.monto),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venceHoy 
                            ? 'Vence Hoy'
                            : 'Vence el día ${gasto.diaDePago}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: venceHoy ? colorAzulPagos : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: venceHoy ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriasSection(List<Gasto> gastosPendientes) {
    // Agrupar gastos por categoría
    final Map<String, List<Gasto>> gastosPorCategoria = {};
    
    for (final gasto in gastosPendientes) {
      final categoriaId = gasto.categoriaId;
      if (!gastosPorCategoria.containsKey(categoriaId)) {
        gastosPorCategoria[categoriaId] = [];
      }
      gastosPorCategoria[categoriaId]!.add(gasto);
    }

    // Separar en servicios y suscripciones (simplificado)
    final servicios = <String, List<Gasto>>{};
    final suscripciones = <String, List<Gasto>>{};

    gastosPorCategoria.forEach((categoriaId, gastos) {
      final categoriaNombre = _obtenerNombreCategoria(categoriaId);
      if (categoriaNombre.toLowerCase().contains('servicio') || 
          categoriaNombre.toLowerCase().contains('mantenimiento')) {
        servicios[categoriaId] = gastos;
      } else {
        suscripciones[categoriaId] = gastos;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (servicios.isNotEmpty) ...[
          _buildCategoriaList('Servicios', servicios),
          const SizedBox(height: 24),
        ],
        if (suscripciones.isNotEmpty) ...[
          _buildCategoriaList('Suscripciones', suscripciones),
        ],
      ],
    );
  }

  Widget _buildCategoriaList(String titulo, Map<String, List<Gasto>> gastosPorCategoria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gastosPorCategoria.length,
          itemBuilder: (context, index) {
            final categoriaId = gastosPorCategoria.keys.elementAt(index);
            final gastos = gastosPorCategoria[categoriaId]!;
            final gasto = gastos.first; // Tomar el primer gasto como representativo
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorForCategoria(categoriaId).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getIconForCategoria(categoriaId),
                    color: _getColorForCategoria(categoriaId),
                    size: 20,
                  ),
                ),
                title: Text(
                  gasto.nombre,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Último pago: ${formatoMoneda(gasto.monto)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implementar navegación a detalles del pago
                },
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Icons.help;
    try {
      final categoria = widget.listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return IconData(categoria.icono, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.help;
    }
  }

  Color _getColorForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Colors.grey;
    try {
      final categoria = widget.listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return categoria.tipo == 'ingreso' ? Colors.green : Colors.red;
    } catch (e) {
      return Colors.grey;
    }
  }

  String _obtenerNombreCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return 'Sin categoría';
    try {
      final categoria = widget.listaDeCategorias.firstWhere((cat) => cat.id == categoriaId);
      return categoria.nombre;
    } catch (e) {
      return 'Sin categoría';
    }
  }
}
