import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaAgenda extends StatefulWidget {
  const VistaAgenda({super.key});

  @override
  State<VistaAgenda> createState() => _VistaAgendaState();
}

class _VistaAgendaState extends State<VistaAgenda> {
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> _tareas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agenda")),
      body: Column(
        children: [_buildWeekCalendar(), const Divider(), _buildTareasDia()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoTarea(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final inicioSemana = _focusedDay.subtract(
      Duration(days: _focusedDay.weekday - 1),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dia = inicioSemana.add(Duration(days: index));
        final seleccionado =
            _selectedDate != null && _esMismoDia(dia, _selectedDate!);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = dia;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: seleccionado ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat.E().format(dia),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${dia.day}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTareasDia() {
    final tareas = _selectedDate != null ? _tareas[_selectedDate!] ?? [] : [];
    return Expanded(
      child:
          tareas.isEmpty
              ? const Center(child: Text("Sin tareas para este día."))
              : ListView.builder(
                itemCount: tareas.length,
                itemBuilder: (context, index) {
                  final tarea = tareas[index];
                  return GestureDetector(
                    onLongPress:
                        () => _mostrarDialogoTarea(
                          context,
                          tareaExistente: tarea,
                        ),
                    child: _buildCard(
                      tarea['tipo'],
                      tarea['contenido'],
                      hora: tarea['hora'],
                      icono: tarea['icono'],
                      color: tarea['color'],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildCard(
    String titulo,
    String subtitulo, {
    IconData? icono,
    String? hora,
    Color? color,
  }) {
    return Card(
      color: color ?? Colors.teal[100],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icono ?? Icons.book, color: Colors.black54),
        title: Text(titulo),
        subtitle: Text('$subtitulo${hora != null ? '\n$hora' : ''}'),
      ),
    );
  }

  void _mostrarDialogoTarea(
    BuildContext context, {
    Map<String, dynamic>? tareaExistente,
  }) {
    final tipoController = TextEditingController(
      text: tareaExistente?['tipo'] ?? '',
    );
    final contenidoController = TextEditingController(
      text: tareaExistente?['contenido'] ?? '',
    );
    final horaController = TextEditingController(
      text: tareaExistente?['hora'] ?? '',
    );
    Color colorSeleccionado = tareaExistente?['color'] ?? Colors.teal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  children: [
                    TextField(
                      controller: tipoController,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                    ),
                    TextField(
                      controller: contenidoController,
                      decoration: const InputDecoration(labelText: 'Contenido'),
                    ),
                    TextField(
                      controller: horaController,
                      decoration: const InputDecoration(labelText: 'Hora'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorOpcion(Colors.teal, colorSeleccionado, (color) {
                          setState(() => colorSeleccionado = color);
                        }),
                        _colorOpcion(Colors.red, colorSeleccionado, (color) {
                          setState(() => colorSeleccionado = color);
                        }),
                        _colorOpcion(Colors.orange, colorSeleccionado, (color) {
                          setState(() => colorSeleccionado = color);
                        }),
                        _colorOpcion(Colors.blue, colorSeleccionado, (color) {
                          setState(() => colorSeleccionado = color);
                        }),
                        _colorOpcion(Colors.purple, colorSeleccionado, (color) {
                          setState(() => colorSeleccionado = color);
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final tipo = tipoController.text.trim();
                        final contenido = contenidoController.text.trim();
                        final hora = horaController.text.trim();

                        if (tipo.isNotEmpty &&
                            contenido.isNotEmpty &&
                            _selectedDate != null) {
                          final nuevaTarea = {
                            'tipo': tipo,
                            'contenido': contenido,
                            'hora': hora.isNotEmpty ? hora : null,
                            'icono': Icons.circle,
                            'color': colorSeleccionado,
                          };

                          setState(() {
                            final lista = _tareas[_selectedDate!] ?? [];
                            if (tareaExistente != null) {
                              final index = lista.indexOf(tareaExistente);
                              lista[index] = nuevaTarea;
                            } else {
                              lista.add(nuevaTarea);
                            }
                            _tareas[_selectedDate!] = lista;
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        tareaExistente != null ? 'Guardar Cambios' : 'Agregar',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _colorOpcion(
    Color color,
    Color colorSeleccionado,
    void Function(Color) onSelected,
  ) {
    return GestureDetector(
      onTap: () => onSelected(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color:
                color == colorSeleccionado ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        width: 30,
        height: 30,
      ),
    );
  }

  bool _esMismoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
