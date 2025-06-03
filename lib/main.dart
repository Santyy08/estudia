// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart'; // Necesario para Firebase
import 'firebase_options.dart'; // Tu archivo generado por FlutterFire CLI

import 'providers/calendario_provider.dart';
import 'providers/usuario_provider.dart'; // Asumimos que lo usaremos para el userId
import 'pantallas/pantalla_calendario.dart';
// Asegúrate de tener TemaProvider si lo usas, o elimínalo de MultiProvider
// import 'providers/tema_provider.dart';

void main() async {
  // Convertir main a async
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de Firebase.initializeApp
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Usa tus firebase_options.dart
  );
  Intl.defaultLocale = 'es_ES'; // O 'es'
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usaremos un userId de prueba por ahora. En una app real, vendría de la autenticación.
    const String userIdDePrueba = "testUser123";

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UsuarioProvider(),
        ), // Si ya lo tienes y usas
        ChangeNotifierProvider(
          create:
              (context) => CalendarioProvider(userIdDePrueba), // Pasar userId
        ),
        // Si tienes un TemaProvider:
        // ChangeNotifierProvider(create: (context) => TemaProvider()),
      ],
      // Si usas TemaProvider, envuelve MaterialApp con un Consumer de TemaProvider
      // De lo contrario, puedes usar MaterialApp directamente.
      // child: Consumer<TemaProvider>( // Ejemplo si usas TemaProvider
      //   builder: (context, temaProvider, child) {
      //     return MaterialApp(
      //       themeMode: temaProvider.modoTema,
      //       theme: temaClaro, // Asegúrate que temaClaro y temaOscuro estén definidos o importados
      //       darkTheme: temaOscuro,
      //       // ... resto de MaterialApp
      // );
      //   },
      // ),
      child: MaterialApp(
        // Si NO usas TemaProvider o lo manejas de otra forma
        title: 'EstudIA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Tema claro por defecto
          primaryColor: const Color(0xFF6A86FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6A86FF),
          ), // Nuevo ThemeData
          useMaterial3: true, // Recomendado para nuevos proyectos
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF6A86FF),
            foregroundColor: Colors.white,
            shape: CircleBorder(),
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
          cardTheme: CardThemeData(
            // Usar CardThemeData
            elevation: 1, // Un poco de elevación para las tarjetas
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // side: BorderSide(color: Colors.grey[200]!) // Opcional
            ),
          ),
          fontFamily: 'Roboto', // Si tienes esta fuente
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
