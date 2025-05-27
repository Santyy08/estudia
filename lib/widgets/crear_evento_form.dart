// lib/widgets/crear_evento_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Asegúrate de que Provider esté importado si lo usas aquí directamente
import 'package:uuid/uuid.dart';
// Importa el modelo actualizado y el enum
import '../widgets/tarjeta_eventos.dart'; // Ya debería estar importando el archivo modificado
// Para acceder a la lógica del calendario

class CrearEventoForm extends StatefulWidget {
  const CrearEventoForm({Key? key}) : super(key: key);

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
  late bool _esTodoElDia; // Nuevo estado para el checkbox
  ReglaRepeticion?
  _reglaRepeticionSeleccionada; // Para guardar la regla de repetición
  Color _colorSeleccionado = Colors.blue.withOpacity(0.2);

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController();
    _descripcionCtrl = TextEditingController();
    final now = DateTime.now();
    // Inicializa _fechaInicio solo con año, mes y día. La hora se maneja por separado.
    _fechaInicio = DateTime(now.year, now.month, now.day);
    _horaInicio = TimeOfDay(
      hour: now.hour,
      minute: (now.minute ~/ 15) * 15,
    ); // Redondea al cuarto de hora más cercano

    // Inicializa _fechaFin igual que _fechaInicio y _horaFin una hora después.
    _fechaFin = DateTime(now.year, now.month, now.day);
    _horaFin = TimeOfDay(
      hour: _horaInicio.hour + 1,
      minute: _horaInicio.minute,
    );

    _esTodoElDia = false; // Por defecto, no es todo el día
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    bool esFechaInicio,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esFechaInicio ? _fechaInicio : _fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );
    if (picked != null) {
      setState(() {
        if (esFechaInicio) {
          _fechaInicio = picked;
          // Si la fecha de fin es anterior a la de inicio, ajustarla
          if (_combinarFechaYHora(
            _fechaFin,
            _horaFin,
          ).isBefore(_combinarFechaYHora(_fechaInicio, _horaInicio))) {
            _fechaFin = picked; // Ajusta también la fecha de fin
            // Podrías también ajustar la hora de fin si quieres mantener la duración
          }
        } else {
          // Asegurarse que la fecha de fin no sea anterior a la de inicio
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
          // Ajustar hora de fin si es necesario para mantener al menos la misma hora o una hora después
          final inicioDT = _combinarFechaYHora(_fechaInicio, _horaInicio);
          final finDT = _combinarFechaYHora(_fechaFin, _horaFin);
          if (finDT.isBefore(inicioDT) || finDT.isAtSameMomentAs(inicioDT)) {
            _horaFin = TimeOfDay(
              hour: _horaInicio.hour + 1,
              minute: _horaInicio.minute,
            );
            // Si la fecha de fin también era anterior, ajustarla
            if (_fechaFin.isBefore(_fechaInicio)) {
              _fechaFin = _fechaInicio;
            } else if (_fechaFin.isAtSameMomentAs(_fechaInicio) &&
                _horaFin.hour < _horaInicio.hour) {
              _horaFin = TimeOfDay(
                hour: _horaInicio.hour + 1,
                minute: _horaInicio.minute,
              );
            }
          }
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  // Helper para combinar fecha (DateTime) y hora (TimeOfDay) en un solo DateTime
  DateTime _combinarFechaYHora(DateTime fecha, TimeOfDay hora) {
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  void _seleccionarColor() {
    // Código para seleccionar color (igual que antes, puedes mantenerlo)
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

  // --- Aquí iría la UI para seleccionar la repetición (lo haremos después) ---
  void _gestionarRepeticion() {
    // TODO: Mostrar un diálogo o una nueva pantalla para configurar _reglaRepeticionSeleccionada
    // Por ahora, solo un placeholder:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de repetición (pendiente)')),
    );
  }
  // --- Fin placeholder repetición ---

  @override
  Widget build(BuildContext context) {
    // Para formatear la fecha y hora en los botones
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
                  if (value == null || value.trim().isEmpty)
                    return 'El título es obligatorio';
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

              // Selector de Fecha y Hora de Inicio
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
                  if (!_esTodoElDia) // Solo mostrar hora si no es "Todo el día"
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

              // Selector de Fecha y Hora de Fin
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
                  if (!_esTodoElDia) // Solo mostrar hora si no es "Todo el día"
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

              // Checkbox para "Todo el día"
              Row(
                children: [
                  Checkbox(
                    value: _esTodoElDia,
                    onChanged: (bool? value) {
                      setState(() {
                        _esTodoElDia = value ?? false;
                        if (_esTodoElDia) {
                          // Si es todo el día, las horas podrían ser 00:00 a 23:59 lógicamente
                          // o simplemente ignorarse al guardar el evento.
                          // Por ahora, solo actualizamos el estado.
                        }
                      });
                    },
                  ),
                  const Text('Todo el día'),
                ],
              ),
              const SizedBox(height: 12),

              // Botón para gestionar repetición (funcionalidad futura)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.repeat),
                title: Text(
                  _reglaRepeticionSeleccionada == null
                      ? 'No se repite'
                      : 'Se repite (detalle pendiente)', // TODO: Mostrar resumen de la regla
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _gestionarRepeticion,
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
                    // Combinar fechas y horas para obtener los DateTime completos
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
                      ); // Inicio del día
                      fechaFinCompleta = DateTime(
                        _fechaFin.year,
                        _fechaFin.month,
                        _fechaFin.day,
                        23,
                        59,
                        59,
                      ); // Fin del día
                      // Asegurarse que fechaFin no sea anterior a fechaInicio si es todo el día y dura varios días
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

                    if (fechaFinCompleta.isBefore(fechaInicioCompleta)) {
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
                      esTodoElDia: _esTodoElDia, // Guardar el nuevo campo
                      color: _colorSeleccionado,
                      reglaRepeticion:
                          _reglaRepeticionSeleccionada, // Guardar la regla
                    );
                    // Devolver el evento al CalendarioProvider a través de Navigator.pop
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
