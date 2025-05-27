// lib/vista_calendario/vista_semana.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
import '../widgets/editar_evento_form.dart';

class VistaSemana extends StatelessWidget {
  const VistaSemana({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        final fechaSeleccionada = calendarioProv.fechaSeleccionada;
        final startOfWeek = fechaSeleccionada.subtract(
          Duration(days: fechaSeleccionada.weekday % 7),
        ); // Domingo
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        final eventosDeLaSemana = calendarioProv.eventosDeLaSemana(
          fechaSeleccionada,
        );

        // Generar las horas desde las 8 AM hasta las 20 PM (ajustable)
        final List<int> hours = List.generate(
          13,
          (index) => 8 + index,
        ); // 8 AM a 8 PM

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      calendarioProv.cambiarFechaSeleccionada(
                        fechaSeleccionada.subtract(const Duration(days: 7)),
                      );
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${DateFormat('MMM dd', 'es').format(startOfWeek)} - ${DateFormat('MMM dd', 'es').format(endOfWeek)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: () {
                      calendarioProv.cambiarFechaSeleccionada(
                        fechaSeleccionada.add(const Duration(days: 7)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna de Horas
                    SizedBox(
                      width: 60, // Ancho fijo para la columna de horas
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ), // Espacio para los nombres de los días
                          ...hours
                              .map(
                                (hour) => SizedBox(
                                  height:
                                      60, // Altura de cada slot de hora (ajustable)
                                  child: Center(
                                    child: Text(
                                      '${hour} AM',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fila de Días de la Semana
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              children: List.generate(7, (index) {
                                final day = startOfWeek.add(
                                  Duration(days: index),
                                );
                                return Expanded(
                                  child: Center(
                                    child: Text(
                                      DateFormat(
                                        'E',
                                        'es',
                                      ).format(day), // Mon, Tue, etc.
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Área de Eventos por Días y Horas
                          Stack(
                            children: [
                              // Líneas Horizontales de la Grilla (horas)
                              ...hours
                                  .map(
                                    (_) => Container(
                                      height:
                                          60, // Misma altura que los slots de hora
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              // Líneas Verticales de la Grilla (días)
                              Positioned.fill(
                                child: Row(
                                  children: List.generate(
                                    7,
                                    (index) => Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              index < 6
                                                  ? Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[200]!,
                                                    ),
                                                  )
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Eventos Posicionados
                              ...eventosDeLaSemana.map((evento) {
                                final dayIndex =
                                    evento.fechaInicio
                                        .difference(startOfWeek)
                                        .inDays;
                                if (dayIndex < 0 || dayIndex > 6)
                                  return const SizedBox.shrink(); // Evento fuera de la semana

                                final startHour =
                                    evento.fechaInicio.hour +
                                    evento.fechaInicio.minute / 60;
                                final endHour =
                                    evento.fechaFin.hour +
                                    evento.fechaFin.minute / 60;

                                // Calcular top y height en base a la escala de 60px por hora
                                final top = (startHour - hours.first) * 60.0;
                                final height = (endHour - startHour) * 60.0;

                                if (top < 0 || height <= 0)
                                  return const SizedBox.shrink(); // Evento fuera del rango de horas mostrado

                                return Positioned(
                                  left:
                                      (MediaQuery.of(context).size.width - 60) /
                                          7 *
                                          dayIndex +
                                      2, // Ancho de la columna del día
                                  top: top + 2, // Margen superior
                                  width:
                                      (MediaQuery.of(context).size.width - 60) /
                                          7 -
                                      4, // Ancho del evento
                                  height: height - 4, // Altura del evento
                                  child: GestureDetector(
                                    onTap: () {
                                      calendarioProv.abrirFormularioEvento(
                                        context,
                                        evento: evento,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: evento.color,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: evento.color!.withOpacity(0.5),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            evento.titulo,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (height >
                                              30) // Mostrar hora solo si hay espacio
                                            Text(
                                              '${DateFormat('HH:mm').format(evento.fechaInicio)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
