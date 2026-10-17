import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/sources_screen.dart';
import 'package:kuran_app/services/app_language.dart';

void main() {
  for (final locale in ['tr', 'en', 'nl']) {
    testWidgets('audio source sections show descriptions in $locale', (tester) async {
      AppLanguage.instance.value = Locale(locale);
      await tester.pumpWidget(const MaterialApp(home: SourcesScreen()));
      for (final reciter in ['Mishary Rashid Alafasy', 'Abu Bakr Ash-Shatri']) {
        final heading = find.text('$reciter · EveryAyah');
        await tester.scrollUntilVisible(heading, 180, scrollable: find.byType(Scrollable).first);
        await tester.tap(heading);
        await tester.pumpAndSettle();
        final prefix = {'tr': 'Okuyucu:', 'en': 'Reciter:', 'nl': 'Recitator:'}[locale]!;
        expect(find.textContaining('$prefix $reciter.'), findsOneWidget);
        final rights = {'tr': 'yanıt bekleniyor', 'en': 'response is pending', 'nl': 'wachten op antwoord'}[locale]!;
        expect(find.textContaining(rights), findsOneWidget);
        await tester.ensureVisible(heading);
        await tester.tap(heading);
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
