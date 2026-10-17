import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/searchable_surah_field.dart';

void main() {
  testWidgets('finds Nas by name and number and accepts unaccented Turkish', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    int? selected;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SearchableSurahField(value: 1, onChanged: (value) => selected = value))));
    await tester.tap(find.byType(SearchableSurahField));
    await tester.pumpAndSettle();
    final input = find.byKey(const ValueKey('surah-search-input'));
    await tester.enterText(input, 'nas');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('surah-search-result-114')), findsOneWidget);
    await tester.enterText(input, '114');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    await tester.enterText(input, 'al-i imran');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('surah-search-result-3')), findsOneWidget);
    await tester.enterText(input, 'xyzxyz');
    await tester.pumpAndSettle();
    expect(find.text('Sonuç bulunamadı.'), findsOneWidget);
    await tester.enterText(input, '114');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('surah-search-result-114')));
    await tester.pumpAndSettle();
    expect(selected, 114);
    expect(input, findsNothing);
    expect(tester.takeException(), isNull);
  });
}
