import 'package:flutter/material.dart';

class Constantes {
  // Colores principales de la app
  static const Color colorPrimario = Color(0xFF6200EE);
  static const Color colorSecundario = Color(0xFF03DAC6);
  static const Color colorFondo = Color(0xFFF5F5F5);
  static const Color colorTextoPrincipal = Color(0xFF212121);
  static const Color colorTextoSecundario = Color(0xFF757575);
  static const Color colorError = Color(0xFFB00020);

  // Tamaños estándar
  static const double paddingPequeno = 8.0;
  static const double paddingMediano = 16.0;
  static const double paddingGrande = 24.0;

  static const double radioBordes = 12.0;

  // Duraciones estándar para animaciones
  static const Duration duracionAnimacionCorta = Duration(milliseconds: 300);
  static const Duration duracionAnimacionMedia = Duration(milliseconds: 500);
  static const Duration duracionAnimacionLarga = Duration(milliseconds: 700);

  // Strings comunes
  static const String appNombre = "EstudIA";
  static const String textoCarga = "Cargando...";
  static const String textoErrorConexion =
      "Error de conexión. Intenta de nuevo.";

  // Rutas de assets
  static const String rutaIconoApp = "assets/icons/icono_app.png";
  static const String rutaFuentePrincipal = "assets/fonts/Roboto-Regular.ttf";

  // Otros valores fijos
  static const int maxEventosPorDia = 10;
  static const int maxTareasPendientes = 20;
}
