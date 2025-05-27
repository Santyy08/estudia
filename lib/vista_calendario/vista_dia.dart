// lib/vista_calendario/vista_dia.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
// Necesario para el tipo de datos de la lista
// No es necesario importar EditarEventoForm aquí, ya que se maneja a través del provider

class VistaDia extends StatelessWidget {
  const VistaDia({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurarse que el locale de Intl esté configurado
    Intl.defaultLocale = 'es_ES';

    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        final fechaActual = calendarioProv.fechaSeleccionada;
        // Obtener los eventos para el día seleccionado usando el método actualizado del provider
        final eventosDelDia = calendarioProv.eventosDelDia(fechaActual);
        // La ordenación ya se hace dentro de eventosDelDia si es necesario,
        // o se puede mantener aquí si se prefiere.
        // ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

        return Column(
          children: [
            // El encabezado con la fecha y los botones de navegación ya está en PantallaCalendario,
            // así que no es necesario repetirlo aquí a menos que quieras un diseño diferente.
            // Si la PantallaCalendario ya tiene un buen título que cambia con el día,
            // esta sección podría ser más simple o incluso eliminarse de esta vista específica.
            // Por ahora, mantendremos la estructura similar a tu versión original,
            // pero considera que el título global ya existe en la AppBar.

            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.arrow_back_ios, size: 20),
            //         onPressed: () {
            //           calendarioProv.cambiarFechaSeleccionada(
            //             fechaActual.subtract(const Duration(days: 1)),
            //           );
            //         },
            //       ),
            //       Expanded(
            //         child: Center(
            //           child: Text(
            //             DateFormat('EEEE, dd \'de\' MMMM', 'es').format(fechaActual),
            //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.arrow_forward_ios, size: 20),
            //         onPressed: () {
            //           calendarioProv.cambiarFechaSeleccionada(
            //             fechaActual.add(const Duration(days: 1)),
            //           );
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            // const Divider(), // Podría ser opcional si la AppBar ya tiene un separador
            Expanded(
              child:
                  eventosDelDia.isEmpty
                      ? Center(
                        child: Text(
                          'No hay eventos para este día.',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(
                          8.0,
                        ), // Añadir un poco de padding general
                        itemCount: eventosDelDia.length,
                        itemBuilder: (context, index) {
                          final evento = eventosDelDia[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              // side: BorderSide(color: Colors.grey[300]!) // Opcional, si el tema no lo define
                            ),
                            child: InkWell(
                              onTap: () {
                                calendarioProv.abrirFormularioEvento(
                                  context,
                                  evento: evento,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8, // Ancho de la barra de color
                                      // Altura dinámica o fija. Si es dinámica, necesita un child o constraints.
                                      // Para que ocupe toda la altura del Card, es más complejo y
                                      // se necesitaría un IntrinsicHeight o calcular la altura.
                                      // Por ahora, una altura fija si el texto es corto.
                                      height:
                                          evento.esTodoElDia
                                              ? 20
                                              : 50, // Más pequeño si es todo el día
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
                                        mainAxisSize:
                                            MainAxisSize
                                                .min, // Para que la columna se ajuste al contenido
                                        children: [
                                          Text(
                                            evento.titulo,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            evento.esTodoElDia
                                                ? 'Todo el día'
                                                : '${DateFormat('HH:mm').format(evento.fechaInicio)} - ${DateFormat('HH:mm').format(evento.fechaFin)}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (evento
                                              .descripcion
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 6),
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
