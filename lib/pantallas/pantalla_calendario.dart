// lib/pantallas/pantalla_calendario.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../vista_calendario/vista_mes.dart';
import '../vista_calendario/vista_semana.dart';
import '../vista_calendario/vista_dia.dart';
import '../vista_calendario/vista_agenda.dart';

import '../providers/calendario_provider.dart';
// No necesitamos importar TarjetaEventos o los formularios aquí directamente,
// ya que CalendarioProvider los maneja al abrir el showModalBottomSheet.

class PantallaCalendario extends StatelessWidget {
  const PantallaCalendario({Key? key}) : super(key: key);

  String _obtenerTituloAppBar(
    VistaCalendario vista,
    DateTime fechaSeleccionada,
  ) {
    final now = DateTime.now();
    switch (vista) {
      case VistaCalendario.Mes:
        if (fechaSeleccionada.year == now.year &&
            fechaSeleccionada.month == now.month) {
          return 'Calendario de Estudio - ${DateFormat('MMMM', 'es').format(fechaSeleccionada)}'; // Como la imagen
        }
        return DateFormat('MMMM yyyy', 'es').format(fechaSeleccionada);
      case VistaCalendario.Semana:
        final inicioSemana = fechaSeleccionada.subtract(
          Duration(days: fechaSeleccionada.weekday % 7),
        ); // Domingo como inicio
        final finSemana = inicioSemana.add(const Duration(days: 6));
        return 'Agenda Semanal: ${DateFormat('MMM dd', 'es').format(inicioSemana)} - ${DateFormat('MMM dd', 'es').format(finSemana)}'; // Como la imagen
      case VistaCalendario.Dia:
        return DateFormat(
          'EEEE, dd \'de\' MMMM',
          'es',
        ).format(fechaSeleccionada);
      case VistaCalendario.Agenda:
        return 'Mi Agenda'; // Título genérico para la agenda
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ), // Botón de "volver" como en tus imágenes
          onPressed: () {
            // Aquí puedes manejar la navegación a la pantalla anterior si es necesario.
            // Por ahora, simplemente volver a la fecha actual o al inicio.
            context.read<CalendarioProvider>().cambiarFechaSeleccionada(
              DateTime.now(),
            );
          },
        ),
        title: Consumer<CalendarioProvider>(
          builder: (context, calendarioProv, child) {
            return Text(
              _obtenerTituloAppBar(
                calendarioProv.vistaSeleccionada,
                calendarioProv.fechaSeleccionada,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ), // Color de texto
            );
          },
        ),
        actions: [
          Consumer<CalendarioProvider>(
            builder: (context, calendarioProv, child) {
              // Convertir enum a string para el botón
              String currentViewName = calendarioProv.vistaSeleccionada.name;
              if (currentViewName == 'Mes')
                currentViewName = 'Month'; // Para mostrar como en la imagen
              if (currentViewName == 'Semana') currentViewName = 'Week';
              if (currentViewName == 'Dia') currentViewName = 'Day';

              return Row(
                children: [
                  TextButton(
                    onPressed:
                        () => calendarioProv.cambiarVista(VistaCalendario.Mes),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          calendarioProv.vistaSeleccionada ==
                                  VistaCalendario.Mes
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                    ),
                    child: const Text('Month'),
                  ),
                  TextButton(
                    onPressed:
                        () =>
                            calendarioProv.cambiarVista(VistaCalendario.Semana),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          calendarioProv.vistaSeleccionada ==
                                  VistaCalendario.Semana
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                    ),
                    child: const Text('Week'),
                  ),
                  TextButton(
                    onPressed:
                        () => calendarioProv.cambiarVista(VistaCalendario.Dia),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          calendarioProv.vistaSeleccionada ==
                                  VistaCalendario.Dia
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                    ),
                    child: const Text('Day'),
                  ),
                  TextButton(
                    onPressed:
                        () =>
                            calendarioProv.cambiarVista(VistaCalendario.Agenda),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          calendarioProv.vistaSeleccionada ==
                                  VistaCalendario.Agenda
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                    ),
                    child: const Text('Agenda'),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
        backgroundColor: Colors.white, // Fondo blanco para el AppBar
        elevation: 0, // Sin sombra
      ),
      body: Consumer<CalendarioProvider>(
        builder: (context, calendarioProv, child) {
          switch (calendarioProv.vistaSeleccionada) {
            case VistaCalendario.Mes:
              return const VistaMes();
            case VistaCalendario.Semana:
              return const VistaSemana();
            case VistaCalendario.Dia:
              return const VistaDia();
            case VistaCalendario.Agenda:
              return const VistaAgenda();
            default:
              return const Center(child: Text('Vista no implementada'));
          }
        },
      ),
      floatingActionButton: Consumer<CalendarioProvider>(
        builder: (context, calendarioProv, child) {
          // El FAB solo se muestra en la vista de mes según la imagen
          if (calendarioProv.vistaSeleccionada == VistaCalendario.Mes) {
            return FloatingActionButton(
              onPressed: () {
                calendarioProv.abrirFormularioEvento(context);
              },
              backgroundColor: Theme.of(context).primaryColor, // Color del FAB
              foregroundColor: Colors.white,
              shape: const CircleBorder(), // Forma circular
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink(); // Ocultar el FAB en otras vistas
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Posición del FAB
    );
  }
}
