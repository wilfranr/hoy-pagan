import 'package:flutter/material.dart';

class AppThemes {
  // Color principal de la aplicación (verde azulado)
  static const Color primaryColor = Color(0xFF00C896);
  static const Color primaryColorDark = Color(0xFF00A67A);
  
  // Colores para el tema claro
  static const Color lightScaffoldBackground = Color(0xFFF5F7F8);
  static const Color lightCardBackground = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  
  // Colores para el tema oscuro
  static const Color darkScaffoldBackground = Color(0xFF101922);
  static const Color darkCardBackground = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  
  // Color de acento para saldos positivos
  static const Color positiveAmountColor = Color(0xFF00C896);
  static const Color negativeAmountColor = Color(0xFFFF3B30);
  
  // Colores para dividers y bordes
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color darkDividerColor = Color(0xFF3A3A3A);

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightScaffoldBackground,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      cardColor: lightCardBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColorDark,
        surface: lightCardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        outline: lightDividerColor,
      ),
      dividerColor: lightDividerColor,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: lightTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightTextPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: lightTextSecondary,
          fontSize: 12,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardBackground,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffoldBackground,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      cardColor: darkCardBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColorDark,
        surface: darkCardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        outline: darkDividerColor,
      ),
      dividerColor: darkDividerColor,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: darkTextSecondary,
          fontSize: 12,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Función auxiliar para crear MaterialColor desde Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.r.round(), g = color.g.round(), b = color.b.round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
