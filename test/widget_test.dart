import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';

void main() {
  testWidgets('Kuran App açılıyor', (WidgetTester tester) async {
    await tester.pumpWidget(const KuranApp());

    expect(find.text('Kuran App'), findsOneWidget);
    expect(find.text('Yasin Suresi'), findsOneWidget);
  });
}
