import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaSemana extends StatefulWidget {
  const VistaSemana({super.key});

  @override
  State<VistaSemana> createState() => _VistaSemanaState();
}

class _VistaSemanaState extends State<VistaSemana> {
  DateTime _startOfWeek = _getStartOfWeek(DateTime.now());
  final Map<DateTime, List<Map<String, dynamic>>> _tareas = {};

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _agregarTarea(BuildContext context, DateTime fecha) {
    final tipoController = TextEditingController();
    final contenidoController = TextEditingController();
    final horaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tipoController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo (Clase, Tarea, Objetivo)',
                    ),
                  ),
                  TextField(
                    controller: contenidoController,
                    decoration: const InputDecoration(labelText: 'Contenido'),
                  ),
                  TextField(
                    controller: horaController,
                    decoration: const InputDecoration(
                      labelText: 'Hora (opcional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final tipo = tipoController.text.trim();
                      final contenido = contenidoController.text.trim();
                      final hora = horaController.text.trim();
                      if (tipo.isNotEmpty && contenido.isNotEmpty) {
                        final tarea = {
                          'tipo': tipo,
                          'contenido': contenido,
                          'hora': hora.isNotEmpty ? hora : null,
                          'icono': Icons.circle,
                          'color':
                              tipo.toLowerCase() == 'tarea'
                                  ? Colors.teal
                                  : tipo.toLowerCase() == 'objetivo'
                                  ? Colors.green
                                  : Colors.grey,
                        };
                        setState(() {
                          _tareas[fecha] = [...?_tareas[fecha], tarea];
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTareaCard(Map<String, dynamic> tarea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(tarea['icono'], color: tarea['color'], size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarea['tipo'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(tarea['contenido'], overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
          if (tarea['hora'] != null)
            Text(tarea['hora'], style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diasSemana = List.generate(
      7,
      (i) => _startOfWeek.add(Duration(days: i)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana - EstudIA'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _startOfWeek = _startOfWeek.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diasSemana.length,
        itemBuilder: (context, index) {
          final dia = diasSemana[index];
          final tareas = _tareas[dia] ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE d MMM', 'es_ES').format(dia),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.teal,
                    ),
                    onPressed: () => _agregarTarea(context, dia),
                  ),
                ],
              ),
              if (tareas.isEmpty)
                const Text(
                  "No hay tareas",
                  style: TextStyle(color: Colors.grey),
                ),
              ...tareas.map(_buildTareaCard),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
