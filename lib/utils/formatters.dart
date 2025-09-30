import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formateador que agrega separadores de miles (.) para el locale colombiano
/// mientras el usuario escribe. Solo maneja enteros (sin decimales).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('es_CO');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = _formatter.format(int.parse(raw));

    // Colocar el cursor al final del texto formateado.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Convierte un texto con separadores de miles a double.
/// Se permiten únicamente dígitos; cualquier otro carácter es ignorado.
double parseMonto(String value) {
  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return 0;
  return double.parse(digitsOnly);
}


