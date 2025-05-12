import 'package:flutter/material.dart';
import 'pantallas/pantalla_inicio.dart';

void main() {
  runApp(const EstudIAApp());
}

class EstudIAApp extends StatelessWidget {
  const EstudIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EstudIA',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        useMaterial3: true, // Opcional, si estás usando Material 3
      ),
      home: const PantallaInicio(),
    );
  }
}
