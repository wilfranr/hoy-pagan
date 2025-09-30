import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemeFromPreferences();
  }
  
  // Cargar la preferencia del tema guardada
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      // Si hay error, usar el tema del sistema por defecto
      _themeMode = ThemeMode.system;
    }
  }
  
  // Establecer el tema y guardarlo en preferencias
  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Si hay error al guardar, no hacer nada
      // El tema ya se cambió en memoria
    }
  }
  
  // Obtener el tema actual basado en el modo
  ThemeData getCurrentTheme(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppThemes.lightTheme;
      case ThemeMode.dark:
        return AppThemes.darkTheme;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark
            ? AppThemes.darkTheme
            : AppThemes.lightTheme;
    }
  }
  
  // Verificar si el tema actual es oscuro
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
  
  // Obtener el nombre del tema actual
  String getCurrentThemeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
