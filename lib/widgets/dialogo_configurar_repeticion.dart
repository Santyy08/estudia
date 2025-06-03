// lib/widgets/dialogo_configurar_repeticion.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tarjeta_eventos.dart'; // Para TipoFrecuenciaRepeticion y ReglaRepeticion

class DialogoConfigurarRepeticion extends StatefulWidget {
  final ReglaRepeticion? reglaInicial;

  const DialogoConfigurarRepeticion({super.key, this.reglaInicial});

  @override
  State<DialogoConfigurarRepeticion> createState() =>
      _DialogoConfigurarRepeticionState();
}

class _DialogoConfigurarRepeticionState
    extends State<DialogoConfigurarRepeticion> {
  late TipoFrecuenciaRepeticion _frecuenciaSeleccionada;
  late int _intervalo;
  List<int> _diasSemanaSeleccionados = []; // Para repetición semanal
  int? _diaDelMesSeleccionado; // Para repetición mensual
  // Para 'termina en fecha'
  DateTime? _fechaFinRepeticion;
  // Para 'termina después de N ocurrencias' (más complejo, omitido por ahora para simplificar)
  // int? _numeroOcurrencias;

  // Controladores para los campos de texto
  late TextEditingController _intervaloCtrl;
  // Clave para el Form y su validación
  final _formKey = GlobalKey<FormState>();

  final List<String> _nombresDiasSemanaCortos = [
    'L', 'M', 'X', 'J', 'V', 'S', 'D', // Lunes a Domingo
  ];

  DateTime _combinarFechaYHora(DateTime fecha, TimeOfDay hora) {
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  @override
  void initState() {
    super.initState();
    // Asegurar que Intl esté inicializado para el locale español si se usa DateFormat
    Intl.defaultLocale = 'es_ES';
    _intervaloCtrl = TextEditingController();

    if (widget.reglaInicial != null) {
      _frecuenciaSeleccionada = widget.reglaInicial!.frecuencia;
      _intervalo = widget.reglaInicial!.intervalo;
      _intervaloCtrl.text = _intervalo.toString();
      // Crear una nueva lista para evitar modificar la original si se cancela
      _diasSemanaSeleccionados = List<int>.from(
        widget.reglaInicial!.diasSemana ?? [],
      );
      _diaDelMesSeleccionado = widget.reglaInicial!.diaDelMes;
      _fechaFinRepeticion = widget.reglaInicial!.fechaFinRepeticion;
    } else {
      _frecuenciaSeleccionada =
          TipoFrecuenciaRepeticion.diaria; // Valor por defecto
      _intervalo = 1;
      _intervaloCtrl.text = '1';
    }
  }

  @override
  void dispose() {
    _intervaloCtrl.dispose();
    super.dispose();
  }

  Widget _buildSelectorFrecuencia() {
    return DropdownButtonFormField<TipoFrecuenciaRepeticion>(
      decoration: const InputDecoration(
        labelText: 'Frecuencia',
        border: OutlineInputBorder(), // Estilo de borde
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ), // Padding interno
      ),
      value: _frecuenciaSeleccionada,
      items:
          TipoFrecuenciaRepeticion.values
              .map(
                (frecuencia) => DropdownMenuItem(
                  value: frecuencia,
                  child: Text(_textoFrecuencia(frecuencia)),
                ),
              )
              .toList(),
      onChanged: (TipoFrecuenciaRepeticion? newValue) {
        if (newValue != null) {
          setState(() {
            _frecuenciaSeleccionada = newValue;
            // Resetear opciones específicas de otras frecuencias si es necesario
            if (_frecuenciaSeleccionada != TipoFrecuenciaRepeticion.semanal) {
              _diasSemanaSeleccionados.clear();
            }
            if (_frecuenciaSeleccionada != TipoFrecuenciaRepeticion.mensual) {
              _diaDelMesSeleccionado = null;
            }
            // Actualizar sufijo del intervalo
            _intervalo = 1; // Resetear intervalo a 1 al cambiar frecuencia
            _intervaloCtrl.text = '1';
          });
        }
      },
    );
  }

  String _textoFrecuencia(TipoFrecuenciaRepeticion frecuencia) {
    switch (frecuencia) {
      case TipoFrecuenciaRepeticion.diaria:
        return 'Diariamente';
      case TipoFrecuenciaRepeticion.semanal:
        return 'Semanalmente';
      case TipoFrecuenciaRepeticion.mensual:
        return 'Mensualmente';
      case TipoFrecuenciaRepeticion.anual:
        return 'Anualmente';
    }
  }

  Widget _buildCampoIntervalo() {
    return TextFormField(
      controller: _intervaloCtrl,
      decoration: InputDecoration(
        labelText: 'Repetir cada',
        suffixText: _obtenerSufijoIntervalo(),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese un intervalo';
        final n = int.tryParse(value);
        if (n == null || n < 1) return 'Debe ser un número > 0';
        return null;
      },
      onSaved: (value) {
        // Usar onSaved para actualizar _intervalo
        _intervalo = int.tryParse(value ?? '1') ?? 1;
      },
    );
  }

  String _obtenerSufijoIntervalo() {
    // Actualizar el sufijo basado en _intervalo para singular/plural
    final valIntervalo = int.tryParse(_intervaloCtrl.text) ?? 1;
    switch (_frecuenciaSeleccionada) {
      case TipoFrecuenciaRepeticion.diaria:
        return valIntervalo == 1 ? 'día' : 'días';
      case TipoFrecuenciaRepeticion.semanal:
        return valIntervalo == 1 ? 'semana' : 'semanas';
      case TipoFrecuenciaRepeticion.mensual:
        return valIntervalo == 1 ? 'mes' : 'meses';
      case TipoFrecuenciaRepeticion.anual:
        return valIntervalo == 1 ? 'año' : 'años';
    }
  }

  Widget _buildSelectorDiasSemana() {
    if (_frecuenciaSeleccionada != TipoFrecuenciaRepeticion.semanal) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Repetir en:',
          style: Theme.of(context).textTheme.labelLarge,
        ), // Usar labelLarge para consistencia
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: List<bool>.generate(
            7,
            (index) => _diasSemanaSeleccionados.contains(
              index + 1,
            ), // DateTime.monday es 1
          ),
          onPressed: (int index) {
            setState(() {
              final dia = index + 1;
              if (_diasSemanaSeleccionados.contains(dia)) {
                _diasSemanaSeleccionados.remove(dia);
              } else {
                _diasSemanaSeleccionados.add(dia);
                _diasSemanaSeleccionados.sort(); // Mantener orden visual
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          // Ajustar constraints para que los botones no sean demasiado anchos
          constraints: BoxConstraints(
            minWidth:
                (MediaQuery.of(context).size.width * 0.7 - 16 * 3) /
                7, // Ancho dinámico
            minHeight: 38,
          ),
          children:
              _nombresDiasSemanaCortos
                  .map(
                    (dia) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(dia),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSelectorDiaDelMes() {
    if (_frecuenciaSeleccionada != TipoFrecuenciaRepeticion.mensual) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Día del mes',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          value: _diaDelMesSeleccionado,
          items:
              List.generate(31, (index) => index + 1)
                  .map(
                    (dia) => DropdownMenuItem(
                      value: dia,
                      child: Text(dia.toString()),
                    ),
                  )
                  .toList(),
          onChanged: (int? newValue) {
            setState(() {
              _diaDelMesSeleccionado = newValue;
            });
          },
          hint: const Text('Seleccionar día'),
        ),
      ],
    );
  }

  Widget _buildSelectorFechaFin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Termina:', style: Theme.of(context).textTheme.labelLarge),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _fechaFinRepeticion == null
                ? 'Nunca'
                : 'En ${DateFormat('dd/MM/yyyy', 'es').format(_fechaFinRepeticion!)}',
          ),
          trailing: const Icon(
            Icons.calendar_today_outlined,
          ), // Icono más adecuado
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate:
                  _fechaFinRepeticion ??
                  DateTime.now().add(const Duration(days: 30)),
              // La fecha de inicio para el selector no puede ser anterior a la fecha de inicio del evento,
              // pero no tenemos esa info aquí. Usamos hoy como mínimo.
              firstDate: _combinarFechaYHora(
                DateTime.now(),
                const TimeOfDay(hour: 0, minute: 0),
              ),
              lastDate: DateTime.now().add(
                const Duration(days: 365 * 10),
              ), // Hasta 10 años en el futuro
            );
            if (picked != null) {
              setState(() {
                _fechaFinRepeticion = picked;
              });
            }
          },
        ),
        if (_fechaFinRepeticion != null)
          Align(
            // Para alinear el botón a la izquierda
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Quitar fecha de fin'),
              onPressed: () {
                setState(() {
                  _fechaFinRepeticion = null;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
      ],
    );
  }

  void _guardarConfiguracion() {
    // Validar el Form antes de intentar guardar
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _formKey.currentState
        ?.save(); // Esto llamará a onSaved en los TextFormField

    // Validaciones adicionales específicas de la lógica de repetición
    if (_frecuenciaSeleccionada == TipoFrecuenciaRepeticion.semanal &&
        _diasSemanaSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione al menos un día de la semana para la repetición semanal.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_frecuenciaSeleccionada == TipoFrecuenciaRepeticion.mensual &&
        _diaDelMesSeleccionado == null) {
      // Esta validación solo aplica si la frecuencia es mensual.
      // Si se cambia de mensual a otra frecuencia, _diaDelMesSeleccionado puede ser null y es válido.
      // Podríamos añadir: && _frecuenciaSeleccionada == TipoFrecuenciaRepeticion.mensual
      // pero el DropdownButtonFormField debería manejar el "hint" si es null.
      // Para ser más estrictos al Aceptar:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione un día del mes para la repetición mensual.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevaRegla = ReglaRepeticion(
      frecuencia: _frecuenciaSeleccionada,
      intervalo: _intervalo, // _intervalo ahora se actualiza en onSaved
      diasSemana:
          _frecuenciaSeleccionada == TipoFrecuenciaRepeticion.semanal
              ? List.from(_diasSemanaSeleccionados)
              : null,
      diaDelMes:
          _frecuenciaSeleccionada == TipoFrecuenciaRepeticion.mensual
              ? _diaDelMesSeleccionado
              : null,
      // mesDelAnio para 'anual' se omitió por simplicidad en la UI, se puede añadir
      fechaFinRepeticion: _fechaFinRepeticion,
    );
    Navigator.of(context).pop(nuevaRegla);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Repetición'),
      content: SizedBox(
        // Darle un ancho al contenido del diálogo
        width: MediaQuery.of(context).size.width * 0.85, // Un poco más de ancho
        child: SingleChildScrollView(
          child: Form(
            // Envolver en un Form para la validación del intervalo
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildSelectorFrecuencia(),
                const SizedBox(height: 16),
                _buildCampoIntervalo(),
                _buildSelectorDiasSemana(),
                _buildSelectorDiaDelMes(),
                _buildSelectorFechaFin(),
              ],
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween, // Distribuir acciones
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: <Widget>[
        TextButton(
          // Botón para quitar repetición (devuelve null)
          child: const Text('No Repetir'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        Row(
          // Agrupar Cancelar y Aceptar
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                // Devuelve la regla inicial sin cambios si se cancela
                Navigator.of(context).pop(widget.reglaInicial);
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _guardarConfiguracion,
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ],
    );
  }
}
