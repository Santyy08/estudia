import 'package:flutter/material.dart';
import '../utils/temas.dart';

class TemaProvider extends ChangeNotifier {
  ThemeMode _modoTema = ThemeMode.light;

  ThemeMode get modoTema => _modoTema;

  // Getter que devuelve el ThemeData activo
  ThemeData get temaActual =>
      _modoTema == ThemeMode.light ? temaClaro : temaOscuro;

  void cambiarTema(ThemeMode modo) {
    _modoTema = modo;
    notifyListeners();
  }

  void toggleTema() {
    if (_modoTema == ThemeMode.light) {
      _modoTema = ThemeMode.dark;
    } else {
      _modoTema = ThemeMode.light;
    }
    notifyListeners();
  }
}
