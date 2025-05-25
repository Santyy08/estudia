import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'pantalla_plan_estudio.dart';
import 'pantalla_asistente_ia.dart';
import 'pantalla_objetivos.dart';
import 'pantalla_tecnicas.dart';
import 'pantalla_calendario.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hola, Juan!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bienvenido a EstudIA 📚',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PantallaCalendario(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE7FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 32,
                        color: Color(0xFF4C63B6),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoy es ${DateFormat('EEEE, d \'de\' MMMM').format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Estudias: 3 materias'),
                          Text('Total: 2 h 30 min'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildOpcion(
                      context,
                      icon: Icons.list_alt,
                      color: const Color(0xFFB8E8E1),
                      label: 'Plan de\nestudio',
                      page: const PantallaPlanEstudio(),
                    ),
                    _buildOpcion(
                      context,
                      icon: Icons.smart_toy,
                      color: const Color(0xFFDCD7FB),
                      label: 'Asistente\nIA',
                      page: const PantallaAsistenteIA(),
                    ),
                    _buildOpcion(
                      context,
                      icon: Icons.track_changes,
                      color: const Color(0xFFD4F4D7),
                      label: 'Objetivos',
                      page: const PantallaObjetivos(),
                    ),
                    _buildOpcion(
                      context,
                      icon: Icons.psychology,
                      color: const Color(0xFFE4D7FB),
                      label: 'Técnicas de\nestudio',
                      page: const PantallaTecnicasEstudio(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DA5F4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Planear mi día →',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcion(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required Widget page,
  }) {
    return GestureDetector(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
