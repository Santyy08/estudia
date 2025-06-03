// lib/providers/calendario_provider.dart
import 'dart:async'; // Para StreamSubscription
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Asegúrate que Uuid esté en pubspec.yaml
import 'package:intl/intl.dart'; // Para formateo en el resumen de repetición

import '../widgets/tarjeta_eventos.dart';
import '../widgets/crear_evento_form.dart';
import '../widgets/editar_evento_form.dart';
import '../servicios/firestore_service.dart'; // Importa tu servicio de Firestore

enum VistaCalendario { Mes, Semana, Dia, Agenda }

class CalendarioProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  final FirestoreService _firestoreService = FirestoreService();
  final String userId; // Para identificar al usuario en Firestore

  VistaCalendario _vistaSeleccionada = VistaCalendario.Mes;
  DateTime _fechaSeleccionada = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime _focusedDayForTableCalendar = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  List<TarjetaEventos> _eventosRaiz =
      []; // Eventos "plantilla" cargados de Firestore
  StreamSubscription? _eventosSubscription;

  CalendarioProvider(this.userId) {
    // print("CalendarioProvider inicializado para userId: $userId");
    if (userId.isEmpty) {
      print(
        "ADVERTENCIA: userId está vacío en CalendarioProvider. Los eventos no se cargarán/guardarán.",
      );
      return;
    }
    _escucharEventosDeFirestore();
  }

  void _escucharEventosDeFirestore() {
    _eventosSubscription?.cancel(); // Cancela suscripción anterior si existe
    _eventosSubscription = _firestoreService
        .obtenerEventosStream(userId)
        .listen(
          (eventosDesdeFirestore) {
            _eventosRaiz = eventosDesdeFirestore;
            // print('Eventos cargados/actualizados desde Firestore: ${_eventosRaiz.length} para userId: $userId');
            notifyListeners();
          },
          onError: (error) {
            print(
              'Error al escuchar eventos de Firestore para userId $userId: $error',
            );
            _eventosRaiz =
                []; // En caso de error, limpiar eventos para evitar datos corruptos
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _eventosSubscription?.cancel();
    super.dispose();
  }

  // GETTERS
  VistaCalendario get vistaSeleccionada => _vistaSeleccionada;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  List<TarjetaEventos> get eventos => List.unmodifiable(
    _generarOcurrenciasParaRangoVisual(),
  ); // Genera ocurrencias al vuelo

  // SETTERS / ACTIONS
  void cambiarVista(VistaCalendario vista) {
    _vistaSeleccionada = vista;
    notifyListeners();
  }

  void cambiarFechaSeleccionada(DateTime fecha) {
    _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
    // Si la vista es Mes, también actualizamos el foco de TableCalendar
    if (_vistaSeleccionada == VistaCalendario.Mes) {
      setFocusedDayForTableCalendar(_fechaSeleccionada);
    }
    notifyListeners();
  }

  void setFocusedDayForTableCalendar(DateTime day) {
    _focusedDayForTableCalendar = DateTime(day.year, day.month, day.day);
    // No es necesario notificar listeners aquí usualmente, ya que TableCalendar maneja su propio estado de foco
    // pero sí es importante para que _generarOcurrenciasParaRangoVisual funcione bien para la vista de mes.
    if (_vistaSeleccionada == VistaCalendario.Mes) {
      notifyListeners(); // Para que la lista de eventos debajo del mes se actualice si depende de _focusedDay
    }
  }

  Future<void> guardarEvento(TarjetaEventos evento) async {
    if (userId.isEmpty) {
      print("Error: No se puede guardar evento, userId está vacío.");
      return;
    }
    // Optimistic update (actualiza UI local primero)
    final index = _eventosRaiz.indexWhere((e) => e.id == evento.id);
    bool esNuevo = false;
    if (index != -1) {
      _eventosRaiz[index] = evento;
    } else {
      _eventosRaiz.add(evento);
      esNuevo = true;
    }
    notifyListeners();

    try {
      if (esNuevo) {
        await _firestoreService.agregarEvento(evento, userId);
      } else {
        await _firestoreService.actualizarEvento(evento, userId);
      }
    } catch (e) {
      print('Error al guardar evento en Firestore: $e');
      // Considerar revertir el optimistic update o mostrar error al usuario
      // Por ahora, si falla, la UI local queda con el cambio pero no se persiste.
      // Para revertir, necesitarías cargar de nuevo desde Firestore o guardar el estado anterior.
    }
  }

  Future<void> eliminarEvento(String eventoId) async {
    if (userId.isEmpty) {
      print("Error: No se puede eliminar evento, userId está vacío.");
      return;
    }
    // Optimistic update
    final eventoOriginal = _eventosRaiz.firstWhere(
      (e) => e.id == eventoId,
      orElse:
          () => TarjetaEventos(
            id: '',
            titulo: '',
            fechaInicio: DateTime.now(),
            fechaFin: DateTime.now(),
          ),
    ); // Necesitamos una forma de manejar el orElse que no lance error
    _eventosRaiz.removeWhere((e) => e.id == eventoId);
    notifyListeners();

    try {
      await _firestoreService.eliminarEvento(eventoId, userId);
    } catch (e) {
      print('Error al eliminar evento en Firestore: $e');
      // Revertir si falla (re-añadir eventoOriginal a _eventosRaiz)
      // _eventosRaiz.add(eventoOriginal); // Ejemplo simple de revertir
      // notifyListeners();
    }
  }

  Future<void> abrirFormularioEvento(
    BuildContext context, {
    TarjetaEventos? evento,
    DateTime? fechaSugerida,
  }) async {
    final TarjetaEventos? resultado =
        await showModalBottomSheet<TarjetaEventos?>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (_) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child:
                      evento == null
                          ? CrearEventoForm(
                            fechaInicialSeleccionada:
                                fechaSugerida ?? _fechaSeleccionada,
                          )
                          : EditarEventoForm(evento: evento),
                ),
              ),
        );

    if (resultado != null) {
      await guardarEvento(resultado);
    }
  }

  // --- LÓGICA DE GENERACIÓN DE OCURRENCIAS (Mantenida y mejorada) ---
  List<TarjetaEventos> _generarOcurrencias(
    TarjetaEventos eventoRaiz,
    DateTime rangoInicio,
    DateTime rangoFin,
  ) {
    List<TarjetaEventos> ocurrencias = [];

    if (eventoRaiz.reglaRepeticion == null) {
      // Evento no recurrente
      if (!(eventoRaiz.fechaFin.isBefore(rangoInicio) ||
          eventoRaiz.fechaInicio.isAfter(rangoFin))) {
        ocurrencias.add(eventoRaiz);
      }
      return ocurrencias;
    }

    final regla = eventoRaiz.reglaRepeticion!;
    DateTime fechaActualOcurrencia = eventoRaiz.fechaInicio;
    final duracionEvento = eventoRaiz.fechaFin.difference(
      eventoRaiz.fechaInicio,
    );

    int contadorSeguridad = 0;
    final int maxOcurrenciasSeguridad =
        730; // Limitar a ~2 años de ocurrencias por evento raíz

    while (fechaActualOcurrencia.isBefore(
          rangoFin.add(const Duration(days: 1)),
        ) && // Comparar hasta el final del día de rangoFin
        (regla.fechaFinRepeticion == null ||
            fechaActualOcurrencia.isBefore(
              regla.fechaFinRepeticion!.add(const Duration(days: 1)),
            )) &&
        contadorSeguridad < maxOcurrenciasSeguridad) {
      contadorSeguridad++;

      if (!fechaActualOcurrencia.isBefore(rangoInicio) &&
          !fechaActualOcurrencia.isBefore(eventoRaiz.fechaInicio)) {
        ocurrencias.add(
          eventoRaiz.copyWith(
            id: eventoRaiz.id, // Mantener ID original para la serie
            fechaInicio: DateTime(
              fechaActualOcurrencia.year,
              fechaActualOcurrencia.month,
              fechaActualOcurrencia.day,
              eventoRaiz.fechaInicio.hour,
              eventoRaiz.fechaInicio.minute,
            ),
            fechaFin: DateTime(
              fechaActualOcurrencia.year,
              fechaActualOcurrencia.month,
              fechaActualOcurrencia.day,
              eventoRaiz.fechaInicio.hour,
              eventoRaiz.fechaInicio.minute,
            ).add(duracionEvento),
            reglaRepeticion: () => null,
          ),
        );
      }

      if (fechaActualOcurrencia.isAfter(rangoFin) &&
          (regla.fechaFinRepeticion != null &&
              fechaActualOcurrencia.isAfter(regla.fechaFinRepeticion!))) {
        break; // Optimización: si ya pasamos ambos rangos
      }

      DateTime siguienteTentativa = fechaActualOcurrencia;
      switch (regla.frecuencia) {
        case TipoFrecuenciaRepeticion.diaria:
          siguienteTentativa = fechaActualOcurrencia.add(
            Duration(days: regla.intervalo),
          );
          break;
        case TipoFrecuenciaRepeticion.semanal:
          DateTime tempDate = fechaActualOcurrencia;
          if (ocurrencias.isNotEmpty &&
              ocurrencias.last.fechaInicio.year == fechaActualOcurrencia.year &&
              ocurrencias.last.fechaInicio.month ==
                  fechaActualOcurrencia.month &&
              ocurrencias.last.fechaInicio.day == fechaActualOcurrencia.day) {
            tempDate = tempDate.add(
              const Duration(days: 1),
            ); // Asegurar avance si ya se añadió para este día
          } else if (contadorSeguridad == 1 &&
              (regla.diasSemana?.contains(tempDate.weekday) ?? false)) {
            // No avanzar el primer día si ya coincide con un día de la semana de la regla
          } else {
            tempDate = tempDate.add(const Duration(days: 1));
          }

          int diasBuscadosEnCiclo = 0;
          bool encontradaEnCiclo = false;
          while (diasBuscadosEnCiclo < (7 * regla.intervalo)) {
            if ((regla.diasSemana?.contains(tempDate.weekday) ??
                    (tempDate.weekday == eventoRaiz.fechaInicio.weekday)) &&
                tempDate.isAfter(fechaActualOcurrencia)) {
              // Comprobar si estamos en el intervalo correcto de semanas
              int semanasCompletasDesdeInicio =
                  (DateTime(tempDate.year, tempDate.month, tempDate.day)
                              .difference(
                                DateTime(
                                  eventoRaiz.fechaInicio.year,
                                  eventoRaiz.fechaInicio.month,
                                  eventoRaiz.fechaInicio.day,
                                ),
                              )
                              .inDays /
                          7)
                      .floor();

              if (semanasCompletasDesdeInicio % regla.intervalo == 0) {
                siguienteTentativa = tempDate;
                encontradaEnCiclo = true;
                break;
              }
            }
            tempDate = tempDate.add(const Duration(days: 1));
            diasBuscadosEnCiclo++;
          }
          if (!encontradaEnCiclo) {
            // Si no se encontró en el ciclo, saltar al siguiente intervalo de semanas
            int diasParaInicioIntervalo =
                (7 * regla.intervalo) -
                (fechaActualOcurrencia
                        .difference(eventoRaiz.fechaInicio)
                        .inDays %
                    (7 * regla.intervalo));
            if (diasParaInicioIntervalo == (7 * regla.intervalo)) {
              diasParaInicioIntervalo =
                  0; // Ya estamos al inicio de un intervalo
            }
            siguienteTentativa = fechaActualOcurrencia.add(
              Duration(
                days:
                    diasParaInicioIntervalo == 0
                        ? 7 * regla.intervalo
                        : diasParaInicioIntervalo,
              ),
            );
            // Y luego buscar el primer día válido de la semana
            diasBuscadosEnCiclo = 0;
            while (diasBuscadosEnCiclo < 7) {
              if (regla.diasSemana?.contains(siguienteTentativa.weekday) ??
                  (siguienteTentativa.weekday ==
                      eventoRaiz.fechaInicio.weekday)) {
                break;
              }
              siguienteTentativa = siguienteTentativa.add(
                const Duration(days: 1),
              );
              diasBuscadosEnCiclo++;
            }
          }

          break;
        case TipoFrecuenciaRepeticion.mensual:
          int currentMonth = fechaActualOcurrencia.month;
          int currentYear = fechaActualOcurrencia.year;
          int targetDay = regla.diaDelMes ?? eventoRaiz.fechaInicio.day;

          currentMonth += regla.intervalo;
          while (currentMonth > 12) {
            currentMonth -= 12;
            currentYear++;
          }

          int daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
          siguienteTentativa = DateTime(
            currentYear,
            currentMonth,
            targetDay > daysInMonth
                ? daysInMonth
                : targetDay, // Ajustar al último día si targetDay no existe
            eventoRaiz.fechaInicio.hour,
            eventoRaiz.fechaInicio.minute,
          );
          // Si la siguiente fecha calculada es anterior o igual a la actual (ej. al cambiar de un mes largo a uno corto)
          // y el día objetivo es el mismo, forzar avance al siguiente mes de intervalo.
          if (siguienteTentativa.isBefore(fechaActualOcurrencia) ||
              siguienteTentativa.isAtSameMomentAs(fechaActualOcurrencia)) {
            currentMonth =
                siguienteTentativa.month + regla.intervalo; // Avanzar de nuevo
            currentYear = siguienteTentativa.year;
            while (currentMonth > 12) {
              currentMonth -= 12;
              currentYear++;
            }
            daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
            siguienteTentativa = DateTime(
              currentYear,
              currentMonth,
              targetDay > daysInMonth ? daysInMonth : targetDay,
              eventoRaiz.fechaInicio.hour,
              eventoRaiz.fechaInicio.minute,
            );
          }
          break;
        case TipoFrecuenciaRepeticion.anual:
          siguienteTentativa = DateTime(
            fechaActualOcurrencia.year + regla.intervalo,
            regla.mesDelAnio ?? eventoRaiz.fechaInicio.month,
            regla.diaDelMes ?? eventoRaiz.fechaInicio.day,
            eventoRaiz.fechaInicio.hour,
            eventoRaiz.fechaInicio.minute,
          );
          break;
      }

      if (siguienteTentativa.isAtSameMomentAs(fechaActualOcurrencia) ||
          siguienteTentativa.isBefore(fechaActualOcurrencia)) {
        // print("Advertencia: No se pudo avanzar la fecha para evento ${eventoRaiz.titulo}. Forzando salida del bucle de recurrencia.");
        contadorSeguridad = maxOcurrenciasSeguridad; // Forzar salida
      }
      fechaActualOcurrencia = siguienteTentativa;
    }
    return ocurrencias;
  }

  List<TarjetaEventos> _generarOcurrenciasParaRangoVisual() {
    DateTime rangoInicio;
    DateTime rangoFin;

    if (_vistaSeleccionada == VistaCalendario.Dia) {
      rangoInicio = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        0,
        0,
        0,
      );
      rangoFin = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        23,
        59,
        59,
      );
    } else if (_vistaSeleccionada == VistaCalendario.Semana) {
      rangoInicio = _fechaSeleccionada.subtract(
        Duration(days: _fechaSeleccionada.weekday % 7),
      );
      rangoInicio = DateTime(
        rangoInicio.year,
        rangoInicio.month,
        rangoInicio.day,
        0,
        0,
        0,
      );
      rangoFin = rangoInicio.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    } else if (_vistaSeleccionada == VistaCalendario.Mes) {
      final primerDiaDelMesMostrado = DateTime(
        _focusedDayForTableCalendar.year,
        _focusedDayForTableCalendar.month,
        1,
      );
      rangoInicio = DateTime(
        primerDiaDelMesMostrado.year,
        primerDiaDelMesMostrado.month,
        1,
      ).subtract(const Duration(days: 7));
      rangoFin = DateTime(
        primerDiaDelMesMostrado.year,
        primerDiaDelMesMostrado.month + 1,
        0,
      ).add(const Duration(days: 7, hours: 23, minutes: 59, seconds: 59));
    } else if (_vistaSeleccionada == VistaCalendario.Agenda) {
      rangoInicio = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      rangoFin = rangoInicio.add(
        const Duration(days: 90, hours: 23, minutes: 59, seconds: 59),
      );
    } else {
      rangoInicio = _fechaSeleccionada.subtract(const Duration(days: 30));
      rangoFin = _fechaSeleccionada.add(
        const Duration(days: 30, hours: 23, minutes: 59, seconds: 59),
      );
    }

    List<TarjetaEventos> todasLasOcurrencias = [];
    for (var eventoRaiz in _eventosRaiz) {
      todasLasOcurrencias.addAll(
        _generarOcurrencias(eventoRaiz, rangoInicio, rangoFin),
      );
    }

    todasLasOcurrencias.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return todasLasOcurrencias;
  }

  List<TarjetaEventos> eventosDelDia(DateTime dia) {
    final inicioDelDia = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final finDelDia = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    List<TarjetaEventos> ocurrenciasDelDia = [];
    for (var eventoRaiz in _eventosRaiz) {
      ocurrenciasDelDia.addAll(
        _generarOcurrencias(eventoRaiz, inicioDelDia, finDelDia),
      );
    }
    ocurrenciasDelDia.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return ocurrenciasDelDia;
  }

  List<TarjetaEventos> eventosDeLaSemana(DateTime diaEnLaSemana) {
    DateTime inicioSemana = diaEnLaSemana.subtract(
      Duration(days: diaEnLaSemana.weekday % 7),
    );
    inicioSemana = DateTime(
      inicioSemana.year,
      inicioSemana.month,
      inicioSemana.day,
      0,
      0,
      0,
    );
    DateTime finSemana = inicioSemana.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    List<TarjetaEventos> ocurrenciasSemana = [];
    for (var eventoRaiz in _eventosRaiz) {
      ocurrenciasSemana.addAll(
        _generarOcurrencias(eventoRaiz, inicioSemana, finSemana),
      );
    }
    ocurrenciasSemana.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return ocurrenciasSemana;
  }

  List<TarjetaEventos> eventosDelMes(DateTime diaEnElMes) {
    final inicioDelMes = DateTime(diaEnElMes.year, diaEnElMes.month, 1);
    final finDelMes = DateTime(
      diaEnElMes.year,
      diaEnElMes.month + 1,
      0,
      23,
      59,
      59,
    );

    List<TarjetaEventos> ocurrenciasMes = [];
    for (var eventoRaiz in _eventosRaiz) {
      ocurrenciasMes.addAll(
        _generarOcurrencias(eventoRaiz, inicioDelMes, finDelMes),
      );
    }
    ocurrenciasMes.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return ocurrenciasMes;
  }

  List<TarjetaEventos> eventosParaAgenda() {
    final ahora = DateTime.now();
    final inicioRangoAgenda = DateTime(ahora.year, ahora.month, ahora.day);
    final finRangoAgenda = inicioRangoAgenda.add(
      const Duration(days: 90, hours: 23, minutes: 59, seconds: 59),
    );

    List<TarjetaEventos> ocurrenciasAgenda = [];
    for (var eventoRaiz in _eventosRaiz) {
      ocurrenciasAgenda.addAll(
        _generarOcurrencias(eventoRaiz, inicioRangoAgenda, finRangoAgenda),
      );
    }
    ocurrenciasAgenda.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return ocurrenciasAgenda;
  }

  List<TarjetaEventos> eventosFiltrados() {
    // Esta función es llamada por TableCalendar y otras vistas.
    switch (_vistaSeleccionada) {
      case VistaCalendario.Mes:
        // Para TableCalendar, el eventLoader llama a eventosDelDia.
        // Si esta función se llamara para obtener todos los eventos del mes visible en la UI,
        // usaríamos _focusedDayForTableCalendar para definir el mes.
        return eventosDelMes(_focusedDayForTableCalendar);
      case VistaCalendario.Semana:
        return eventosDeLaSemana(_fechaSeleccionada);
      case VistaCalendario.Dia:
        return eventosDelDia(_fechaSeleccionada);
      case VistaCalendario.Agenda:
        return eventosParaAgenda();
    }
  }
}
