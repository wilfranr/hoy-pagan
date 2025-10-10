import 'package:flutter/material.dart';
import 'package:kipu/widgets/kipu_colors.dart';

/// Widget personalizado para mostrar diálogos de confirmación con la mascota Kipu
class KipuPromptDialog extends StatefulWidget {
  /// Ruta de la imagen de la mascota (debe incluir la burbuja de diálogo)
  final String mascotImagePath;
  
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

  const KipuPromptDialog({
    super.key,
    required this.mascotImagePath,
    required this.descripcion,
    required this.monto,
    this.frecuencia,
    this.textoBotonSi = 'Sí',
    this.textoBotonNo = 'No',
    required this.onConfirmar,
    required this.onCancelar,
  });

  @override
  State<KipuPromptDialog> createState() => _KipuPromptDialogState();
}

class _KipuPromptDialogState extends State<KipuPromptDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para la animación de deslizamiento
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Controlador para la animación de desvanecimiento
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Animación de deslizamiento desde abajo
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Animación de desvanecimiento
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    // Iniciar las animaciones
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
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
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: screenHeight * 0.8,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Tarjeta de información (parte inferior)
                    _buildInfoCard(),
                    
                    // Mascota Kipu (parte superior)
                    _buildMascotSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye la sección de la mascota Kipu
  Widget _buildMascotSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final mascotSize = screenWidth > 600 ? 200.0 : 160.0; // Aumentar tamaño significativamente
    
    return Positioned(
      top: -mascotSize * 0.4, // Posicionar más fuera de la tarjeta
      child: Container(
        height: mascotSize,
        width: mascotSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(mascotSize / 2),
          boxShadow: [
            BoxShadow(
              color: KipuColors.tealKipu.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(mascotSize / 2),
          child: Image.asset(
            widget.mascotImagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback si la imagen no se encuentra
              return Container(
                decoration: BoxDecoration(
                  color: KipuColors.tealKipu.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(mascotSize / 2),
                ),
                child: Icon(
                  Icons.pets,
                  size: mascotSize * 0.5,
                  color: KipuColors.tealKipu,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta de información
  Widget _buildInfoCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      margin: EdgeInsets.only(
        top: screenWidth > 600 ? 120 : 100, // Aumentar espacio para la mascota más grande
      ),
      decoration: BoxDecoration(
        color: KipuColors.tarjetaOscura,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: KipuColors.bordeModal,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 24 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Detalles de la transacción
            _buildTransactionDetails(),
            
            SizedBox(height: screenWidth > 600 ? 24 : 20),
            
            // Botones de acción
            _buildActionButtons(),
          ],
        ),
      ),
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
