import 'package:flutter/material.dart';

class PantallaTecnicasEstudio extends StatelessWidget {
  const PantallaTecnicasEstudio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Técnicas de Estudio')),
      body: const Center(
        child: Text('Métodos y técnicas de estudio recomendadas'),
      ),
    );
  }
}
