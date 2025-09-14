import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema de la Aplicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona el tema',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Elige un tema para tu aplicación. Claro, oscuro o usa el mismo tema que has elegido en la configuración del sistema.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Opciones de tema
                Text(
                  'Opciones de tema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                // Opción Claro
                Card(
                  child: RadioListTile<ThemeMode>(
                    title: const Text('Claro'),
                    subtitle: const Text('Tema claro con fondo blanco'),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setTheme(value);
                      }
                    },
                    secondary: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 2,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 16,
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Opción Oscuro
                Card(
                  child: RadioListTile<ThemeMode>(
                    title: const Text('Oscuro'),
                    subtitle: const Text('Tema oscuro con fondo negro'),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setTheme(value);
                      }
                    },
                    secondary: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 2,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 16,
                            height: 2,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Opción Sistema
                Card(
                  child: RadioListTile<ThemeMode>(
                    title: const Text('Sistema'),
                    subtitle: const Text('Sigue la configuración del sistema'),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        themeProvider.setTheme(value);
                      }
                    },
                    secondary: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          // Lado claro
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 8,
                                    height: 1,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Lado oscuro
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 8,
                                    height: 1,
                                    color: Colors.grey.shade500,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Información adicional
                Card(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El tema seleccionado se aplicará inmediatamente y se guardará para futuras sesiones.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
