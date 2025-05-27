class Validadores {
  // Valida que el campo no esté vacío
  static String? campoRequerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  // Valida que el email sea válido
  static String? emailValido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    // Regex básico para email
    final regexEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regexEmail.hasMatch(valor.trim())) {
      return 'Ingrese un email válido';
    }
    return null;
  }

  // Valida que el texto tenga una longitud mínima
  static String? longitudMinima(String? valor, int min) {
    if (valor == null || valor.trim().length < min) {
      return 'Debe tener al menos $min caracteres';
    }
    return null;
  }

  // Valida que la contraseña sea segura (mínimo 6 caracteres, al menos una mayúscula y un número)
  static String? passwordSegura(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    final regexMayuscula = RegExp(r'[A-Z]');
    final regexNumero = RegExp(r'\d');
    if (!regexMayuscula.hasMatch(valor)) {
      return 'La contraseña debe tener al menos una letra mayúscula';
    }
    if (!regexNumero.hasMatch(valor)) {
      return 'La contraseña debe tener al menos un número';
    }
    return null;
  }

  // Valida que dos campos sean iguales (por ejemplo, contraseña y confirmación)
  static String? camposIguales(String? valor1, String? valor2) {
    if (valor1 != valor2) {
      return 'Los campos no coinciden';
    }
    return null;
  }
}
