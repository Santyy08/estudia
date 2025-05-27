// lib/providers/calendario_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// Importa los modelos y formularios actualizados
import '../widgets/tarjeta_eventos.dart';
import '../widgets/crear_evento_form.dart';
import '../widgets/editar_evento_form.dart';

// Enum para las vistas del calendario (ya lo tenías, solo para asegurar que esté aquí)
enum VistaCalendario { Mes, Semana, Dia, Agenda }

class CalendarioProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  VistaCalendario _vistaSeleccionada = VistaCalendario.Mes;
  DateTime _fechaSeleccionada = DateTime.now();

  // Lista principal de eventos. Aquí guardaremos solo los eventos "plantilla" o "raíz".
  // Las ocurrencias de eventos recurrentes se generarán al vuelo.
  final List<TarjetaEventos> _eventosRaiz = [];

  CalendarioProvider() {
    // Inicializar con algunos eventos de ejemplo usando la nueva estructura
    _cargarEventosDeEjemplo();
  }

  VistaCalendario get vistaSeleccionada => _vistaSeleccionada;
  DateTime get fechaSeleccionada => _fechaSeleccionada;

  // Este getter ahora generará las ocurrencias de eventos recurrentes para la vista
  List<TarjetaEventos> get eventos {
    // Por ahora, devolvemos los eventos raíz. La generación de ocurrencias se hará
    // en las funciones específicas como eventosDelDia, eventosDeLaSemana, etc.
    // O, si se quiere una lista "plana" de todas las ocurrencias en un rango,
    // se necesitaría una lógica más compleja aquí. Para simplificar, empezamos así.
    return List.unmodifiable(_generarOcurrenciasParaRangoVisual());
  }

  void _cargarEventosDeEjemplo() {
    _eventosRaiz.addAll([
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Clase Historia del Arte',
        descripcion: 'Ver capítulo sobre el Renacimiento.',
        fechaInicio: DateTime(2025, 4, 8, 9, 0),
        fechaFin: DateTime(2025, 4, 8, 10, 0),
        esTodoElDia: false,
        color: Colors.blue.withOpacity(0.2),
        etiquetas: ['Clase'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Tarea: Leer capítulo 5',
        descripcion: 'Leer capítulo 5 del libro de texto.',
        fechaInicio: DateTime(2025, 4, 9, 9, 0),
        fechaFin: DateTime(2025, 4, 9, 10, 0),
        esTodoElDia: false,
        color: Colors.lightGreen.withOpacity(0.2),
        etiquetas: ['Tarea'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Estudiar álgebra',
        descripcion: 'Resolver ejercicios de ecuaciones diferenciales.',
        fechaInicio: DateTime(2025, 4, 10, 10, 30),
        fechaFin: DateTime(2025, 4, 10, 11, 30),
        esTodoElDia: false,
        color: Colors.purple.withOpacity(0.2),
        etiquetas: ['Objetivo'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Clase Filosofía',
        descripcion: 'Debate sobre ética y moral.',
        fechaInicio: DateTime(2025, 4, 11, 11, 0),
        fechaFin: DateTime(2025, 4, 11, 12, 0),
        esTodoElDia: false,
        color: Colors.orange.withOpacity(0.2),
        etiquetas: ['Clase'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Reunión de Proyecto',
        descripcion: 'Discutir avances y próximos pasos.',
        fechaInicio: DateTime(2025, 4, 16, 14, 0),
        fechaFin: DateTime(2025, 4, 16, 15, 0),
        esTodoElDia: false,
        color: Colors.teal.withOpacity(0.2),
        etiquetas: ['Reunión'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Preparar Presentación',
        descripcion: 'Finalizar diapositivas para el viernes.',
        fechaInicio: DateTime(2025, 4, 17, 10, 0),
        fechaFin: DateTime(2025, 4, 17, 12, 0),
        esTodoElDia: false,
        color: Colors.indigo.withOpacity(0.2),
        etiquetas: ['Estudio'],
      ),
      // Ejemplo de evento recurrente (semanal)
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Clase de Yoga Semanal',
        fechaInicio: DateTime(2025, 4, 7, 18, 0), // Lunes 7 de Abril
        fechaFin: DateTime(2025, 4, 7, 19, 0),
        color: Colors.pink.withOpacity(0.2),
        esTodoElDia: false,
        reglaRepeticion: ReglaRepeticion(
          frecuencia: TipoFrecuenciaRepeticion.semanal,
          intervalo: 1,
          diasSemana: [DateTime.monday], // Se repite todos los lunes
          fechaFinRepeticion: DateTime(2025, 6, 30), // Hasta fin de Junio
        ),
        etiquetas: ['Bienestar', 'Clase'],
      ),
      TarjetaEventos(
        id: _uuid.v4(),
        titulo: 'Cumpleaños de Ana',
        fechaInicio: DateTime(2025, 5, 10), // 10 de Mayo
        fechaFin: DateTime(2025, 5, 10, 23, 59, 59), // Fin del día
        esTodoElDia: true, // Evento de todo el día
        color: Colors.amber.withOpacity(0.3),
        etiquetas: ['Personal', 'Cumpleaños'],
      ),
    ]);
  }

  void cambiarVista(VistaCalendario vista) {
    _vistaSeleccionada = vista;
    notifyListeners();
  }

  void cambiarFechaSeleccionada(DateTime fecha) {
    // Normalizar a solo fecha para evitar problemas con la hora al comparar días
    _fechaSeleccionada = DateTime(fecha.year, fecha.month, fecha.day);
    notifyListeners();
  }

  Future<void> guardarEvento(TarjetaEventos evento) async {
    // Si el evento ya existe (por ID), lo reemplazamos. Sino, lo añadimos.
    final index = _eventosRaiz.indexWhere((e) => e.id == evento.id);
    if (index != -1) {
      _eventosRaiz[index] = evento;
    } else {
      _eventosRaiz.add(evento);
    }
    // Aquí iría la lógica para guardar en Firestore
    notifyListeners();
  }

  void eliminarEvento(String id) {
    _eventosRaiz.removeWhere((e) => e.id == id);
    // Aquí iría la lógica para eliminar de Firestore
    // También, si el evento era recurrente, se necesitaría una lógica para
    // eliminar todas sus futuras ocurrencias o solo la serie.
    notifyListeners();
  }

  Future<void> abrirFormularioEvento(
    BuildContext context, {
    TarjetaEventos? evento,
  }) async {
    final resultado = await showModalBottomSheet<TarjetaEventos?>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors
              .transparent, // Para que el Container interno defina el color y bordes
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).cardColor, // Usa el color de fondo de las tarjetas del tema
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child:
                  evento == null
                      ? const CrearEventoForm()
                      : EditarEventoForm(evento: evento),
            ),
          ),
    );

    if (resultado != null) {
      await guardarEvento(resultado);
    }
  }

  // --- Lógica para generar ocurrencias de eventos ---

  List<TarjetaEventos> _generarOcurrencias(
    TarjetaEventos eventoRaiz,
    DateTime rangoInicio,
    DateTime rangoFin,
  ) {
    List<TarjetaEventos> ocurrencias = [];

    if (eventoRaiz.reglaRepeticion == null) {
      // Evento no recurrente, solo verificar si cae en el rango
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

    while (fechaActualOcurrencia.isBefore(rangoFin) &&
        (regla.fechaFinRepeticion == null ||
            fechaActualOcurrencia.isBefore(regla.fechaFinRepeticion!))) {
      // Solo añadir si la ocurrencia actual está dentro del rango visible Y después del inicio original del evento raíz
      if (!fechaActualOcurrencia.isBefore(rangoInicio) &&
          !fechaActualOcurrencia.isBefore(eventoRaiz.fechaInicio)) {
        ocurrencias.add(
          eventoRaiz.copyWith(
            // Creamos una nueva instancia para esta ocurrencia, manteniendo el ID original
            // o podríamos generar IDs únicos por ocurrencia si fuera necesario para excepciones.
            // Por ahora, se usa el mismo ID, asumiendo que la edición afecta a la serie.
            fechaInicio: fechaActualOcurrencia,
            fechaFin: fechaActualOcurrencia.add(duracionEvento),
            // Importante: la regla de repetición no se copia a las instancias individuales generadas
            // para evitar bucles infinitos al generar ocurrencias de ocurrencias.
            // Las instancias son solo eso, instancias, no nuevas series.
            reglaRepeticion:
                () => null, // Las ocurrencias no tienen su propia regla
          ),
        );
      }

      // Avanzar a la siguiente ocurrencia según la regla
      switch (regla.frecuencia) {
        case TipoFrecuenciaRepeticion.diaria:
          fechaActualOcurrencia = fechaActualOcurrencia.add(
            Duration(days: regla.intervalo),
          );
          break;
        case TipoFrecuenciaRepeticion.semanal:
          if (regla.diasSemana == null || regla.diasSemana!.isEmpty) {
            // Si no hay diasSemana definidos, se repite X semanas después en el mismo día de la semana
            fechaActualOcurrencia = fechaActualOcurrencia.add(
              Duration(days: 7 * regla.intervalo),
            );
          } else {
            // Buscar el siguiente día de la semana en la lista que coincida,
            // avanzando las semanas necesarias según el intervalo.
            DateTime proximaFecha = fechaActualOcurrencia;
            do {
              proximaFecha = proximaFecha.add(const Duration(days: 1));
              // Si hemos pasado al siguiente ciclo de intervalo semanal, buscamos desde el inicio de ese ciclo.
              if (proximaFecha.weekday == eventoRaiz.fechaInicio.weekday &&
                  proximaFecha.difference(fechaActualOcurrencia).inDays >=
                      7 * (regla.intervalo - 1) &&
                  !regla.diasSemana!.contains(proximaFecha.weekday)) {
                // Avanzar al inicio de la siguiente semana de intervalo
                int diasParaLunes =
                    (DateTime.monday - proximaFecha.weekday + 7) % 7;
                proximaFecha = DateTime(
                  proximaFecha.year,
                  proximaFecha.month,
                  proximaFecha.day,
                ).add(Duration(days: diasParaLunes));
                proximaFecha = proximaFecha.add(
                  Duration(days: 7 * (regla.intervalo - 1)),
                ); // Saltar semanas de intervalo
              }
            } while (!regla.diasSemana!.contains(proximaFecha.weekday) ||
                proximaFecha.isAtSameMomentAs(fechaActualOcurrencia) ||
                proximaFecha.isBefore(fechaActualOcurrencia));
            fechaActualOcurrencia = DateTime(
              proximaFecha.year,
              proximaFecha.month,
              proximaFecha.day,
              eventoRaiz.fechaInicio.hour,
              eventoRaiz.fechaInicio.minute,
            );
          }
          break;
        case TipoFrecuenciaRepeticion.mensual:
          // Lógica simplificada: suma X meses al día original.
          // Una lógica más robusta manejaría finales de mes (ej. repetir el último día del mes).
          int nuevoMes = fechaActualOcurrencia.month + regla.intervalo;
          int nuevoAnio = fechaActualOcurrencia.year;
          while (nuevoMes > 12) {
            nuevoMes -= 12;
            nuevoAnio++;
          }
          // Intentar mantener el mismo día, si no existe (ej. 31 de Feb), ir al último día válido.
          int dia = regla.diaDelMes ?? eventoRaiz.fechaInicio.day;
          int diasEnMes =
              DateTime(
                nuevoAnio,
                nuevoMes + 1,
                0,
              ).day; // Día 0 del mes siguiente es el último del actual
          if (dia > diasEnMes) {
            dia = diasEnMes;
          }
          fechaActualOcurrencia = DateTime(
            nuevoAnio,
            nuevoMes,
            dia,
            eventoRaiz.fechaInicio.hour,
            eventoRaiz.fechaInicio.minute,
          );
          break;
        case TipoFrecuenciaRepeticion.anual:
          int anio = fechaActualOcurrencia.year + regla.intervalo;
          int mes = regla.mesDelAnio ?? eventoRaiz.fechaInicio.month;
          int dia =
              regla.diaDelMes ??
              eventoRaiz.fechaInicio.day; // Podría ser más específico
          int diasEnMes = DateTime(anio, mes + 1, 0).day;
          if (dia > diasEnMes) {
            dia = diasEnMes;
          }
          fechaActualOcurrencia = DateTime(
            anio,
            mes,
            dia,
            eventoRaiz.fechaInicio.hour,
            eventoRaiz.fechaInicio.minute,
          );
          break;
      }
      // Pequeña salvaguarda para evitar bucles si la fecha no avanza
      if (ocurrencias.isNotEmpty &&
          fechaActualOcurrencia.isAtSameMomentAs(
            ocurrencias.last.fechaInicio,
          )) {
        break;
      }
    }
    return ocurrencias;
  }

  // Método para obtener el rango de fechas que las vistas suelen necesitar
  List<TarjetaEventos> _generarOcurrenciasParaRangoVisual() {
    DateTime rangoInicio;
    DateTime rangoFin;

    // Define un rango amplio para asegurar que todas las vistas tengan datos,
    // podrías optimizar esto para cada vista si es necesario.
    // Por ejemplo, la vista mensual podría necesitar un rango de ~42 días.
    // La vista semanal, 7 días. La vista diaria, 1 día.
    // La agenda, desde hoy hasta X tiempo en el futuro.
    // Para empezar, un rango genérico grande:
    rangoInicio = _fechaSeleccionada.subtract(const Duration(days: 45));
    rangoFin = _fechaSeleccionada.add(const Duration(days: 45));

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
      ); // Domingo
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
      ); // Sábado fin de día
    } else if (_vistaSeleccionada == VistaCalendario.Mes) {
      // Para table_calendar, él mismo pide los eventos por día.
      // Pero si quisiéramos una lista "plana" para el mes, sería algo así:
      final primerDiaDelMesMostrado = DateTime(
        _focusedDayForTableCalendar.year,
        _focusedDayForTableCalendar.month,
        1,
      );
      rangoInicio = primerDiaDelMesMostrado.subtract(
        Duration(days: primerDiaDelMesMostrado.weekday % 7),
      );
      rangoFin = rangoInicio.add(
        const Duration(days: 41, hours: 23, minutes: 59, seconds: 59),
      ); // 6 semanas
    } else if (_vistaSeleccionada == VistaCalendario.Agenda) {
      rangoInicio = DateTime.now();
      rangoFin = rangoInicio.add(
        const Duration(days: 90),
      ); // Agenda para los próximos 90 días
    }

    List<TarjetaEventos> todasLasOcurrencias = [];
    for (var eventoRaiz in _eventosRaiz) {
      todasLasOcurrencias.addAll(
        _generarOcurrencias(eventoRaiz, rangoInicio, rangoFin),
      );
    }

    // Ordenar por fecha de inicio
    todasLasOcurrencias.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return todasLasOcurrencias;
  }

  // Necesario para la vista de mes (TableCalendar)
  DateTime _focusedDayForTableCalendar = DateTime.now();
  void setFocusedDayForTableCalendar(DateTime day) {
    _focusedDayForTableCalendar = day;
    // No necesariamente notificamos listeners aquí, TableCalendar lo maneja internamente
    // pero lo necesitamos para _generarOcurrenciasParaRangoVisual si optimizamos para mes.
  }

  // Funciones específicas para cada vista, usando la generación de ocurrencias
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
    ); // Domingo
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
    ); // Sábado

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
    // Para table_calendar, es mejor que él pida por día.
    // Esta función ahora podría devolver eventos cuya serie *comienza* en ese mes,
    // o usar un rango como en _generarOcurrenciasParaRangoVisual.
    // Por simplicidad y para que coincida con la lógica de table_calendar,
    // es mejor que table_calendar use `eventosDelDia`.
    // Si se necesita una lista de todos los eventos que "tocan" un mes:
    final inicioDelMes = DateTime(diaEnElMes.year, diaEnElMes.month, 1);
    final finDelMes = DateTime(
      diaEnElMes.year,
      diaEnElMes.month + 1,
      0,
      23,
      59,
      59,
    ); // Día 0 del mes siguiente

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
    // Por ejemplo, los próximos 365 días. Ajusta según necesidad.
    final finRangoAgenda = ahora.add(const Duration(days: 365));

    List<TarjetaEventos> ocurrenciasAgenda = [];
    for (var eventoRaiz in _eventosRaiz) {
      // Solo considerar eventos cuya serie podría tener ocurrencias futuras
      if (eventoRaiz.reglaRepeticion == null) {
        // Evento único
        if (!eventoRaiz.fechaInicio.isBefore(
          ahora.subtract(const Duration(days: 1)),
        )) {
          // Que no haya pasado ya (con margen)
          ocurrenciasAgenda.addAll(
            _generarOcurrencias(
              eventoRaiz,
              ahora.subtract(const Duration(days: 1)),
              finRangoAgenda,
            ),
          );
        }
      } else {
        // Evento recurrente
        if (eventoRaiz.reglaRepeticion!.fechaFinRepeticion == null ||
            !eventoRaiz.reglaRepeticion!.fechaFinRepeticion!.isBefore(ahora)) {
          ocurrenciasAgenda.addAll(
            _generarOcurrencias(
              eventoRaiz,
              ahora.subtract(const Duration(days: 1)),
              finRangoAgenda,
            ),
          );
        }
      }
    }
    // Filtrar para asegurar que solo mostramos desde "hoy" en la agenda
    ocurrenciasAgenda =
        ocurrenciasAgenda
            .where(
              (e) =>
                  !e.fechaFin.isBefore(
                    DateTime(ahora.year, ahora.month, ahora.day),
                  ),
            )
            .toList();
    ocurrenciasAgenda.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    return ocurrenciasAgenda;
  }

  // Esta función ya no se usa directamente como antes, se llama a las específicas de cada vista.
  // Podría adaptarse para devolver un conjunto general de eventos si fuera necesario.
  List<TarjetaEventos> eventosFiltrados() {
    switch (_vistaSeleccionada) {
      case VistaCalendario.Mes:
        // La vista de Mes (TableCalendar) llamará a eventosDelDia para cada día.
        // Si se necesita una lista "plana" para otro propósito, se usa eventosDelMes.
        // Para el eventLoader de TableCalendar, él se encarga.
        // Aquí devolvemos un conjunto representativo si se llamase directamente.
        return eventosDelMes(_fechaSeleccionada);
      case VistaCalendario.Semana:
        return eventosDeLaSemana(_fechaSeleccionada);
      case VistaCalendario.Dia:
        return eventosDelDia(_fechaSeleccionada);
      case VistaCalendario.Agenda:
        return eventosParaAgenda();
    }
  }
}
