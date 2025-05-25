import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VistaMes extends StatefulWidget {
  final Function(DateTime) onDiaSeleccionado;
  final DateTime fechaSeleccionada;

  const VistaMes({
    super.key,
    required this.onDiaSeleccionado,
    required this.fechaSeleccionada,
  });

  @override
  State<VistaMes> createState() => _VistaMesState();
}

class _VistaMesState extends State<VistaMes> {
  late DateTime _mesActual;

  @override
  void initState() {
    super.initState();
    _mesActual = DateTime(
      widget.fechaSeleccionada.year,
      widget.fechaSeleccionada.month,
    );
  }

  void _cambiarMes(int direccion) {
    setState(() {
      _mesActual = DateTime(_mesActual.year, _mesActual.month + direccion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final diasEnMes = DateUtils.getDaysInMonth(
      _mesActual.year,
      _mesActual.month,
    );
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final primerDiaSemana = (primerDia.weekday) % 7;
    final totalCeldas = diasEnMes + primerDiaSemana;

    final dias = List.generate(totalCeldas, (index) {
      if (index < primerDiaSemana) return null;
      return DateTime(
        _mesActual.year,
        _mesActual.month,
        index - primerDiaSemana + 1,
      );
    });

    return Column(
      children: [
        _header(),
        const SizedBox(height: 12),
        _diasSemana(),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final dia = dias[index];
              final esSeleccionado =
                  dia != null &&
                  dia.day == widget.fechaSeleccionada.day &&
                  dia.month == widget.fechaSeleccionada.month &&
                  dia.year == widget.fechaSeleccionada.year;

              return GestureDetector(
                onTap: dia != null ? () => widget.onDiaSeleccionado(dia) : null,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        esSeleccionado ? Colors.teal[200] : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dia != null ? '${dia.day}' : '',
                    style: TextStyle(
                      color: esSeleccionado ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _header() {
    final mesNombre = DateFormat.yMMMM('es_ES').format(_mesActual);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _cambiarMes(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          mesNombre,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => _cambiarMes(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _diasSemana() {
    const dias = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          dias.map((dia) {
            return Expanded(
              child: Center(
                child: Text(
                  dia,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
    );
  }
}
