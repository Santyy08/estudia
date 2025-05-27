import 'package:flutter/material.dart';
import 'package:estudia/modelos/usuario.dart';

class UsuarioProvider extends ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  bool get estaAutenticado => _usuario != null;

  void establecerUsuario(Usuario nuevoUsuario) {
    _usuario = nuevoUsuario;
    notifyListeners();
  }

  void limpiarUsuario() {
    _usuario = null;
    notifyListeners();
  }

  void actualizarNombre(String nuevoNombre) {
    if (_usuario != null) {
      _usuario = _usuario!.copyWith(nombre: nuevoNombre);
      notifyListeners();
    }
  }

  void actualizarEmail(String nuevoEmail) {
    if (_usuario != null) {
      _usuario = _usuario!.copyWith(email: nuevoEmail);
      notifyListeners();
    }
  }

  void actualizarFotoPerfil(String nuevaUrl) {
    if (_usuario != null) {
      _usuario = _usuario!.copyWith(fotoPerfil: nuevaUrl);
      notifyListeners();
    }
  }
}
