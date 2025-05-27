// lib/vista_calendario/vista_mes.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
import '../widgets/editar_evento_form.dart';

class VistaMes extends StatefulWidget {
  const VistaMes({Key? key}) : super(key: key);

  @override
  State<VistaMes> createState() => _VistaMesState();
}

class _VistaMesState extends State<VistaMes> {
  late final ValueNotifier<List<TarjetaEventos>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = context.read<CalendarioProvider>().fechaSeleccionada;
    _focusedDay =
        _selectedDay!; // Iniciar focusedDay con la fecha seleccionada del provider
    _selectedEvents = ValueNotifier(
      _getEventsForDay(context.read<CalendarioProvider>().fechaSeleccionada),
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<TarjetaEventos> _getEventsForDay(DateTime day) {
    return context.read<CalendarioProvider>().eventosDelDia(day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<CalendarioProvider>().cambiarFechaSeleccionada(selectedDay);
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        // Sincronizar _selectedDay y _focusedDay con el provider
        if (!isSameDay(_selectedDay, calendarioProv.fechaSeleccionada)) {
          _selectedDay = calendarioProv.fechaSeleccionada;
          _focusedDay = calendarioProv.fechaSeleccionada;
          _selectedEvents.value = _getEventsForDay(
            calendarioProv.fechaSeleccionada,
          );
        }

        return Column(
          children: [
            TableCalendar<TarjetaEventos>(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              daysOfWeekHeight: 20.0, // Altura para los días de la semana
              rowHeight: 40.0, // Altura de cada fila de días

              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: const TextStyle(color: Colors.black87),
                weekendTextStyle: const TextStyle(color: Colors.black87),
                todayTextStyle: const TextStyle(color: Colors.white),
                selectedTextStyle: const TextStyle(color: Colors.white),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                leftWithIcon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black54,
                  size: 20,
                ),
                rightWithIcon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                  size: 20,
                ),
                headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
                weekdayStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                // No cambiamos la fecha seleccionada del provider aquí,
                // solo el mes enfocado en el calendario.
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ValueListenableBuilder<List<TarjetaEventos>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay eventos para el día seleccionado.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final evento = value[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            calendarioProv.abrirFormularioEvento(
                              context,
                              evento: evento,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: evento.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        evento.titulo,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm', 'es').format(
                                          evento.fechaInicio,
                                        ), // Solo la hora
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey[700]),
                                      ),
                                      if (evento.descripcion.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          evento.descripcion,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
