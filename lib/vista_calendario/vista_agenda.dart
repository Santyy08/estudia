// lib/vista_calendario/vista_agenda.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart'; // Para el tipo de datos TarjetaEventos

class VistaAgenda extends StatelessWidget {
  const VistaAgenda({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'es_ES';

    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        // Usar el método del provider que ya genera las ocurrencias para la agenda
        final eventosParaAgenda = calendarioProv.eventosParaAgenda();

        if (eventosParaAgenda.isEmpty) {
          return Center(
            child: Text(
              'No hay eventos futuros en tu agenda.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          );
        }

        // Agrupar eventos por día para la visualización de la agenda
        final Map<DateTime, List<TarjetaEventos>> eventosAgrupados = {};
        for (var evento in eventosParaAgenda) {
          // Normalizar a solo fecha para agrupar correctamente
          final fechaSinHora = DateTime(
            evento.fechaInicio.year,
            evento.fechaInicio.month,
            evento.fechaInicio.day,
          );
          if (!eventosAgrupados.containsKey(fechaSinHora)) {
            eventosAgrupados[fechaSinHora] = [];
          }
          eventosAgrupados[fechaSinHora]!.add(evento);
        }

        // Ordenar las fechas de los grupos
        final fechasOrdenadas =
            eventosAgrupados.keys.toList()..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: fechasOrdenadas.length,
          itemBuilder: (context, sectionIndex) {
            final fechaGrupo = fechasOrdenadas[sectionIndex];
            final eventosDelDiaAgrupado = eventosAgrupados[fechaGrupo]!;
            // Los eventos ya vienen ordenados por hora desde el provider si se hizo bien en `eventosParaAgenda`

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    // Formato de fecha para la cabecera de cada día
                    DateFormat(
                      'EEEE, dd \'de\' MMMM \'de\' yyyy',
                      'es',
                    ).format(fechaGrupo),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(
                            context,
                          ).primaryColorDark, // Un color distintivo para la fecha
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap:
                      true, // Importante para ListView dentro de Column/ListView
                  physics:
                      const NeverScrollableScrollPhysics(), // Deshabilitar scroll individual
                  itemCount: eventosDelDiaAgrupado.length,
                  itemBuilder: (context, eventIndex) {
                    final evento = eventosDelDiaAgrupado[eventIndex];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      elevation: 1.5,
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
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Centrar verticalmente
                            children: [
                              Container(
                                width: 6, // Ancho de la barra de color
                                height:
                                    evento.esTodoElDia
                                        ? 20
                                        : 35, // Altura de la barra
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                      // No mostrar desc en "todo el dia" para ahorrar espacio
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
                                    if (evento.etiquetas.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Wrap(
                                          spacing: 4.0,
                                          runSpacing: 2.0,
                                          children:
                                              evento.etiquetas
                                                  .map(
                                                    (tag) => Chip(
                                                      label: Text(
                                                        tag,
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                      labelPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 3,
                                                            vertical: 0,
                                                          ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      padding: EdgeInsets.zero,
                                                      backgroundColor: evento
                                                          .color
                                                          .withOpacity(0.1),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (sectionIndex < fechasOrdenadas.length - 1)
                  const Divider(height: 16, indent: 16, endIndent: 16),
              ],
            );
          },
        );
      },
    );
  }
}
