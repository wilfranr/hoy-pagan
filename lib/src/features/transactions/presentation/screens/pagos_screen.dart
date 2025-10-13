import 'package:flutter/material.dart';
import 'package:kipu/src/shared/utils/formatters.dart';
import 'package:kipu/src/features/transactions/data/models/gasto_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';
import 'package:kipu/src/features/transactions/data/models/pago_pendiente_model.dart';

class PagosScreen extends StatefulWidget {
  final List<Gasto> listaDeGastos;
  final List<Categoria> listaDeCategorias;
  final List<PagoPendiente> listaDePagosPendientes;
  final Function(PagoPendiente, double, String) onPagoCompletado;

  const PagosScreen({
    super.key,
    required this.listaDeGastos,
    required this.listaDeCategorias,
    required this.listaDePagosPendientes,
    required this.onPagoCompletado,
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
    // Combinar gastos pendientes y pagos pendientes
    final gastosPendientes = widget.listaDeGastos.where((gasto) => !gasto.pagado).toList();
    final pagosPendientes = widget.listaDePagosPendientes.where((pago) => !pago.pagado).toList();
    
    if (gastosPendientes.isEmpty && pagosPendientes.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumenCard(gastosPendientes, pagosPendientes),
          const SizedBox(height: 24),
          if (pagosPendientes.isNotEmpty) ...[
            _buildPagosPendientesSection(pagosPendientes),
            const SizedBox(height: 24),
          ],
          if (gastosPendientes.isNotEmpty) ...[
            _buildProximosVencimientos(gastosPendientes),
            const SizedBox(height: 24),
            _buildCategoriasSection(gastosPendientes),
          ],
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

  Widget _buildResumenCard(List<Gasto> gastosPendientes, List<PagoPendiente> pagosPendientes) {
    final totalGastos = gastosPendientes.fold<double>(0.0, (sum, gasto) => sum + gasto.monto);
    final totalPagos = pagosPendientes.fold<double>(0.0, (sum, pago) => sum + pago.montoActual);
    final totalGeneral = totalGastos + totalPagos;

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
              formatoMoneda(totalGeneral),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (pagosPendientes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${pagosPendientes.length} pagos recurrentes pendientes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagosPendientesSection(List<PagoPendiente> pagosPendientes) {
    // Ordenar pagos por fecha de vencimiento
    pagosPendientes.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pagos Recurrentes Pendientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pagosPendientes.length,
          itemBuilder: (context, index) {
            final pago = pagosPendientes[index];
            final venceHoy = pago.venceHoy;
            final estaVencido = pago.estaVencido;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: venceHoy 
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: colorAzulPagos,
                      width: 2,
                    ),
                  )
                : null,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorForCategoria(pago.categoriaId).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getIconForCategoria(pago.categoriaId),
                    color: _getColorForCategoria(pago.categoriaId),
                    size: 20,
                  ),
                ),
                title: Text(
                  pago.descripcion,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto estimado: ${formatoMoneda(pago.montoEstimado)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venceHoy 
                        ? 'Vence Hoy'
                        : estaVencido
                          ? 'Vencido'
                          : 'Vence: ${_formatearFecha(pago.fechaVencimiento)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: venceHoy 
                          ? colorAzulPagos 
                          : estaVencido 
                            ? Colors.red 
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: venceHoy || estaVencido ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (pago.datosFijos.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatearDatosFijos(pago.datosFijos),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _mostrarDetallesPago(pago),
              ),
            );
          },
        ),
      ],
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _formatearDatosFijos(Map<String, dynamic> datosFijos) {
    if (datosFijos.isEmpty) return '';
    
    final List<String> partes = [];
    datosFijos.forEach((key, value) {
      if (value.toString().isNotEmpty) {
        partes.add('${_capitalizar(key)}: $value');
      }
    });
    
    return partes.join(', ');
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  void _mostrarDetallesPago(PagoPendiente pago) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallesPagoModal(pago),
    );
  }

  Widget _buildDetallesPagoModal(PagoPendiente pago) {
    final montoController = TextEditingController(text: pago.montoEstimado.toString());
    final referenciaController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalles del Pago',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Información fija
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Fija',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Descripción: ${pago.descripcion}'),
                    Text('Tipo: ${pago.tipoDeGasto}'),
                    if (pago.datosFijos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Datos adicionales:'),
                      ...pago.datosFijos.entries.map((entry) => 
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text('${_capitalizar(entry.key)}: ${entry.value}'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Campos editables
            Text(
              'Información del Mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Campo de monto
            TextField(
              controller: montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto Real',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo de referencia
            TextField(
              controller: referenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia/Número de Factura',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botón de completar pago
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final montoReal = double.tryParse(montoController.text) ?? pago.montoEstimado;
                  final referencia = referenciaController.text.trim();
                  
                  widget.onPagoCompletado(pago, montoReal, referencia);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAzulPagos,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Marcar como Pagado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
