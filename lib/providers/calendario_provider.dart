// lib/providers/calendario_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../widgets/tarjeta_eventos.dart';
import '../widgets/crear_evento_form.dart';
import '../widgets/editar_evento_form.dart';

enum VistaCalendario { Mes, Semana, Dia, Agenda }

class CalendarioProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  VistaCalendario _vistaSeleccionada = VistaCalendario.Mes;
  DateTime _fechaSeleccionada = DateTime.now();

  final List<TarjetaEventos> _eventos = [];

  CalendarioProvider() {
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Clase Historia del Arte',
        descripcion: 'Ver capítulo sobre el Renacimiento.',
        fechaInicio: DateTime(2025, 4, 8, 9, 0), // Lunes, 8 de abril, 9 AM
        fechaFin: DateTime(2025, 4, 8, 10, 0),
        color: Colors.blue.withOpacity(0.2), // Color de ejemplo pastel
        etiquetas: ['Clase'],
      ),
    );
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Tarea: Leer capítulo 5',
        descripcion: 'Leer capítulo 5 del libro de texto.',
        fechaInicio: DateTime(2025, 4, 9, 9, 0), // Martes, 9 de abril, 9 AM
        fechaFin: DateTime(2025, 4, 9, 10, 0),
        color: Colors.lightGreen.withOpacity(0.2), // Color de ejemplo pastel
        etiquetas: ['Tarea'],
      ),
    );
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Estudiar álgebra',
        descripcion: 'Resolver ejercicios de ecuaciones diferenciales.',
        fechaInicio: DateTime(
          2025,
          4,
          10,
          10,
          30,
        ), // Miércoles, 10 de abril, 10:30 AM
        fechaFin: DateTime(2025, 4, 10, 11, 30),
        color: Colors.purple.withOpacity(0.2), // Color de ejemplo pastel
        etiquetas: ['Objetivo'],
      ),
    );
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Clase Filosofía',
        descripcion: 'Debate sobre ética y moral.',
        fechaInicio: DateTime(2025, 4, 11, 11, 0), // Jueves, 11 de abril, 11 AM
        fechaFin: DateTime(2025, 4, 11, 12, 0),
        color: Colors.orange.withOpacity(0.2), // Color de ejemplo pastel
        etiquetas: ['Clase'],
      ),
    );
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Reunión de Proyecto',
        descripcion: 'Discutir avances y próximos pasos.',
        fechaInicio: DateTime(2025, 4, 16, 14, 0), // 16 de abril, 2 PM
        fechaFin: DateTime(2025, 4, 16, 15, 0),
        color: Colors.teal.withOpacity(0.2),
        etiquetas: ['Reunión'],
      ),
    );
    _eventos.add(
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Preparar Presentación',
        descripcion: 'Finalizar diapositivas para el viernes.',
        fechaInicio: DateTime(2025, 4, 17, 10, 0), // 17 de abril, 10 AM
        fechaFin: DateTime(2025, 4, 17, 12, 0),
        color: Colors.indigo.withOpacity(0.2),
        etiquetas: ['Estudio'],
      ),
    );
  }

  VistaCalendario get vistaSeleccionada => _vistaSeleccionada;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  List<TarjetaEventos> get eventos => List.unmodifiable(_eventos);

  void cambiarVista(VistaCalendario vista) {
    _vistaSeleccionada = vista;
    notifyListeners();
  }

  void cambiarFechaSeleccionada(DateTime fecha) {
    _fechaSeleccionada = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
    ); // Normalizar a solo fecha
    notifyListeners();
  }

  Future<void> guardarEvento(TarjetaEventos evento) async {
    final index = _eventos.indexWhere((e) => e.id == evento.id);
    if (index != -1) {
      _eventos[index] = evento;
    } else {
      _eventos.add(evento);
    }
    notifyListeners();
  }

  void eliminarEvento(String id) {
    _eventos.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> abrirFormularioEvento(
    BuildContext context, {
    TarjetaEventos? evento,
  }) async {
    final resultado = await showModalBottomSheet<TarjetaEventos?>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child:
                evento == null
                    ? const CrearEventoForm()
                    : EditarEventoForm(evento: evento),
          ),
    );

    if (resultado != null) {
      await guardarEvento(resultado);
    }
  }

  List<TarjetaEventos> eventosDelDia(DateTime dia) {
    return _eventos.where((evento) {
      final startDay = DateTime(
        evento.fechaInicio.year,
        evento.fechaInicio.month,
        evento.fechaInicio.day,
      );
      final endDay = DateTime(
        evento.fechaFin.year,
        evento.fechaFin.month,
        evento.fechaFin.day,
      );
      final queryDay = DateTime(dia.year, dia.month, dia.day);

      // El evento es del día si su rango de fechas incluye el día consultado.
      // Un evento que empieza hoy y termina mañana, es "del día" de hoy.
      // Un evento que empieza ayer y termina hoy, es "del día" de hoy.
      return (queryDay.isAtSameMomentAs(startDay) ||
              queryDay.isAfter(startDay)) &&
          (queryDay.isAtSameMomentAs(endDay) || queryDay.isBefore(endDay));
    }).toList();
  }

  List<TarjetaEventos> eventosDeLaSemana(DateTime diaEnLaSemana) {
    // Encuentra el primer día de la semana (Domingo) de la fecha dada
    DateTime startOfWeek = diaEnLaSemana.subtract(
      Duration(days: diaEnLaSemana.weekday % 7),
    );
    // Encuentra el último día de la semana (Sábado)
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Normalizar las fechas a medianoche
    startOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    endOfWeek = DateTime(
      endOfWeek.year,
      endOfWeek.month,
      endOfWeek.day,
      23,
      59,
      59,
    );

    return _eventos.where((evento) {
      // Un evento es de la semana si su rango de fechas se solapa con el rango de la semana
      return evento.fechaFin.isAfter(startOfWeek) &&
          evento.fechaInicio.isBefore(endOfWeek);
    }).toList();
  }

  List<TarjetaEventos> eventosDelMes(DateTime diaEnElMes) {
    return _eventos.where((evento) {
      return (evento.fechaInicio.year == diaEnElMes.year &&
              evento.fechaInicio.month == diaEnElMes.month) ||
          (evento.fechaFin.year == diaEnElMes.year &&
              evento.fechaFin.month == diaEnElMes.month);
    }).toList();
  }

  List<TarjetaEventos> eventosFiltrados() {
    switch (_vistaSeleccionada) {
      case VistaCalendario.Mes:
        return eventosDelMes(_fechaSeleccionada);
      case VistaCalendario.Semana:
        return eventosDeLaSemana(_fechaSeleccionada);
      case VistaCalendario.Dia:
        return eventosDelDia(_fechaSeleccionada);
      case VistaCalendario.Agenda:
        return _eventos
            .where((evento) => evento.fechaFin.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    }
  }
}
