import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    final String mes = DateFormat('MMMM', 'es_ES').format(_focusedMonth);
    final int year = _focusedMonth.year;
    final tareasDelDia = _tareas[_selectedDate] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario EstudIA'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () {
              Navigator.pushNamed(context, '/semana');
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_agenda),
            onPressed: () {
              Navigator.pushNamed(context, '/agenda');
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
                    '${mes[0].toUpperCase()}${mes.substring(1)} $year',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildCalendar(),
              const SizedBox(height: 16),
              if (_selectedDate != null)
                Expanded(
                  child:
                      tareasDelDia.isEmpty
                          ? const Center(
                            child: Text('No hay tareas para este día.'),
                          )
                          : ListView(
                            children:
                                tareasDelDia
                                    .map((tarea) => _buildCard(tarea))
                                    .toList(),
                          ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoTarea(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
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
            ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                .map(
                  (d) => Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
          final bool isSelected =
              _selectedDate != null &&
              currentDay.difference(_selectedDate!).inDays == 0;
          week.add(
            GestureDetector(
              onTap: () => setState(() => _selectedDate = currentDay),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.teal[200] : null,
                ),
                alignment: Alignment.center,
                height: 36,
                child: Text('$day'),
              ),
            ),
          );
        } else {
          week.add(const SizedBox());
        }
        day++;
      }
      rows.add(TableRow(children: week));
      if (day > daysInMonth) break;
    }

    return Table(children: rows);
  }

  Widget _buildCard(Map<String, dynamic> tarea) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          tarea['icono'] ?? Icons.book,
          color: tarea['color'] ?? Colors.grey,
        ),
        title: Text(tarea['tipo'] ?? 'Tarea'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tarea['contenido'] ?? ''),
            if (tarea['hora'] != null)
              Text(
                'Hora: ${tarea['hora']}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoTarea(BuildContext context) {
    final tipoController = TextEditingController();
    final contenidoController = TextEditingController();
    final horaController = TextEditingController();
    Color colorSeleccionado = Colors.teal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (Ej: Clase, Tarea)',
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
                Row(
                  children: [
                    const Text('Color:'),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap:
                          () => setState(() => colorSeleccionado = Colors.teal),
                      child: CircleAvatar(backgroundColor: Colors.teal),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap:
                          () =>
                              setState(() => colorSeleccionado = Colors.purple),
                      child: CircleAvatar(backgroundColor: Colors.purple),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap:
                          () =>
                              setState(() => colorSeleccionado = Colors.orange),
                      child: CircleAvatar(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDate == null) return;
                    final tarea = {
                      'tipo': tipoController.text.trim(),
                      'contenido': contenidoController.text.trim(),
                      'hora': horaController.text.trim(),
                      'icono': Icons.circle,
                      'color': colorSeleccionado,
                    };
                    setState(() {
                      _tareas[_selectedDate!] = [
                        ...?_tareas[_selectedDate],
                        tarea,
                      ];
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Agregar Tarea'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
