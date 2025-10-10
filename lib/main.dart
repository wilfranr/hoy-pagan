import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kipu/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}