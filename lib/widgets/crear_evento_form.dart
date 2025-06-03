// lib/widgets/crear_evento_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'tarjeta_eventos.dart'; // Para TarjetaEventos, TipoFrecuenciaRepeticion, ReglaRepeticion
import 'dialogo_configurar_repeticion.dart'; // Importa el diálogo que creamos

// Provider no se importa aquí si la interacción con él se maneja al hacer pop del formulario.
// import 'package:provider/provider.dart';
// import '../providers/calendario_provider.dart';

class CrearEventoForm extends StatefulWidget {
  final DateTime?
  fechaInicialSeleccionada; // Opcional: para pre-rellenar la fecha

  const CrearEventoForm({super.key, this.fechaInicialSeleccionada});

  @override
  State<CrearEventoForm> createState() => _CrearEventoFormState();
}

class _CrearEventoFormState extends State<CrearEventoForm> {
  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;
  late DateTime _fechaInicio;
  late TimeOfDay _horaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaFin;
  late bool _esTodoElDia;
  ReglaRepeticion? _reglaRepeticionSeleccionada;
  Color _colorSeleccionado = Colors.blue.withOpacity(0.2);

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'es_ES'; // Asegurar locale para DateFormat
    _tituloCtrl = TextEditingController();
    _descripcionCtrl = TextEditingController();

    final DateTime fechaBase =
        widget.fechaInicialSeleccionada ?? DateTime.now();
    final now =
        DateTime.now(); // Para la hora actual si no se pasa fecha inicial

    _fechaInicio = DateTime(fechaBase.year, fechaBase.month, fechaBase.day);
    _horaInicio = TimeOfDay(
      hour: now.hour,
      minute: (now.minute ~/ 15) * 15,
    ); // Hora actual redondeada

    // Si se pasó una fecha inicial, la hora de fin podría ser una hora después
    // Si no, la fecha de fin es la misma que la de inicio (hoy)
    _fechaFin = DateTime(fechaBase.year, fechaBase.month, fechaBase.day);
    _horaFin = TimeOfDay(
      hour: _horaInicio.hour + 1,
      minute: _horaInicio.minute,
    );

    _esTodoElDia = false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  DateTime _combinarFechaYHora(DateTime fecha, TimeOfDay hora) {
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    bool esFechaInicio,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esFechaInicio ? _fechaInicio : _fechaFin,
      firstDate: esFechaInicio ? DateTime(2000) : _fechaInicio,
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );
    if (picked != null) {
      setState(() {
        if (esFechaInicio) {
          _fechaInicio = picked;
          if (_combinarFechaYHora(
            _fechaFin,
            _horaFin,
          ).isBefore(_combinarFechaYHora(_fechaInicio, _horaInicio))) {
            _fechaFin = picked;
            if (_horaFin.hour < _horaInicio.hour ||
                (_horaFin.hour == _horaInicio.hour &&
                    _horaFin.minute < _horaInicio.minute)) {
              _horaFin = TimeOfDay(
                hour: _horaInicio.hour + 1,
                minute: _horaInicio.minute,
              );
            }
          }
        } else {
          if (picked.isBefore(_fechaInicio)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La fecha de fin no puede ser anterior a la fecha de inicio.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _fechaFin = picked;
          }
        }
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context, bool esHoraInicio) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: esHoraInicio ? _horaInicio : _horaFin,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (esHoraInicio) {
          _horaInicio = picked;
          final inicioDT = _combinarFechaYHora(_fechaInicio, _horaInicio);
          final finDT = _combinarFechaYHora(_fechaFin, _horaFin);
          if (finDT.isBefore(inicioDT) || finDT.isAtSameMomentAs(inicioDT)) {
            _horaFin = TimeOfDay(
              hour: _horaInicio.hour + 1,
              minute: _horaInicio.minute,
            );
            if (_fechaFin.isBefore(_fechaInicio)) {
              _fechaFin = _fechaInicio;
            } else if (_fechaFin.isAtSameMomentAs(_fechaInicio) &&
                (_horaFin.hour < _horaInicio.hour ||
                    (_horaFin.hour == _horaInicio.hour &&
                        _horaFin.minute <= _horaInicio.minute))) {
              _horaFin = TimeOfDay(
                hour: _horaInicio.hour + 1,
                minute: _horaInicio.minute,
              );
            }
          }
        } else {
          final inicioDT = _combinarFechaYHora(_fechaInicio, _horaInicio);
          final nuevaFinDT = _combinarFechaYHora(_fechaFin, picked);
          if (nuevaFinDT.isBefore(inicioDT) ||
              nuevaFinDT.isAtSameMomentAs(inicioDT)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La hora de fin debe ser posterior a la hora de inicio.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            _horaFin = picked;
          }
        }
      });
    }
  }

  void _seleccionarColor() {
    showDialog<Color>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Seleccionar color'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          Colors.red.withOpacity(0.2),
                          Colors.orange.withOpacity(0.2),
                          Colors.amber.withOpacity(0.2),
                          Colors.green.withOpacity(0.2),
                          Colors.teal.withOpacity(0.2),
                          Colors.blue.withOpacity(0.2),
                          Colors.indigo.withOpacity(0.2),
                          Colors.purple.withOpacity(0.2),
                          Colors.pink.withOpacity(0.2),
                          Colors.brown.withOpacity(0.2),
                          Colors.grey.withOpacity(0.2),
                        ]
                        .map(
                          (color) => GestureDetector(
                            onTap: () {
                              Navigator.pop(context, color);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border:
                                    _colorSeleccionado == color
                                        ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 3,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    ).then((selectedColor) {
      if (selectedColor != null) {
        setState(() {
          _colorSeleccionado = selectedColor;
        });
      }
    });
  }

  String _obtenerTextoResumenRepeticion() {
    if (_reglaRepeticionSeleccionada == null) {
      return 'No se repite';
    }
    final regla = _reglaRepeticionSeleccionada!;
    String texto = '';
    switch (regla.frecuencia) {
      case TipoFrecuenciaRepeticion.diaria:
        texto =
            regla.intervalo == 1
                ? 'Diariamente'
                : 'Cada ${regla.intervalo} días';
        break;
      case TipoFrecuenciaRepeticion.semanal:
        texto =
            regla.intervalo == 1
                ? 'Semanalmente'
                : 'Cada ${regla.intervalo} semanas';
        if (regla.diasSemana != null && regla.diasSemana!.isNotEmpty) {
          const nombresDias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
          final dias = regla.diasSemana!
              .map((d) {
                if (d >= DateTime.monday && d <= DateTime.sunday) {
                  return nombresDias[d - 1];
                }
                return '';
              })
              .where((s) => s.isNotEmpty)
              .join(', ');
          if (dias.isNotEmpty) texto += ' los $dias';
        }
        break;
      case TipoFrecuenciaRepeticion.mensual:
        texto =
            regla.intervalo == 1
                ? 'Mensualmente'
                : 'Cada ${regla.intervalo} meses';
        if (regla.diaDelMes != null) {
          texto += ' el día ${regla.diaDelMes}';
        }
        break;
      case TipoFrecuenciaRepeticion.anual:
        texto =
            regla.intervalo == 1
                ? 'Anualmente'
                : 'Cada ${regla.intervalo} años';
        break;
    }
    if (regla.fechaFinRepeticion != null) {
      texto +=
          ' hasta ${DateFormat('dd/MM/yyyy', 'es').format(regla.fechaFinRepeticion!)}';
    }
    return texto;
  }

  void _gestionarRepeticion() async {
    final ReglaRepeticion? nuevaRegla = await showDialog<ReglaRepeticion>(
      context: context,
      builder: (BuildContext context) {
        return DialogoConfigurarRepeticion(
          // Usamos el diálogo real
          reglaInicial: _reglaRepeticionSeleccionada,
        );
      },
    );

    if (mounted && nuevaRegla != _reglaRepeticionSeleccionada) {
      setState(() {
        _reglaRepeticionSeleccionada = nuevaRegla;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy', 'es');

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Nuevo Evento',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              Text("Desde", style: Theme.of(context).textTheme.titleSmall),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(formatoFecha.format(_fechaInicio)),
                      onPressed: () => _seleccionarFecha(context, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_esTodoElDia)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(_horaInicio.format(context)),
                        onPressed: () => _seleccionarHora(context, true),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text("Hasta", style: Theme.of(context).textTheme.titleSmall),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(formatoFecha.format(_fechaFin)),
                      onPressed: () => _seleccionarFecha(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_esTodoElDia)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_outlined, size: 18),
                        label: Text(_horaFin.format(context)),
                        onPressed: () => _seleccionarHora(context, false),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Checkbox(
                    value: _esTodoElDia,
                    onChanged: (bool? value) {
                      setState(() {
                        _esTodoElDia = value ?? false;
                      });
                    },
                  ),
                  const Text('Todo el día'),
                ],
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.repeat),
                title: Text(
                  _obtenerTextoResumenRepeticion(),
                ), // Usa la función de resumen
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _gestionarRepeticion, // Llama al diálogo real
                dense: true,
              ),
              const SizedBox(height: 12),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.color_lens),
                title: const Text('Color del evento'),
                trailing: GestureDetector(
                  onTap: _seleccionarColor,
                  child: CircleAvatar(
                    backgroundColor: _colorSeleccionado,
                    radius: 15,
                  ),
                ),
                dense: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    DateTime fechaInicioCompleta;
                    DateTime fechaFinCompleta;

                    if (_esTodoElDia) {
                      fechaInicioCompleta = DateTime(
                        _fechaInicio.year,
                        _fechaInicio.month,
                        _fechaInicio.day,
                        0,
                        0,
                        0,
                      );
                      fechaFinCompleta = DateTime(
                        _fechaFin.year,
                        _fechaFin.month,
                        _fechaFin.day,
                        23,
                        59,
                        59,
                      );
                      if (fechaFinCompleta.isBefore(fechaInicioCompleta)) {
                        fechaFinCompleta = DateTime(
                          fechaInicioCompleta.year,
                          fechaInicioCompleta.month,
                          fechaInicioCompleta.day,
                          23,
                          59,
                          59,
                        );
                      }
                    } else {
                      fechaInicioCompleta = _combinarFechaYHora(
                        _fechaInicio,
                        _horaInicio,
                      );
                      fechaFinCompleta = _combinarFechaYHora(
                        _fechaFin,
                        _horaFin,
                      );
                    }

                    if (fechaFinCompleta.isBefore(fechaInicioCompleta) ||
                        (!_esTodoElDia &&
                            fechaFinCompleta.isAtSameMomentAs(
                              fechaInicioCompleta,
                            ))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La fecha y hora de fin deben ser posteriores al inicio.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final nuevoEvento = TarjetaEventos(
                      id: _uuid.v4(),
                      titulo: _tituloCtrl.text.trim(),
                      descripcion: _descripcionCtrl.text.trim(),
                      fechaInicio: fechaInicioCompleta,
                      fechaFin: fechaFinCompleta,
                      esTodoElDia: _esTodoElDia,
                      color: _colorSeleccionado,
                      reglaRepeticion: _reglaRepeticionSeleccionada,
                    );
                    Navigator.of(context).pop(nuevoEvento);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
