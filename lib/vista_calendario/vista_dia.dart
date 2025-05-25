import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaDia extends StatefulWidget {
  final DateTime fechaSeleccionada;
  final List<Map<String, dynamic>> tareasDelDia;

  const VistaDia({
    super.key,
    required this.fechaSeleccionada,
    required this.tareasDelDia,
  });

  @override
  State<VistaDia> createState() => _VistaDiaState();
}

class _VistaDiaState extends State<VistaDia> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Opcional: Scroll automático a la hora actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final horaActual = TimeOfDay.now().hour;
      _scrollController.jumpTo((horaActual - 1) * 80.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fechaTexto = DateFormat(
      'EEEE d MMMM y',
      'es_ES',
    ).format(widget.fechaSeleccionada);

    return Scaffold(
      appBar: AppBar(
        title: Text("Día: $fechaTexto"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 24,
        itemBuilder: (context, index) {
          final hora = TimeOfDay(hour: index, minute: 0);
          final tareasEnEstaHora =
              widget.tareasDelDia.where((tarea) {
                final tareaHora = tarea['hora'];
                if (tareaHora == null || tareaHora.isEmpty) return false;
                try {
                  final tareaTime = DateFormat("HH:mm").parse(tareaHora);
                  return tareaTime.hour == hora.hour;
                } catch (_) {
                  return false;
                }
              }).toList();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hora.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (tareasEnEstaHora.isEmpty)
                  const Text(
                    'Sin eventos',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...tareasEnEstaHora.map((tarea) => _buildCard(tarea)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> tarea) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(color: tarea['color'] ?? Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tarea['icono'] ?? Icons.circle, color: tarea['color'], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarea['tipo'] ?? 'Evento',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (tarea['contenido'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(tarea['contenido']),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
