import 'package:flutter_test/flutter_test.dart';

import 'package:kipu/app.dart';

void main() {
  testWidgets('Renderiza pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Gastos y Transacciones'), findsOneWidget);
  });
}
