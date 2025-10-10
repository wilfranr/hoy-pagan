import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kipu/src/features/transactions/data/models/transaccion_model.dart';
import 'package:kipu/src/features/transactions/data/models/categoria_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaccion transaction;
  final List<Categoria> categorias;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categorias,
  });

  String formatoMoneda(double monto) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$', decimalDigits: 0);
    return currencyFormat.format(monto);
  }

  IconData _getIconForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Icons.help;
    final categoria = categorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return IconData(categoria.icono, fontFamily: 'MaterialIcons');
  }

  Color _getColorForCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return Colors.grey;
    final categoria = categorias.firstWhere(
      (cat) => cat.id == categoriaId,
      orElse: () => Categoria.nueva(nombre: 'Sin categoría', tipo: 'gasto', icono: Icons.help.codePoint),
    );
    return categoria.tipo == 'ingreso' ? Colors.green : Colors.red;
  }

  String _obtenerNombreCategoria(String categoriaId) {
    if (categoriaId.isEmpty) return 'Sin categoría';
    try {
      return categorias.firstWhere((cat) => cat.id == categoriaId).nombre;
    } catch (e) {
      return 'Sin categoría';
    }
  }

  @override
  Widget build(BuildContext context) {
    String titulo = '';
    switch (transaction.tipo) {
      case 'ingreso':
        titulo = 'Ingreso Extra';
        break;
      case 'gasto':
        titulo = 'Gasto';
        break;
      case 'ahorro':
        titulo = 'Ahorro';
        break;
      case 'inversion':
        titulo = 'Inversión';
        break;
    }

    final hora = DateFormat('h:mm a', 'es').format(transaction.fecha);
    final nombreCategoria = _obtenerNombreCategoria(transaction.categoriaId);
    final subtitulo = transaction.descripcion == 'Sin descripción' 
        ? hora
        : '${transaction.descripcion} - $hora';
    final monto = transaction.tipo == 'ingreso' ? '+${formatoMoneda(transaction.monto)}' : formatoMoneda(transaction.monto);
    final montoColor = transaction.tipo == 'ingreso' ? Colors.green : Colors.red;
    final icon = _getIconForCategoria(transaction.categoriaId);
    final color = _getColorForCategoria(transaction.categoriaId);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
        trailing: Text(
          monto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: montoColor,
          ),
        ),
      ),
    );
  }
}
