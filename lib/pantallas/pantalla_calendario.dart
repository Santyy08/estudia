// lib/pantallas/pantalla_calendario.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../vista_calendario/vista_mes.dart';
import '../vista_calendario/vista_semana.dart';
import '../vista_calendario/vista_dia.dart';
import '../vista_calendario/vista_agenda.dart';

import '../providers/calendario_provider.dart';
// Ya no necesitamos importar TarjetaEventos o los formularios aquí directamente,
// ya que CalendarioProvider maneja la apertura de los formularios.

class PantallaCalendario extends StatelessWidget {
  const PantallaCalendario({Key? key}) : super(key: key);

  String _obtenerTituloAppBar(
    BuildContext
    context, // Añadido para acceder al provider dentro de esta función si es necesario
    VistaCalendario vista,
    DateTime fechaSeleccionada,
  ) {
    // Acceder al provider para obtener la fecha enfocada si es necesario (ej. para el título del mes)
    // Aunque para el título actual, `fechaSeleccionada` del provider es suficiente.
    // final calendarioProv = Provider.of<CalendarioProvider>(context, listen: false);
    final now = DateTime.now();

    switch (vista) {
      case VistaCalendario.Mes:
        // El título de la vista de mes ahora lo maneja internamente el widget TableCalendar,
        // así que aquí podemos poner un título más genérico o uno que refleje la fecha seleccionada
        // si TableCalendar no está visible o si queremos un título general en la AppBar.
        // Por consistencia con tu diseño, mostraremos "Calendario de Estudio - Mes Año"
        // similar a tu imagen de "Calendario de Estudio - Abril".
        return 'Calendario - ${DateFormat('MMMM yyyy', 'es').format(fechaSeleccionada)}';
      case VistaCalendario.Semana:
        final inicioSemana = fechaSeleccionada.subtract(
          // Asegúrate que el cálculo del inicio de semana sea consistente (Domingo o Lunes)
          // El provider usa (weekday % 7) para Domingo como inicio.
          Duration(days: fechaSeleccionada.weekday % 7),
        );
        final finSemana = inicioSemana.add(const Duration(days: 6));
        return '${DateFormat('dd MMM', 'es').format(inicioSemana)} - ${DateFormat('dd MMM \'de\' yyyy', 'es').format(finSemana)}';
      case VistaCalendario.Dia:
        return DateFormat(
          'EEEE, dd \'de\' MMMM \'de\' yyyy',
          'es',
        ).format(fechaSeleccionada);
      case VistaCalendario.Agenda:
        return 'Mi Agenda';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa el locale para intl
    Intl.defaultLocale =
        'es_ES'; // o 'es' dependiendo de tus necesidades exactas de formato

    return Scaffold(
      appBar: AppBar(
        // El botón de volver puede ser útil si esta pantalla no es la raíz
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     if (Navigator.canPop(context)) {
        //       Navigator.pop(context);
        //     } else {
        //       // Acción por defecto si no se puede "volver" (ej. ir a la fecha actual)
        //       context.read<CalendarioProvider>().cambiarFechaSeleccionada(DateTime.now());
        //     }
        //   },
        // ),
        title: Consumer<CalendarioProvider>(
          builder: (context, calendarioProv, child) {
            return Text(
              _obtenerTituloAppBar(
                context, // Pasar el contexto
                calendarioProv.vistaSeleccionada,
                calendarioProv.fechaSeleccionada,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Ajuste de tamaño para que quepa mejor
                // color: Colors.black87, // El tema del AppBar ya lo maneja
              ),
            );
          },
        ),
        actions: [
          Consumer<CalendarioProvider>(
            builder: (context, calendarioProv, child) {
              return PopupMenuButton<VistaCalendario>(
                icon: Icon(
                  Icons
                      .calendar_view_month_outlined, // Icono más genérico para el selector de vista
                  color:
                      Theme.of(context).appBarTheme.actionsIconTheme?.color ??
                      Theme.of(context).primaryColor,
                ),
                onSelected: (VistaCalendario vista) {
                  calendarioProv.cambiarVista(vista);
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<VistaCalendario>>[
                      const PopupMenuItem<VistaCalendario>(
                        value: VistaCalendario.Mes,
                        child: Text('Mes'),
                      ),
                      const PopupMenuItem<VistaCalendario>(
                        value: VistaCalendario.Semana,
                        child: Text('Semana'),
                      ),
                      const PopupMenuItem<VistaCalendario>(
                        value: VistaCalendario.Dia,
                        child: Text('Día'),
                      ),
                      const PopupMenuItem<VistaCalendario>(
                        value: VistaCalendario.Agenda,
                        child: Text('Agenda'),
                      ),
                    ],
              );
            },
          ),
          // Botón para ir al día de Hoy
          IconButton(
            icon: Icon(
              Icons.today,
              color:
                  Theme.of(context).appBarTheme.actionsIconTheme?.color ??
                  Theme.of(context).primaryColor,
            ),
            tooltip: 'Hoy',
            onPressed: () {
              context.read<CalendarioProvider>().cambiarFechaSeleccionada(
                DateTime.now(),
              );
              // Si estás en la vista de Mes, también podrías querer que TableCalendar se enfoque en hoy.
              // Esto requeriría una forma de comunicar esto a VistaMes, o que VistaMes escuche cambios
              // en fechaSeleccionada y actualice su focusedDay si está mostrando el mes actual.
            },
          ),
        ],
        // backgroundColor: Colors.white, // Ya definido en el tema de main.dart
        // elevation: 0, // Ya definido en el tema de main.dart
      ),
      body: Consumer<CalendarioProvider>(
        builder: (context, calendarioProv, child) {
          // Aquí pasamos la fecha seleccionada del provider a las vistas que la necesiten.
          // Las vistas internamente usarán esta fecha o el provider para obtener sus eventos.
          switch (calendarioProv.vistaSeleccionada) {
            case VistaCalendario.Mes:
              return const VistaMes(); // VistaMes ya usa el provider internamente
            case VistaCalendario.Semana:
              return const VistaSemana(); // VistaSemana usa el provider
            case VistaCalendario.Dia:
              return const VistaDia(); // VistaDia usa el provider
            case VistaCalendario.Agenda:
              return const VistaAgenda(); // VistaAgenda usa el provider
            default: // No debería ocurrir
              return const Center(child: Text('Vista no implementada'));
          }
        },
      ),
      floatingActionButton: Consumer<CalendarioProvider>(
        builder: (context, calendarioProv, child) {
          // Mostrar FAB en todas las vistas excepto Agenda (o como prefieras)
          if (calendarioProv.vistaSeleccionada != VistaCalendario.Agenda) {
            return FloatingActionButton(
              onPressed: () {
                // Al crear un nuevo evento, la fecha por defecto del formulario
                // debería ser la `fechaSeleccionada` del calendario.
                // El `CrearEventoForm` ya usa `DateTime.now()`,
                // podríamos pasarle `calendarioProv.fechaSeleccionada` si quisiéramos.
                calendarioProv.abrirFormularioEvento(context);
              },
              // backgroundColor: Theme.of(context).primaryColor, // Ya definido en el tema
              // foregroundColor: Colors.white, // Ya definido en el tema
              // shape: const CircleBorder(), // Ya definido en el tema
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink(); // Ocultar FAB en la vista de Agenda
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Default
    );
  }
}
