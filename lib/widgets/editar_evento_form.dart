// lib/widgets/editar_evento_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Importa el modelo actualizado y el enum
import '../widgets/tarjeta_eventos.dart';
import '../providers/calendario_provider.dart';

class EditarEventoForm extends StatefulWidget {
  final TarjetaEventos evento;

  const EditarEventoForm({Key? key, required this.evento}) : super(key: key);

  @override
  State<EditarEventoForm> createState() => _EditarEventoFormState();
}

class _EditarEventoFormState extends State<EditarEventoForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;

  late DateTime _fechaInicio;
  late TimeOfDay _horaInicio;
  late DateTime _fechaFin;
  late TimeOfDay _horaFin;
  late bool _esTodoElDia;
  ReglaRepeticion? _reglaRepeticionSeleccionada;
  late Color _colorEvento;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.evento.titulo);
    _descripcionCtrl = TextEditingController(text: widget.evento.descripcion);

    // Separar fecha y hora del evento existente
    _fechaInicio = DateTime(
      widget.evento.fechaInicio.year,
      widget.evento.fechaInicio.month,
      widget.evento.fechaInicio.day,
    );
    _horaInicio = TimeOfDay.fromDateTime(widget.evento.fechaInicio);
    _fechaFin = DateTime(
      widget.evento.fechaFin.year,
      widget.evento.fechaFin.month,
      widget.evento.fechaFin.day,
    );
    _horaFin = TimeOfDay.fromDateTime(widget.evento.fechaFin);

    _esTodoElDia = widget.evento.esTodoElDia;
    _reglaRepeticionSeleccionada =
        widget.evento.reglaRepeticion; // Cargar la regla existente
    _colorEvento = widget.evento.color;
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
      firstDate: DateTime(2000),
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

  void _seleccionarColor() {
    // Mismo código de selección de color que en CrearEventoForm
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
                                    _colorEvento ==
                                            color // Usar _colorEvento aquí
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
          _colorEvento = selectedColor;
        }); // Usar _colorEvento
      }
    });
  }

  void _gestionarRepeticion() {
    // TODO: Mostrar un diálogo o una nueva pantalla para configurar _reglaRepeticionSeleccionada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración de repetición (pendiente)')),
    );
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

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
      fechaInicioCompleta = _combinarFechaYHora(_fechaInicio, _horaInicio);
      fechaFinCompleta = _combinarFechaYHora(_fechaFin, _horaFin);
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
      setState(() => _guardando = false);
      return;
    }

    final eventoActualizado = widget.evento.copyWith(
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fechaInicio: fechaInicioCompleta,
      fechaFin: fechaFinCompleta,
      esTodoElDia: _esTodoElDia,
      color: _colorEvento,
      // Para reglaRepeticion, necesitamos usar ValueGetter para poder pasar null explícitamente si es necesario
      reglaRepeticion: () => _reglaRepeticionSeleccionada,
    );

    final calendarioProv = context.read<CalendarioProvider>();
    try {
      await calendarioProv.guardarEvento(
        eventoActualizado,
      ); // Asumiendo que guardarEvento es async
      if (mounted) Navigator.pop(context, eventoActualizado);
    } catch (e) {
      // Manejar error si es necesario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el evento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _eliminarEvento() async {
    final calendarioProv = context.read<CalendarioProvider>();

    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar evento'),
            content: const Text('¿Estás seguro de eliminar este evento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      try {
        calendarioProv.eliminarEvento(
          widget.evento.id,
        ); // Asumiendo que eliminarEvento es async
        if (mounted) Navigator.pop(context); // Cierra el formulario de edición
        // No se devuelve nada porque el evento se elimina
      } catch (e) {
        // Manejar error si es necesario
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar el evento: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy', 'es');

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Editar Evento',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty)
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
                      prefixIcon: Icon(Icons.notes),
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
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          label: Text(formatoFecha.format(_fechaFin)),
                          onPressed: () => _seleccionarFecha(context, false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_esTodoElDia)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.access_time_outlined,
                              size: 18,
                            ),
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
                        backgroundColor: _colorEvento,
                        radius: 15,
                      ),
                    ),
                    dense: true,
                  ),
                  const SizedBox(height: 20),

                  if (_guardando)
                    const CircularProgressIndicator()
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _eliminarEvento,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _guardarEvento,
                          icon: const Icon(Icons.save_alt_outlined),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
