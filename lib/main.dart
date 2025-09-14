import 'package:flutter/material.dart';
import 'package:hoypagan/screens/home_screen.dart'; // Corregido para reflejar el nombre del paquete

void main() {
  // Asegura que los bindings de Flutter estén inicializados antes de usar paquetes.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}