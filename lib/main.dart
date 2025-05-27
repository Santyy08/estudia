// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'providers/calendario_provider.dart';
import 'pantallas/pantalla_calendario.dart';

void main() {
  Intl.defaultLocale = 'es';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalendarioProvider(),
      child: MaterialApp(
        title: 'EstudIA', // Como en tus imágenes
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(
            0xFF6A86FF,
          ), // Un azul que se asemeja al de tu diseño
          primarySwatch: Colors.blue, // Para generar tonos automáticamente
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF6A86FF), // Color del FAB
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A86FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
          cardTheme: CardTheme(
            elevation: 0, // Sin sombra por defecto en cards
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ), // Borde suave
            ),
          ),
          fontFamily:
              'Roboto', // Puedes definir una fuente específica si usas una personalizada
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', ''), Locale('es', '')],
        home: const PantallaCalendario(),
      ),
    );
  }
}
