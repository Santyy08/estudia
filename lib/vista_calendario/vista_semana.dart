// lib/vista_calendario/vista_semana.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/calendario_provider.dart';
import '../widgets/tarjeta_eventos.dart';
// No es necesario importar EditarEventoForm aquí

class VistaSemana extends StatelessWidget {
  const VistaSemana({Key? key}) : super(key: key);

  // Define las horas que se mostrarán en la cuadrícula
  final List<int> _horasDelDia = const [
    // 0, 1, 2, 3, 4, 5, 6, 7, // Horas de la madrugada si se quieren mostrar
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23, // 8 AM a 11 PM
  ];
  final double _alturaHora = 60.0; // Altura de cada slot de hora en la UI
  final double _anchoColumnaHora =
      50.0; // Ancho para la columna de etiquetas de hora

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'es_ES';

    return Consumer<CalendarioProvider>(
      builder: (context, calendarioProv, child) {
        final fechaSeleccionada = calendarioProv.fechaSeleccionada;
        // El título de la semana ya se maneja en la AppBar de PantallaCalendario
        // por lo que la navegación y el título aquí son redundantes.
        // final startOfWeek = fechaSeleccionada.subtract(Duration(days: fechaSeleccionada.weekday % 7));
        // final endOfWeek = startOfWeek.add(const Duration(days: 6));

        // Obtiene los eventos para la semana actual (ya filtrados y con ocurrencias)
        final eventosDeLaSemana = calendarioProv.eventosDeLaSemana(
          fechaSeleccionada,
        );

        // Separar eventos de todo el día de los eventos con hora específica
        final eventosTodoElDia =
            eventosDeLaSemana.where((e) => e.esTodoElDia).toList();
        final eventosConHora =
            eventosDeLaSemana.where((e) => !e.esTodoElDia).toList();

        // Calcular el primer día de la semana (Domingo)
        final primerDiaSemana = fechaSeleccionada.subtract(
          Duration(days: fechaSeleccionada.weekday % 7),
        );

        return Column(
          children: [
            // Ya no necesitamos la barra de navegación de semana aquí, se maneja en la AppBar general
            // _BarraNavegacionSemana(fechaSeleccionada: fechaSeleccionada),
            // const Divider(height: 1),

            // Sección para eventos de "Todo el día"
            _buildSeccionEventosTodoElDia(
              context,
              eventosTodoElDia,
              primerDiaSemana,
              calendarioProv,
            ),

            // Cuadrícula principal de la semana
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna de Horas (etiquetas)
                    _buildColumnaHoras(context),
                    // Columnas de los Días con sus eventos
                    Expanded(
                      child: Stack(
                        children: [
                          // Fondo de la cuadrícula (líneas)
                          _buildFondoCuadricula(context, primerDiaSemana),
                          // Eventos posicionados
                          ..._buildEventosEnCuadricula(
                            context,
                            eventosConHora,
                            primerDiaSemana,
                            calendarioProv,
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

  Widget _buildColumnaHoras(BuildContext context) {
    return SizedBox(
      width: _anchoColumnaHora,
      child: Column(
        children: [
          SizedBox(height: 30), // Espacio para la cabecera de los días
          ..._horasDelDia
              .map(
                (hour) => Container(
                  height: _alturaHora,
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat(
                      'HH:mm',
                    ).format(DateTime(0, 0, 0, hour, 0)), // Formato '08:00'
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFondoCuadricula(BuildContext context, DateTime primerDiaSemana) {
    return Column(
      children: [
        // Cabecera de los Días de la Semana
        Container(
          height: 30, // Altura para los nombres de los días
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: List.generate(7, (index) {
              final dia = primerDiaSemana.add(Duration(days: index));
              final esHoy = isSameDay(dia, DateTime.now());
              return Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E', 'es')
                            .format(dia)
                            .substring(0, 1)
                            .toUpperCase(), // "L", "M", etc.
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color:
                              esHoy
                                  ? Theme.of(context).primaryColor
                                  : Colors.black54,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(dia), // Número del día "8", "9"
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              esHoy ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                          color:
                              esHoy
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        // Líneas Horizontales de la Grilla (para cada hora)
        ..._horasDelDia
            .map(
              (_) => Container(
                height: _alturaHora,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
              ),
            )
            .toList(),
        // Líneas Verticales (entre días) - Se dibujan como parte del Stack o dentro de cada columna del día
        // Esto se maneja mejor con el posicionamiento de los eventos o un CustomPainter si es muy complejo
      ],
    );
  }

  List<Widget> _buildEventosEnCuadricula(
    BuildContext context,
    List<TarjetaEventos> eventos,
    DateTime primerDiaSemana,
    CalendarioProvider calendarioProv,
  ) {
    final double anchoDia =
        (MediaQuery.of(context).size.width - _anchoColumnaHora) / 7;

    return eventos.map((evento) {
      // Asegurarse que el evento caiga dentro de la semana visible y las horas visibles

      // Ajustar primerDiaSemana para que sea realmente el inicio del día (00:00)
      DateTime inicioVisibleSemana = DateTime(
        primerDiaSemana.year,
        primerDiaSemana.month,
        primerDiaSemana.day,
      );
      DateTime finVisibleSemana = inicioVisibleSemana.add(
        const Duration(days: 7),
      );

      // Ignorar eventos que no se solapan con la semana actual
      if (evento.fechaFin.isBefore(inicioVisibleSemana) ||
          evento.fechaInicio.isAfter(finVisibleSemana)) {
        return const SizedBox.shrink();
      }

      // Calcular posición y tamaño
      // Normalizar fechaInicio y fechaFin al rango de horas visibles
      double horaInicioEvento =
          evento.fechaInicio.hour + (evento.fechaInicio.minute / 60.0);
      double horaFinEvento =
          evento.fechaFin.hour + (evento.fechaFin.minute / 60.0);

      // Si el evento empieza antes de la primera hora visible, ajustarlo
      if (horaInicioEvento < _horasDelDia.first)
        horaInicioEvento = _horasDelDia.first.toDouble();
      // Si el evento termina después de la última hora visible + 1 (para que ocupe hasta el final del slot), ajustarlo
      if (horaFinEvento > _horasDelDia.last + 1)
        horaFinEvento = (_horasDelDia.last + 1).toDouble();

      double top = (horaInicioEvento - _horasDelDia.first) * _alturaHora;
      double height = (horaFinEvento - horaInicioEvento) * _alturaHora;

      // Si el evento es de varios días (no "todo el día", sino que cruza medianoche)
      // esta lógica necesitaría ser más compleja para renderizarlo en múltiples columnas.
      // Por ahora, lo posicionamos en el día de inicio.
      // Para eventos que cruzan días, se deberían crear "segmentos" de evento por día.
      // Esta simplificación asume que un evento con hora se muestra solo en su día de inicio si dura menos de 24h.
      // O si dura más, se muestra cortado o necesita una lógica más avanzada.

      int diaIndex = evento.fechaInicio.difference(inicioVisibleSemana).inDays;
      if (diaIndex < 0 || diaIndex > 6)
        return const SizedBox.shrink(); // Fuera de la semana

      if (height <= 0)
        return const SizedBox.shrink(); // Evento sin duración visible

      return Positioned(
        top: top + 30, // +30 para compensar la cabecera de los días
        left: diaIndex * anchoDia + 2, // +2 para un pequeño margen
        width: anchoDia - 4, // -4 para márgenes a ambos lados
        height: height - 2, // -2 para un pequeño margen inferior
        child: GestureDetector(
          onTap: () {
            calendarioProv.abrirFormularioEvento(context, evento: evento);
          },
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: evento.color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: evento.color.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: Text(
              evento.titulo,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color:
                    ThemeData.estimateBrightnessForColor(evento.color) ==
                            Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines:
                  (height / 12)
                      .floor(), // Intentar mostrar más líneas si hay espacio
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSeccionEventosTodoElDia(
    BuildContext context,
    List<TarjetaEventos> eventos,
    DateTime primerDiaSemana,
    CalendarioProvider calendarioProv,
  ) {
    if (eventos.isEmpty) return const SizedBox.shrink();

    // Agrupar eventos de todo el día por su día dentro de la semana
    Map<int, List<TarjetaEventos>> eventosPorDia = {};
    for (var evento in eventos) {
      // Considerar eventos de todo el día que duran múltiples días
      DateTime diaActual = DateTime(
        evento.fechaInicio.year,
        evento.fechaInicio.month,
        evento.fechaInicio.day,
      );
      DateTime diaFinEvento = DateTime(
        evento.fechaFin.year,
        evento.fechaFin.month,
        evento.fechaFin.day,
      );

      while (!diaActual.isAfter(diaFinEvento)) {
        int diaIndex = diaActual.difference(primerDiaSemana).inDays;
        if (diaIndex >= 0 && diaIndex < 7) {
          // Si el día está en la semana visible
          if (!eventosPorDia.containsKey(diaIndex)) {
            eventosPorDia[diaIndex] = [];
          }
          // Añadimos el evento original, la UI decidirá cómo mostrarlo (ej. solo el título)
          eventosPorDia[diaIndex]!.add(evento);
        }
        if (diaActual == diaFinEvento)
          break; // Evitar bucle infinito si fechaInicio y fechaFin son iguales (aunque esTodoElDia)
        diaActual = diaActual.add(const Duration(days: 1));
      }
    }

    // Determinar cuántas "filas" de eventos de todo el día necesitamos como máximo por día
    int maxFilas = 0;
    eventosPorDia.values.forEach((list) {
      if (list.length > maxFilas) maxFilas = list.length;
    });
    if (maxFilas == 0 && eventos.isNotEmpty)
      maxFilas = 1; // Al menos una fila si hay algún evento
    if (maxFilas > 2)
      maxFilas =
          2; // Limitar a 2 filas para no ocupar mucho espacio, luego un "+X más"

    if (maxFilas == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: _anchoColumnaHora,
        bottom: 4,
        top: 4,
      ), // Alinear con la cuadrícula
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: Colors.grey[50],
      ),
      child: Column(
        children: List.generate(maxFilas, (filaIndex) {
          return SizedBox(
            // Usar SizedBox para controlar la altura de la fila
            height: 22, // Altura fija por fila de evento de todo el día
            child: Row(
              children: List.generate(7, (diaIndex) {
                final eventosDelDiaParaFila = eventosPorDia[diaIndex] ?? [];
                if (filaIndex < eventosDelDiaParaFila.length) {
                  final evento = eventosDelDiaParaFila[filaIndex];
                  return Expanded(
                    child: GestureDetector(
                      onTap:
                          () => calendarioProv.abrirFormularioEvento(
                            context,
                            evento: evento,
                          ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: evento.color.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          evento.titulo,
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                ThemeData.estimateBrightnessForColor(
                                          evento.color,
                                        ) ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Expanded(child: Container()); // Espacio vacío
                }
              }),
            ),
          );
        }),
        // TODO: Implementar indicador "+X más" si hay más eventos de los que se muestran
      ),
    );
  }
}

// Helper para comparar si dos DateTime son el mismo día (ignorando la hora)
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
