import 'package:flutter_test/flutter_test.dart';
import 'package:es_stock/main.dart';

void main() {
  testWidgets('Mostra o ecrã de login', (WidgetTester tester) async {
    await tester.pumpWidget(const EsStockApp());
    expect(find.text('ES Stock'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
