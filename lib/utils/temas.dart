import 'package:flutter/material.dart';
import 'constantes.dart';

final ThemeData temaClaro = ThemeData(
  brightness: Brightness.light,
  primaryColor: Constantes.colorPrimario,
  colorScheme: ColorScheme.light(
    primary: Constantes.colorPrimario,
    secondary: Constantes.colorSecundario,
    error: Constantes.colorError,
    surface: Constantes.colorFondo,
  ),
  scaffoldBackgroundColor: Constantes.colorFondo,
  appBarTheme: AppBarTheme(
    backgroundColor: Constantes.colorPrimario,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Constantes.colorTextoPrincipal,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Constantes.colorTextoPrincipal,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Constantes.colorTextoPrincipal),
    bodyMedium: TextStyle(fontSize: 14, color: Constantes.colorTextoSecundario),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Constantes.colorPrimario,
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
);

final ThemeData temaOscuro = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Constantes.colorSecundario,
  colorScheme: ColorScheme.dark(
    primary: Constantes.colorSecundario,
    secondary: Constantes.colorPrimario,
    error: Constantes.colorError,
    surface: Colors.black87,
  ),
  scaffoldBackgroundColor: Colors.black87,
  appBarTheme: AppBarTheme(
    backgroundColor: Constantes.colorSecundario,
    foregroundColor: Colors.black,
    elevation: 4,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white70,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Constantes.colorSecundario,
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
);
