import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos con Persistencia',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const PantallaEventos(),
    );
  }
}

class Evento {
  String tipo;
  String contenido;
  String? hora;
  IconData icono;
  Color color;
  bool recurrente;
  String? notasRapidas;
  List<String>? adjuntos;
  bool completado;

  Evento({
    required this.tipo,
    required this.contenido,
    this.hora,
    required this.icono,
    required this.color,
    this.recurrente = false,
    this.notasRapidas,
    this.adjuntos,
    this.completado = false,
  });

  // Para guardar y recuperar en SharedPreferences, serializamos a JSON

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'contenido': contenido,
      'hora': hora,
      'iconCodePoint': icono.codePoint,
      'iconFontFamily': icono.fontFamily,
      'iconFontPackage': icono.fontPackage,
      'colorValue': color.value,
      'recurrente': recurrente,
      'notasRapidas': notasRapidas,
      'adjuntos': adjuntos,
      'completado': completado,
    };
  }

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      tipo: map['tipo'] ?? '',
      contenido: map['contenido'] ?? '',
      hora: map['hora'],
      icono: IconData(
        map['iconCodePoint'] ?? Icons.event.codePoint,
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      ),
      color: Color(map['colorValue'] ?? Colors.grey.value),
      recurrente: map['recurrente'] ?? false,
      notasRapidas: map['notasRapidas'],
      adjuntos:
          (map['adjuntos'] != null) ? List<String>.from(map['adjuntos']) : null,
      completado: map['completado'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Evento.fromJson(String source) => Evento.fromMap(json.decode(source));
}

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  List<Evento> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList('eventos') ?? [];
    setState(() {
      _eventos = listaJson.map((e) => Evento.fromJson(e)).toList();
      _cargando = false;
    });
  }

  Future<void> _guardarEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = _eventos.map((e) => e.toJson()).toList();
    await prefs.setStringList('eventos', listaJson);
  }

  void _cambiarCompletado(int index, bool valor) {
    setState(() {
      _eventos[index].completado = valor;
    });
    _guardarEventos();
  }

  Future<void> _mostrarFormulario([Evento? evento, int? index]) async {
    final resultado = await showModalBottomSheet<Evento>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FormularioEvento(evento: evento),
          ),
    );

    if (resultado != null) {
      setState(() {
        if (index != null) {
          _eventos[index] = resultado;
        } else {
          _eventos.add(resultado);
        }
      });
      await _guardarEventos();
    }
  }

  void _eliminarEvento(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar evento'),
            content: const Text('¿Seguro que quieres eliminar este evento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      setState(() {
        _eventos.removeAt(index);
      });
      await _guardarEventos();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Eventos')),
      body:
          _eventos.isEmpty
              ? const Center(child: Text('No tienes eventos, agrega uno :)'))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _eventos.length,
                itemBuilder: (context, index) {
                  final evento = _eventos[index];
                  return Dismissible(
                    key: ValueKey(
                      evento.tipo + evento.hora.toString() + index.toString(),
                    ),
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blueAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    confirmDismiss: (direccion) async {
                      if (direccion == DismissDirection.startToEnd) {
                        // eliminar
                        await _eliminarEvento(index);
                        return false;
                      } else if (direccion == DismissDirection.endToStart) {
                        // editar
                        _mostrarFormulario(evento, index);
                        return false;
                      }
                      return false;
                    },
                    child: TarjetaEvento(
                      tipo: evento.tipo,
                      contenido: evento.contenido,
                      hora: evento.hora,
                      icono: evento.icono,
                      color: evento.color,
                      recurrente: evento.recurrente,
                      notasRapidas: evento.notasRapidas,
                      adjuntos: evento.adjuntos,
                      completado: evento.completado,
                      onCompletadoChanged: (valor) {
                        _cambiarCompletado(index, valor);
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar evento',
      ),
    );
  }
}

class TarjetaEvento extends StatefulWidget {
  final String tipo;
  final String contenido;
  final String? hora;
  final IconData icono;
  final Color color;
  final bool recurrente;
  final String? notasRapidas;
  final List<String>? adjuntos;
  final bool completado;
  final ValueChanged<bool> onCompletadoChanged;

  const TarjetaEvento({
    super.key,
    required this.tipo,
    required this.contenido,
    this.hora,
    required this.icono,
    required this.color,
    this.recurrente = false,
    this.notasRapidas,
    this.adjuntos,
    this.completado = false,
    required this.onCompletadoChanged,
  });

  @override
  State<TarjetaEvento> createState() => _TarjetaEventoState();
}

class _TarjetaEventoState extends State<TarjetaEvento>
    with SingleTickerProviderStateMixin {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.color.withOpacity(0.2),
              child: Icon(widget.icono, color: widget.color),
            ),
            title: Text(
              widget.tipo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contenido, style: const TextStyle(fontSize: 14)),
                if (widget.hora != null && widget.hora!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '🕒 ${widget.hora}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                if (widget.recurrente)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: const [
                        Icon(Icons.repeat, size: 14, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text(
                          'Recurrente',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Checkbox(
              value: widget.completado,
              onChanged: (valor) {
                if (valor != null) widget.onCompletadoChanged(valor);
              },
            ),
            onTap: () {
              setState(() {
                _expandido = !_expandido;
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child:
                _expandido
                    ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.notasRapidas != null &&
                              widget.notasRapidas!.isNotEmpty)
                            Text('Notas: ${widget.notasRapidas}'),
                          if (widget.adjuntos != null &&
                              widget.adjuntos!.isNotEmpty)
                            Text('Adjuntos: ${widget.adjuntos!.join(', ')}'),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class FormularioEvento extends StatefulWidget {
  final Evento? evento;

  const FormularioEvento({super.key, this.evento});

  @override
  State<FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<FormularioEvento> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tipoController;
  late TextEditingController _contenidoController;
  late TextEditingController _horaController;
  late TextEditingController _notasController;
  bool _recurrente = false;
  bool _completado = false;
  Color _color = Colors.deepPurple;
  IconData _icono = Icons.event;
  List<String> _adjuntos = [];

  @override
  void initState() {
    super.initState();
    final e = widget.evento;
    _tipoController = TextEditingController(text: e?.tipo ?? '');
    _contenidoController = TextEditingController(text: e?.contenido ?? '');
    _horaController = TextEditingController(text: e?.hora ?? '');
    _notasController = TextEditingController(text: e?.notasRapidas ?? '');
    _recurrente = e?.recurrente ?? false;
    _completado = e?.completado ?? false;
    _color = e?.color ?? Colors.deepPurple;
    _icono = e?.icono ?? Icons.event;
    _adjuntos = e?.adjuntos ?? [];
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _contenidoController.dispose();
    _horaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _seleccionarColor() async {
    final colores = [
      Colors.deepPurple,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.brown,
    ];

    final colorSeleccionado = await showDialog<Color>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Selecciona un color'),
            children:
                colores
                    .map(
                      (c) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, c),
                        child: CircleAvatar(backgroundColor: c),
                      ),
                    )
                    .toList(),
          ),
    );

    if (colorSeleccionado != null) {
      setState(() {
        _color = colorSeleccionado;
      });
    }
  }

  void _seleccionarIcono() async {
    final Map<String, IconData> iconosOpciones = {
      'Evento': Icons.event,
      'Tarea': Icons.check_circle,
      'Clase': Icons.school,
      'Recordatorio': Icons.alarm,
      'Otro': Icons.notes,
    };

    final iconoSeleccionado = await showDialog<IconData>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Selecciona un ícono'),
            children:
                iconosOpciones.entries
                    .map(
                      (entry) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, entry.value),
                        child: Row(
                          children: [
                            Icon(entry.value, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
    );

    if (iconoSeleccionado != null) {
      setState(() {
        _icono = iconoSeleccionado;
      });
    }
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoEvento = Evento(
        tipo: _tipoController.text.trim(),
        contenido: _contenidoController.text.trim(),
        hora:
            _horaController.text.trim().isEmpty
                ? null
                : _horaController.text.trim(),
        icono: _icono,
        color: _color,
        recurrente: _recurrente,
        notasRapidas:
            _notasController.text.trim().isEmpty
                ? null
                : _notasController.text.trim(),
        adjuntos: _adjuntos.isEmpty ? null : _adjuntos,
        completado: _completado,
      );

      Navigator.pop(context, nuevoEvento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12) +
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo de evento'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Requerido'
                            : null,
              ),
              TextFormField(
                controller: _contenidoController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Requerido'
                            : null,
              ),
              TextFormField(
                controller: _horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora (opcional, ej: 14:00)',
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _seleccionarIcono,
                    icon: Icon(_icono),
                    label: const Text('Cambiar ícono'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _seleccionarColor,
                    icon: CircleAvatar(backgroundColor: _color, radius: 12),
                    label: const Text('Cambiar color'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('¿Recurrente?'),
                value: _recurrente,
                onChanged: (valor) {
                  setState(() {
                    _recurrente = valor;
                  });
                },
              ),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas rápidas (opcional)',
                ),
                maxLines: 2,
              ),
              SwitchListTile(
                title: const Text('¿Completado?'),
                value: _completado,
                onChanged: (valor) {
                  setState(() {
                    _completado = valor;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
