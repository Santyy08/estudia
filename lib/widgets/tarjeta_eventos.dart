// lib/widgets/tarjeta_eventos.dart
import 'package:flutter/material.dart';

// Define un Enum para los tipos de frecuencia
enum TipoFrecuenciaRepeticion { diaria, semanal, mensual, anual }

class ReglaRepeticion {
  final TipoFrecuenciaRepeticion frecuencia;
  final int intervalo; // Ej: si es diaria e intervalo es 2, es cada 2 días
  final List<int>? diasSemana; // Lunes=1, ..., Domingo=7 (solo para semanal)
  final int? diaDelMes; // Solo para mensual (ej. el día 15 de cada mes)
  final int? mesDelAnio; // Solo para anual (ej. el mes 3 - Marzo)
  final DateTime? fechaFinRepeticion; // Hasta cuándo se repite

  ReglaRepeticion({
    required this.frecuencia,
    this.intervalo = 1,
    this.diasSemana,
    this.diaDelMes,
    this.mesDelAnio,
    this.fechaFinRepeticion,
  });

  // Método para convertir esta regla a un formato guardable (ej. para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'frecuencia': frecuencia.name, // Guarda el nombre del enum (ej. 'diaria')
      'intervalo': intervalo,
      'diasSemana': diasSemana,
      'diaDelMes': diaDelMes,
      'mesDelAnio': mesDelAnio,
      'fechaFinRepeticion':
          fechaFinRepeticion?.toIso8601String(), // Convierte DateTime a texto
    };
  }

  // Método para crear una regla desde un formato guardado
  factory ReglaRepeticion.fromMap(Map<String, dynamic> map) {
    return ReglaRepeticion(
      frecuencia: TipoFrecuenciaRepeticion.values.firstWhere(
        (e) => e.name == map['frecuencia'],
        orElse:
            () =>
                TipoFrecuenciaRepeticion
                    .diaria, // Valor por defecto si hay error
      ),
      intervalo: map['intervalo'] ?? 1,
      diasSemana:
          map['diasSemana'] != null ? List<int>.from(map['diasSemana']) : null,
      diaDelMes: map['diaDelMes'],
      mesDelAnio: map['mesDelAnio'],
      fechaFinRepeticion:
          map['fechaFinRepeticion'] != null
              ? DateTime.parse(
                map['fechaFinRepeticion'],
              ) // Convierte texto a DateTime
              : null,
    );
  }
}

class TarjetaEventos {
  final String id;
  String titulo;
  String descripcion;
  DateTime fechaInicio; // Incluye fecha y hora de inicio
  DateTime fechaFin; // Incluye fecha y hora de fin
  Color color;
  bool esTodoElDia; // Nuevo campo para eventos que duran todo el día
  ReglaRepeticion? reglaRepeticion; // Para manejar eventos recurrentes
  bool notificar;
  List<String> etiquetas;

  TarjetaEventos({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.fechaInicio,
    required this.fechaFin,
    this.color = Colors.blue,
    this.esTodoElDia = false, // Por defecto, un evento no es de todo el día
    this.reglaRepeticion, // Puede ser nulo si el evento no se repite
    this.notificar = false,
    List<String>? etiquetas,
  }) : etiquetas = etiquetas ?? [];

  // Propiedad para saber fácilmente si un evento es recurrente
  bool get esRecurrente => reglaRepeticion != null;

  // Método para copiar un evento, modificando algunos campos si es necesario
  TarjetaEventos copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Color? color,
    bool? esTodoElDia,
    ValueGetter<ReglaRepeticion?>?
    reglaRepeticion, // Permite pasar null para borrar la regla
    bool? notificar,
    List<String>? etiquetas,
  }) {
    return TarjetaEventos(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      color: color ?? this.color,
      esTodoElDia: esTodoElDia ?? this.esTodoElDia,
      reglaRepeticion:
          reglaRepeticion != null ? reglaRepeticion() : this.reglaRepeticion,
      notificar: notificar ?? this.notificar,
      etiquetas: etiquetas ?? this.etiquetas,
    );
  }

  // Método para convertir el evento a un formato guardable
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'color': color.value, // Guarda el valor numérico del color
      'esTodoElDia': esTodoElDia,
      'reglaRepeticion': reglaRepeticion?.toMap(), // Guarda la regla si existe
      'notificar': notificar,
      'etiquetas': etiquetas,
    };
  }

  // Método para crear un evento desde un formato guardado
  factory TarjetaEventos.fromMap(Map<String, dynamic> map) {
    return TarjetaEventos(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaFin: DateTime.parse(map['fechaFin']),
      color: Color(map['color']), // Crea el color desde su valor numérico
      esTodoElDia: map['esTodoElDia'] ?? false,
      reglaRepeticion:
          map['reglaRepeticion'] != null
              ? ReglaRepeticion.fromMap(
                Map<String, dynamic>.from(map['reglaRepeticion']),
              )
              : null,
      notificar: map['notificar'] ?? false,
      etiquetas: List<String>.from(map['etiquetas'] ?? []),
    );
  }
}
