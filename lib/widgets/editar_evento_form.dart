// lib/widgets/editar_evento_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  late DateTime _fechaFin;
  late Color _colorEvento;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.evento.titulo);
    _descripcionCtrl = TextEditingController(text: widget.evento.descripcion);
    _fechaInicio = widget.evento.fechaInicio;
    _fechaFin = widget.evento.fechaFin;
    _colorEvento = widget.evento.color;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaHoraInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );
    if (fecha == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaInicio),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora == null) return;

    final nuevaFechaInicio = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    if (nuevaFechaInicio.isAfter(_fechaFin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha y hora de inicio debe ser antes de la fecha de fin',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _fechaInicio = nuevaFechaInicio;
    });
  }

  Future<void> _seleccionarFechaHoraFin() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );
    if (fecha == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaFin),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora == null) return;

    final nuevaFechaFin = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    if (nuevaFechaFin.isBefore(_fechaInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha y hora de fin debe ser después de la fecha de inicio',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _fechaFin = nuevaFechaFin;
    });
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
                    _coloresDisponibles()
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
                                    _colorEvento == color
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
        });
      }
    });
  }

  List<Color> _coloresDisponibles() {
    return [
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
    ];
  }

  Future<void> _guardarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final eventoActualizado = widget.evento.copyWith(
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      color: _colorEvento,
    );

    final calendarioProv = context.read<CalendarioProvider>();
    await calendarioProv.guardarEvento(eventoActualizado);

    setState(() => _guardando = false);
    if (mounted) Navigator.pop(context, eventoActualizado);
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
      await calendarioProv.eliminarEvento(widget.evento.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm', 'es');

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
          children: [
            Text(
              'Editar Evento',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                      if (valor == null || valor.trim().isEmpty) {
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
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Inicio: ${df.format(_fechaInicio)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _seleccionarFechaHoraInicio,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text('Fin: ${df.format(_fechaFin)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: _seleccionarFechaHoraFin,
                    ),
                  ),
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
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _guardarEvento,
                          icon: const Icon(Icons.save),
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
