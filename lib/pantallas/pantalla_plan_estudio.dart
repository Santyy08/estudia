import 'package:flutter/material.dart';

class PantallaPlanEstudio extends StatelessWidget {
  const PantallaPlanEstudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan de Estudio')),
      body: Center(
        child: Container(
          height: 150,
          width: 600,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE7FB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "este es el plan de estudio",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
