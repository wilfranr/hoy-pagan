import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kipu/src/features/user_profile/data/models/usuario_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _estadoSeleccionado;
  String? _ciudadSeleccionada;
  int? _mesSeleccionado;
  int? _diaSeleccionado;
  int? _anoSeleccionado;

  // Listas de opciones
  final List<String> _estados = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche',
    'Chiapas', 'Chihuahua', 'Ciudad de México', 'Coahuila', 'Colima',
    'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'México',
    'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla',
    'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa', 'Sonora',
    'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'
  ];

  final List<String> _ciudades = [
    'Ciudad de México', 'Guadalajara', 'Monterrey', 'Puebla', 'Tijuana',
    'León', 'Juárez', 'Torreón', 'Querétaro', 'San Luis Potosí',
    'Mérida', 'Mexicali', 'Aguascalientes', 'Acapulco', 'Cuernavaca',
    'Saltillo', 'Hermosillo', 'Villahermosa', 'Culiacán', 'Morelia'
  ];

  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  final List<int> _dias = List.generate(31, (index) => index + 1);
  final List<int> _anos = List.generate(100, (index) => DateTime.now().year - 18 - index);

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioJson = prefs.getString('usuario');
    if (usuarioJson != null) {
      final usuario = Usuario.fromJson(json.decode(usuarioJson));
      _nombreController.text = usuario.nombre;
      _emailController.text = usuario.email;
      _telefonoController.text = usuario.telefono;
      _estadoSeleccionado = usuario.estado;
      _ciudadSeleccionada = usuario.ciudad;
      _mesSeleccionado = usuario.fechaNacimiento.month;
      _diaSeleccionado = usuario.fechaNacimiento.day;
      _anoSeleccionado = usuario.fechaNacimiento.year;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardarUsuario() async {
    if (_formKey.currentState!.validate()) {
      final usuario = Usuario(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        estado: _estadoSeleccionado!,
        ciudad: _ciudadSeleccionada!,
        fechaNacimiento: DateTime(_anoSeleccionado!, _mesSeleccionado!, _diaSeleccionado!),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', json.encode(usuario.toJson()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu número de teléfono';
    }
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingresa un número de teléfono válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo Nombre
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Email
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                validator: _validarEmail,
              ),
              const SizedBox(height: 20),

              // Campo Teléfono
              TextFormField(
                controller: _telefonoController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                  ),
                ),
                validator: _validarTelefono,
              ),
              const SizedBox(height: 20),

              // Campos Estado y Ciudad
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey[800],
                      items: _estados.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoSeleccionado = value;
                          _ciudadSeleccionada = null; // Resetear ciudad
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona un estado';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _ciudadSeleccionada,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey[800],
                      items: _ciudades.map((ciudad) {
                        return DropdownMenuItem(
                          value: ciudad,
                          child: Text(ciudad, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _ciudadSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona una ciudad';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fecha de nacimiento
              const Text(
                'Date of birth',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _mesSeleccionado,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey[800],
                      items: _meses.asMap().entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key + 1,
                          child: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _mesSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Mes';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _diaSeleccionado,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey[800],
                      items: _dias.map((dia) {
                        return DropdownMenuItem(
                          value: dia,
                          child: Text(
                            dia.toString().padLeft(2, '0'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _diaSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Día';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _anoSeleccionado,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
                        ),
                      ),
                      dropdownColor: Colors.grey[800],
                      items: _anos.map((ano) {
                        return DropdownMenuItem(
                          value: ano,
                          child: Text(
                            ano.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _anoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Ano';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Botón Confirmar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _guardarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Texto de términos
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    children: [
                      TextSpan(text: 'By confirming you agree to all '),
                      TextSpan(
                        text: 'terms',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
