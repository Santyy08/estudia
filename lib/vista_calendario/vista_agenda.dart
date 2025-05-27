// lib/vista_calendario/vista_agenda.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
import '../widgets/editar_evento_form.dart';

class VistaAgenda extends StatelessWidget {
  const VistaAgenda({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        final eventosFuturos = calendarioProv.eventosFiltrados();

        if (eventosFuturos.isEmpty) {
          return Center(
            child: Text(
              'No hay eventos futuros en tu agenda.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        final Map<DateTime, List<TarjetaEventos>> eventosAgrupados = {};
        for (var evento in eventosFuturos) {
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

        final fechasOrdenadas =
            eventosAgrupados.keys.toList()..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          itemCount: fechasOrdenadas.length,
          itemBuilder: (context, sectionIndex) {
            final fecha = fechasOrdenadas[sectionIndex];
            final eventosDelDia =
                eventosAgrupados[fecha]!
                  ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    DateFormat(
                      'EEEE, dd \'de\' MMMM \'de\' yyyy',
                      'es',
                    ).format(fecha),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventosDelDia.length,
                  itemBuilder: (context, eventIndex) {
                    final evento = eventosDelDia[eventIndex];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      elevation: 2,
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
                              Container(
                                width: 6,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: evento.color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evento.titulo,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat('HH:mm', 'es').format(evento.fechaInicio)} - ${DateFormat('HH:mm', 'es').format(evento.fechaFin)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (evento.descripcion.isNotEmpty)
                                      Text(
                                        evento.descripcion,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (evento.etiquetas.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Wrap(
                                          spacing: 6.0,
                                          runSpacing: 0.0,
                                          children:
                                              evento.etiquetas
                                                  .map(
                                                    (tag) => Chip(
                                                      label: Text(
                                                        tag,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
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
              ],
            );
          },
        );
      },
    );
  }
}
