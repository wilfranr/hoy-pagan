import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kipu/app.dart';
import 'package:kipu/src/services/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}
