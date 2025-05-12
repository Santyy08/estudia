import 'package:flutter/material.dart';

class PantallaObjetivos extends StatelessWidget {
  const PantallaObjetivos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objetivos')),
      body: const Center(child: Text('Lista de objetivos del usuario')),
    );
  }
}