import 'package:flutter_test/flutter_test.dart';

import 'package:estudia/main.dart'; // Nombre correcto del paquete

void main() {
  testWidgets('Verifica que el saludo y el botón están presentes', (WidgetTester tester) async {
    // Construye el widget principal
    await tester.pumpWidget(const EstudIAApp());

    // Verifica que aparece el texto de saludo
    expect(find.text('Hola, Juan!'), findsOneWidget);

    // Verifica que aparece el botón de planificar
    expect(find.text('Planear mi día →'), findsOneWidget);
  });
}
