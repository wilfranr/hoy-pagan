import 'package:uuid/uuid.dart';

class Categoria {
  String id;
  String nombre;
  String tipo; // 'ingreso' o 'gasto'
  int icono; // codePoint del IconData

  Categoria({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.icono,
  });

  // Constructor factory para crear Categoria desde JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      icono: json['icono'] as int,
    );
  }

  // Método para convertir Categoria a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'icono': icono,
    };
  }

  // Constructor para crear una nueva categoría con ID único
  factory Categoria.nueva({
    required String nombre,
    required String tipo,
    required int icono,
  }) {
    return Categoria(
      id: const Uuid().v4(),
      nombre: nombre,
      tipo: tipo,
      icono: icono,
    );
  }
}
