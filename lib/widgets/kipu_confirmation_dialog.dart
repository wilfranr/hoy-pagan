import 'package:flutter/material.dart';
import 'package:kipu/widgets/kipu_colors.dart';

/// Widget personalizado para mostrar diálogos de confirmación con la mascota Kipu animada
class KipuConfirmationDialog extends StatefulWidget {
  /// Título de la pregunta (ej. "¿Ya pagaste este gasto?")
  final String titulo;
  
  /// Descripción de la transacción
  final String descripcion;
  
  /// Monto de la transacción
  final String monto;
  
  /// Frecuencia o información adicional
  final String? frecuencia;
  
  /// Texto del botón de confirmación positiva
  final String textoBotonSi;
  
  /// Texto del botón de confirmación negativa
  final String textoBotonNo;
  
  /// Función callback para cuando se presiona "Sí"
  final VoidCallback onConfirmar;
  
  /// Función callback para cuando se presiona "No"
  final VoidCallback onCancelar;

  const KipuConfirmationDialog({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.monto,
    this.frecuencia,
    this.textoBotonSi = 'Sí',
    this.textoBotonNo = 'No',
    required this.onConfirmar,
    required this.onCancelar,
  });

  @override
  State<KipuConfirmationDialog> createState() => _KipuConfirmationDialogState();
}

class _KipuConfirmationDialogState extends State<KipuConfirmationDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para la animación de rebote vertical
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animación de rebote suave
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Animación de movimiento lateral sutil
    _wiggleAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar la animación en bucle
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Ajustar el ancho máximo según el tamaño de pantalla
    final maxWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.9;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          color: KipuColors.tarjetaOscura,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: KipuColors.bordeModal,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascota Kipu animada
              _buildKipuAnimation(),
              
              SizedBox(height: screenWidth > 600 ? 20 : 16),
              
              // Título de la pregunta
              Text(
                widget.titulo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: KipuColors.textoPrincipalModal,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screenWidth > 600 ? 16 : 12),
              
              // Detalles de la transacción
              _buildTransactionDetails(),
              
              SizedBox(height: screenWidth > 600 ? 24 : 20),
              
              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la animación de la mascota Kipu
  Widget _buildKipuAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final kipuSize = screenWidth > 600 ? 100.0 : 80.0;
        
        return Transform.translate(
          offset: Offset(
            _wiggleAnimation.value * (0.5 - (_animationController.value % 1)),
            -_bounceAnimation.value,
          ),
          child: Container(
            height: kipuSize,
            width: kipuSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kipuSize / 2),
              boxShadow: [
                BoxShadow(
                  color: KipuColors.tealKipu.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(kipuSize / 2),
              child: Image.asset(
                'assets/images/logo_kipu.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si la imagen no se encuentra
                  return Container(
                    decoration: BoxDecoration(
                      color: KipuColors.tealKipu.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(kipuSize / 2),
                    ),
                    child: Icon(
                      Icons.pets,
                      size: kipuSize * 0.5,
                      color: KipuColors.tealKipu,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye los detalles de la transacción
  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KipuColors.fondoModal.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KipuColors.bordeModal,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.descripcion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: KipuColors.textoPrincipalModal,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: KipuColors.tealKipu,
              ),
              const SizedBox(width: 4),
              Text(
                widget.monto,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: KipuColors.tealKipu,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          if (widget.frecuencia != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: KipuColors.textoSecundarioModal,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.frecuencia!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: KipuColors.textoSecundarioModal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    
    return Row(
      children: [
        // Botón "No"
        Expanded(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCancelar();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isWideScreen ? 12 : 10,
                horizontal: isWideScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.textoBotonNo,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: KipuColors.textoSecundarioClaro,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        SizedBox(width: isWideScreen ? 12 : 8),
        
        // Botón "Sí"
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onConfirmar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KipuColors.tealKipu,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isWideScreen ? 12 : 10,
                horizontal: isWideScreen ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              widget.textoBotonSi,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
