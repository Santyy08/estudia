// lib/vista_calendario/vista_dia.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
import '../widgets/editar_evento_form.dart';

class VistaDia extends StatelessWidget {
  const VistaDia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        final fechaActual = calendarioProv.fechaSeleccionada;
        final eventosDelDia = calendarioProv.eventosDelDia(fechaActual)
          ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () {
                      calendarioProv.cambiarFechaSeleccionada(
                        fechaActual.subtract(const Duration(days: 1)),
                      );
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat(
                          'EEEE, dd \'de\' MMMM',
                          'es',
                        ).format(fechaActual),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: () {
                      calendarioProv.cambiarFechaSeleccionada(
                        fechaActual.add(const Duration(days: 1)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child:
                  eventosDelDia.isEmpty
                      ? Center(
                        child: Text(
                          'No hay eventos para este día.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                      : ListView.builder(
                        itemCount: eventosDelDia.length,
                        itemBuilder: (context, index) {
                          final evento = eventosDelDia[index];
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
                                    Container(
                                      width: 8,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: evento.color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
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
                                            '${DateFormat('HH:mm').format(evento.fechaInicio)} - ${DateFormat('HH:mm').format(evento.fechaFin)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (evento
                                              .descripcion
                                              .isNotEmpty) ...[
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
                      ),
            ),
          ],
        );
      },
    );
  }
}
