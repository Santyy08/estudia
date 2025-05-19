import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({super.key});

  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> _tareas = {};

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM').format(_focusedMonth);
    final year = _focusedMonth.year;

    final tareasDelDia = _tareas[_selectedDate] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_day_outlined),
            onPressed: () {
              // Aquí podrías navegar al cronograma diario
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Cronograma del día"),
                      content: Text(
                        "Mostrando cronograma para: ${_selectedDate != null ? DateFormat('dd MMMM yyyy').format(_selectedDate!) : 'ningún día'}",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${toBeginningOfSentenceCase(month)} $year',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            int newMonth = _focusedMonth.month - 1;
                            int newYear = _focusedMonth.year;
                            if (newMonth < 1) {
                              newMonth = 12;
                              newYear -= 1;
                            }
                            _focusedMonth = DateTime(newYear, newMonth);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            int newMonth = _focusedMonth.month + 1;
                            int newYear = _focusedMonth.year;
                            if (newMonth > 12) {
                              newMonth = 1;
                              newYear += 1;
                            }
                            _focusedMonth = DateTime(newYear, newMonth);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 32),
              if (_selectedDate != null && tareasDelDia.isNotEmpty)
                ...tareasDelDia.map(
                  (tarea) => _buildCard(
                    tarea['tipo'],
                    tarea['contenido'],
                    tarea['icono'],
                    tarea['color'],
                    hora: tarea['hora'],
                  ),
                ),
              if (_selectedDate != null && tareasDelDia.isEmpty)
                const Text("No hay tareas para este día."),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoTarea(context),
        backgroundColor: Colors.teal[200],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    List<TableRow> rows = [];

    rows.add(
      TableRow(
        children:
            ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    int day = 1 - firstWeekday;
    for (int i = 0; i < 6; i++) {
      List<Widget> week = [];
      for (int j = 0; j < 7; j++) {
        if (day > 0 && day <= daysInMonth) {
          DateTime currentDay = DateTime(
            _focusedMonth.year,
            _focusedMonth.month,
            day,
          );
          week.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = currentDay;
                });
              },
              child: Container(
                decoration:
                    _selectedDate?.day == day &&
                            _selectedDate?.month == _focusedMonth.month &&
                            _selectedDate?.year == _focusedMonth.year
                        ? BoxDecoration(
                          color: Colors.teal[100],
                          shape: BoxShape.circle,
                        )
                        : null,
                alignment: Alignment.center,
                height: 36,
                child: Text('$day'),
              ),
            ),
          );
        } else {
          week.add(const SizedBox(height: 36));
        }
        day++;
      }
      rows.add(TableRow(children: week));
      if (day > daysInMonth) break;
    }

    return Table(children: rows);
  }

  Widget _buildCard(
    String title,
    String content,
    IconData icon,
    Color color, {
    String? hora,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          if (hora != null)
            Text(
              hora,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoTarea(BuildContext context) {
    final tipoController = TextEditingController();
    final contenidoController = TextEditingController();
    final horaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
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
                    labelText: 'Tipo (Ej: Clase, Tarea, Objetivo)',
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
                    if (tipo.isNotEmpty &&
                        contenido.isNotEmpty &&
                        _selectedDate != null) {
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
                        _tareas[_selectedDate!] = [
                          ...?_tareas[_selectedDate],
                          tarea,
                        ];
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
