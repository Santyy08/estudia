// lib/vista_calendario/vista_mes.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
// No es necesario importar EditarEventoForm aquí

class VistaMes extends StatefulWidget {
  const VistaMes({super.key});

  @override
  State<VistaMes> createState() => _VistaMesState();
}

class _VistaMesState extends State<VistaMes> {
  // El ValueNotifier para los eventos seleccionados se actualiza cuando cambia el día
  late final ValueNotifier<List<TarjetaEventos>> _selectedEvents;
  final CalendarFormat _calendarFormat =
      CalendarFormat.month; // Por defecto, vista mensual

  // _focusedDay se usa para controlar qué mes se muestra en TableCalendar
  DateTime _focusedDay = DateTime.now();
  // _selectedDay es el día que el usuario ha tocado/seleccionado
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES'; // Asegurar locale

    // Sincronizar con el provider al inicio
    final calendarioProv = Provider.of<CalendarioProvider>(
      context,
      listen: false,
    );
    _selectedDay = calendarioProv.fechaSeleccionada;
    _focusedDay =
        calendarioProv
            .fechaSeleccionada; // Enfocar el día seleccionado inicialmente
    calendarioProv.setFocusedDayForTableCalendar(
      _focusedDay,
    ); // Informar al provider

    // Obtener los eventos para el día seleccionado inicialmente
    _selectedEvents = ValueNotifier(
      _getEventsForDay(calendarioProv.fechaSeleccionada),
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Función que TableCalendar usará para cargar eventos para cada día visible
  List<TarjetaEventos> _getEventsForDay(DateTime day) {
    // Llama al método del provider que genera las ocurrencias para un día específico
    // Es importante normalizar el 'day' a medianoche para la búsqueda en el provider si es necesario
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return Provider.of<CalendarioProvider>(
      context,
      listen: false,
    ).eventosDelDia(normalizedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      final calendarioProv = Provider.of<CalendarioProvider>(
        context,
        listen: false,
      );
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // Actualizar el día enfocado también
      });
      // Actualizar la fecha seleccionada en el provider
      calendarioProv.cambiarFechaSeleccionada(selectedDay);
      // Actualizar la lista de eventos para el nuevo día seleccionado
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    // Cuando el usuario cambia de mes en TableCalendar, actualizamos _focusedDay
    _focusedDay = focusedDay;
    // También informamos al provider (opcional, pero puede ser útil si otras partes dependen de esto)
    Provider.of<CalendarioProvider>(
      context,
      listen: false,
    ).setFocusedDayForTableCalendar(focusedDay);
    // No cambiamos _selectedDay aquí, solo el mes/año que se visualiza
    // Podrías optar por seleccionar el primer día del nuevo mes enfocado:
    // _onDaySelected(focusedDay, focusedDay);
    // O mantener la selección anterior si estaba en un mes diferente.
    // Por ahora, solo actualizamos el foco.
    setState(
      () {},
    ); // Para que la UI refleje el cambio de mes si es necesario (ej. título)
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el provider para actualizar _selectedDay y _focusedDay si cambian externamente
    // Esto es útil si, por ejemplo, el botón "Hoy" en la AppBar cambia la fecha.
    final calendarioProv = context.watch<CalendarioProvider>();
    if (_selectedDay != calendarioProv.fechaSeleccionada) {
      // Esta sincronización debe hacerse con cuidado para evitar bucles de reconstrucción.
      // Lo ideal es que _onDaySelected sea la única fuente de verdad para cambiar _selectedDay
      // y el provider. Si el provider cambia, esta vista debería reaccionar.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Evita setState durante build
        if (!isSameDay(_selectedDay, calendarioProv.fechaSeleccionada)) {
          setState(() {
            _selectedDay = calendarioProv.fechaSeleccionada;
            _focusedDay =
                calendarioProv
                    .fechaSeleccionada; // Mantener foco y selección sincronizados
            _selectedEvents.value = _getEventsForDay(
              calendarioProv.fechaSeleccionada,
            );
          });
        } else if (!isSameDay(_focusedDay, calendarioProv.fechaSeleccionada) &&
            _calendarFormat == CalendarFormat.month) {
          // Si solo el foco cambió (ej. desde el provider por alguna razón)
          setState(() {
            _focusedDay = calendarioProv.fechaSeleccionada;
          });
        }
      });
    }

    return Column(
      children: [
        TableCalendar<TarjetaEventos>(
          locale: 'es_ES', // Configurar el idioma para TableCalendar
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay:
              _focusedDay, // Día que TableCalendar usa para determinar el mes visible
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay, // Función para cargar eventos
          startingDayOfWeek:
              StartingDayOfWeek.monday, // Empezar semana en Lunes
          daysOfWeekHeight:
              22.0, // Altura para los nombres de los días de la semana
          rowHeight:
              48.0, // Altura de cada fila de días, ajusta según tu contenido
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                // Mostrar múltiples puntos si hay múltiples eventos, o un solo punto customizado
                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        events
                            .take(3)
                            .map(
                              (event) => Container(
                                // Mostrar hasta 3 puntos
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 0.5,
                                ),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: event.color.withOpacity(
                                    0.8,
                                  ), // Usar color del evento
                                ),
                              ),
                            )
                            .toList(),
                  ),
                );
              }
              return null;
            },
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible:
                false, // No mostrar días de meses anteriores/posteriores
            // todayDecoration, selectedDecoration, defaultTextStyle, etc., se heredan del tema
            // o se pueden personalizar aquí.
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              // Estilo por defecto si no se usa markerBuilder
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            cellMargin: const EdgeInsets.all(
              5.0,
            ), // Margen alrededor de cada celda de día
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible:
                false, // Ocultar botón de cambiar formato (semana, 2 semanas, mes)
            titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            // Los iconos de flecha ya deberían usar el color del tema del AppBar,
            // pero se pueden forzar aquí si es necesario.
            // leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
            // rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            // Estilo para los nombres de los días (L, M, M, J, V, S, D)
            weekdayStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Colors.grey[800],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged, // Manejar cambio de mes
          // onFormatChanged: (format) { // Si se permite cambiar el formato
          //   if (_calendarFormat != format) {
          //     setState(() { _calendarFormat = format; });
          //   }
          // },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<TarjetaEventos>>(
            valueListenable: _selectedEvents,
            builder: (context, eventosDelDiaSeleccionado, _) {
              if (eventosDelDiaSeleccionado.isEmpty) {
                return Center(
                  child: Text(
                    'No hay eventos para este día.',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: eventosDelDiaSeleccionado.length,
                itemBuilder: (context, index) {
                  final evento = eventosDelDiaSeleccionado[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Provider.of<CalendarioProvider>(
                          context,
                          listen: false,
                        ).abrirFormularioEvento(context, evento: evento);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: evento.esTodoElDia ? 20 : 35,
                              decoration: BoxDecoration(
                                color: evento.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    evento.titulo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    evento.esTodoElDia
                                        ? 'Todo el día'
                                        : '${DateFormat('HH:mm').format(evento.fechaInicio)} - ${DateFormat('HH:mm').format(evento.fechaFin)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (evento.descripcion.isNotEmpty &&
                                      !evento.esTodoElDia) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      evento.descripcion,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 11),
                                      maxLines: 1,
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
  }
}

// Helper (si no lo tienes global)
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
