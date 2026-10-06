import 'package:flutter_test/flutter_test.dart';
import 'package:molina_os/main.dart';
void main() {
  testWidgets('MOLINA OS muestra el dashboard inicial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MolinaOSApp());
    expect(find.text('MOLINA OS'), findsOneWidget);
    expect(find.text('Buenos días, Julián'), findsOneWidget);
    expect(
      find.text('Tu dinero. Tus decisiones. Tu futuro.'),
      findsOneWidget,
    );
    expect(find.text('DINERO TOTAL'), findsOneWidget);
    expect(find.text('DISPONIBLE REAL'), findsOneWidget);
    expect(find.text('Ingresos'), findsOneWidget);
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('Deudas'), findsOneWidget);
    expect(find.text('Salir de deudas'), findsOneWidget);
    expect(find.text('Registrar movimiento'), findsOneWidget);
  });
}