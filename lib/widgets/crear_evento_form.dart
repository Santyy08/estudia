// lib/widgets/crear_evento_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../widgets/tarjeta_eventos.dart';

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
  Color _colorSeleccionado = Colors.blue.withOpacity(
    0.2,
  ); // Color por defecto pastel

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController();
    _descripcionCtrl = TextEditingController();
    final now = DateTime.now();
    _fechaInicio = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      (now.minute ~/ 5) * 5,
    ); // Redondea al minuto más cercano múltiplo de 5
    _horaInicio = TimeOfDay.fromDateTime(_fechaInicio);
    _fechaFin = _fechaInicio.add(const Duration(hours: 1));
    _horaFin = TimeOfDay.fromDateTime(_fechaFin);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''), // Forzar español para DatePicker
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        // Si la fecha de fin es anterior a la de inicio, ajustarla
        if (_fechaFin.isBefore(_fechaInicio)) {
          _fechaFin = _fechaInicio;
        }
      });
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true), // Formato 24 horas
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaInicio = picked;
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin,
      firstDate:
          _fechaInicio, // No permitir fecha de fin anterior a la de inicio
      lastDate: DateTime(2100),
      locale: const Locale('es', ''), // Forzar español para DatePicker
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
    }
  }

  Future<void> _seleccionarHoraFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaFin,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true), // Formato 24 horas
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaFin = picked;
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

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text(
                'Nuevo Evento',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(_fechaInicio),
                      ),
                      onPressed: _seleccionarFechaInicio,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_horaInicio.format(context)),
                      onPressed: _seleccionarHoraInicio,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
                      onPressed: _seleccionarFechaFin,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_horaFin.format(context)),
                      onPressed: _seleccionarHoraFin,
                    ),
                  ),
                ],
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
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final fechaInicioCompleta = DateTime(
                      _fechaInicio.year,
                      _fechaInicio.month,
                      _fechaInicio.day,
                      _horaInicio.hour,
                      _horaInicio.minute,
                    );
                    final fechaFinCompleta = DateTime(
                      _fechaFin.year,
                      _fechaFin.month,
                      _fechaFin.day,
                      _horaFin.hour,
                      _horaFin.minute,
                    );

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
                      color: _colorSeleccionado,
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
