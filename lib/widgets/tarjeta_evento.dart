// lib/widgets/tarjeta_eventos.dart
import 'package:flutter/material.dart';

class TarjetaEventos {
  final String id;
  String titulo;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFin;
  Color color;
  bool esRecurrente;
  String? repeticion; // 'diaria', 'semanal', 'mensual', etc.
  bool notificar;
  List<String> etiquetas;

  TarjetaEventos({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.fechaInicio,
    required this.fechaFin,
    this.color = Colors.blue,
    this.esRecurrente = false,
    this.repeticion,
    this.notificar = false,
    List<String>? etiquetas,
  }) : etiquetas = etiquetas ?? [];

  // Para facilitar copiado o clonación de eventos
  TarjetaEventos copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Color? color,
    bool? esRecurrente,
    String? repeticion,
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
      esRecurrente: esRecurrente ?? this.esRecurrente,
      repeticion: repeticion ?? this.repeticion,
      notificar: notificar ?? this.notificar,
      etiquetas: etiquetas ?? this.etiquetas,
    );
  }

  // Para facilitar serialización / deserialización (ejemplo para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'color': color.value,
      'esRecurrente': esRecurrente,
      'repeticion': repeticion,
      'notificar': notificar,
      'etiquetas': etiquetas,
    };
  }

  factory TarjetaEventos.fromMap(Map<String, dynamic> map) {
    return TarjetaEventos(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaFin: DateTime.parse(map['fechaFin']),
      color: Color(map['color']),
      esRecurrente: map['esRecurrente'] ?? false,
      repeticion: map['repeticion'],
      notificar: map['notificar'] ?? false,
      etiquetas: List<String>.from(map['etiquetas'] ?? []),
    );
  }
}
