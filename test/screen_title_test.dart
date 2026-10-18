import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/screen_title.dart';

void main() {
  testWidgets('compact headings preserve Turkish casing and all interface locales', (tester) async {
    final previous = AppLanguage.instance.value;
    addTearDown(() => AppLanguage.instance.value = previous);
    for (final entry in [
      ('tr', 'Meal Oku', 'MEAL OKU'),
      ('tr', "Kur'an dinle", "KUR'AN DİNLE"),
      ('tr', 'Kısayollarım', 'KISAYOLLARIM'),
      ('en', 'Read translation', 'READ TRANSLATION'),
      ('nl', 'Vertaling lezen', 'VERTALING LEZEN'),
    ]) {
      AppLanguage.instance.value = Locale(entry.$1);
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => ScreenTitle(context, entry.$2))));
      final title = tester.widget<ScreenTitle>(find.byType(ScreenTitle));
      expect(title.data, entry.$3);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.fontSize, 18);
      expect(title.maxLines, 1);
    }
  });
}
