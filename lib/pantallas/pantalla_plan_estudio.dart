import 'package:flutter/material.dart';

class PantallaPlanEstudio extends StatelessWidget {
  const PantallaPlanEstudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan de Estudio')),
      body: const Center(child: Text('Contenido del plan de estudio')),
    );
  }
}