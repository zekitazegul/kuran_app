import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/meal_screen.dart';
import 'package:kuran_app/services/meal_reader.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/widgets/paginated_meal_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Turkish pages retain explanation text and exclude Arabic', () async {
    final pages = jsonDecode(await rootBundle.loadString('assets/meal/turkish-pages.json')) as List;
    expect(pages.length, 1490);
    final all = pages.expand((p) => p as List).join(' ');
    expect(RegExp(r'[\u0600-\u06ff\ufb50-\ufdff\ufe70-\ufeff]').hasMatch(all), isFalse);
    expect((pages[41] as List).length, greaterThan(5));
    expect(all.length, greaterThan(3000000));
    final fatiha = List<String>.from(pages[41] as List);
    expect(fatiha[1], startsWith('Daha kuvvetli rivayetlere göre'));
    expect(fatiha[1], contains('iki defa nâzil olmuştur. Umumî kabule göre,'));
    expect(fatiha[1], endsWith('Fâtiha’sız namaz olmaz.'));
    expect(List<String>.from(pages[49] as List)[1], startsWith('Hicret’in hemen ardından'));
    final firstNote = fatiha.firstWhere((p) => p.startsWith('1. Bizzat'));
    expect(firstNote, contains('Kur’ân okumaya başlarken, Besmele’den önce Eûzü'));
    expect(firstNote, contains('denir. Bunun en kısa manâsı,'));
    expect(firstNote, isNot(contains('müslim-gayrı')));
    final secondNote = fatiha.firstWhere((p) => p.startsWith('2. Rahmân'));
    expect(secondNote, contains('Cenab-ı Hakk’ın bir sıfatı olmakla beraber, isim olma ciheti'));
    expect(secondNote, contains('müslim-gayrı müslim hiçbir ayırım yapmadan bütün varlığı'));
    final lastSurahVerses = List<String>.from(pages[1335] as List).join(' ');
    expect(lastSurahVerses.indexOf('25. Elbet'), lessThan(lastSurahVerses.indexOf('26. Hesaplarını')));
    expect(lastSurahVerses, contains('Hesaplarını görmek de elbet Biz’e aittir.'));
    final hadid = List<String>.from(pages[1210] as List);
    expect(hadid.indexWhere((p) => p.startsWith('57. HADÎD')), lessThan(hadid.indexWhere((p) => p.startsWith('Medine’de'))));
    expect(pages.expand((p) => p as List).where((p) => (p as String).length == 1), isEmpty);
  });
  test('pagination preserves all text and every slice fits the viewport', () {
    final text = List.generate(35, (i) => '$i. A long paragraph with several words and punctuation. ').join('\n\n');
    for (final size in [16.0, 22.0, 40.0]) {
      for (final height in [130.0, 500.0]) {
        final style = TextStyle(fontSize: size, height: 1.6);
        final slices = paginateMealText(text, style, 280, height, TextScaler.linear(1.3));
        expect(slices.length, greaterThan(1));
        expect(slices.map((s) => text.substring(s.start, s.end)).join(), text);
        for (final slice in slices) {
          final painter = TextPainter(text: TextSpan(text: text.substring(slice.start, slice.end), style: style),
            textDirection: TextDirection.ltr, textScaler: TextScaler.linear(1.3))..layout(maxWidth: 280);
          // A trailing newline belongs to this slice but has no visible ink.
          final lines = painter.computeLineMetrics();
          final nonEmpty = lines.where((line) => line.width > 0);
          if (nonEmpty.isEmpty) { painter.dispose(); continue; }
          expect(nonEmpty.last.baseline + nonEmpty.last.descent, lessThanOrEqualTo(height + 0.01));
          painter.dispose();
        }
      }
    }
  });

  testWidgets('meal turns screenfuls before source pages and restores the text position', (tester) async {
    var saved = <String, dynamic>{};
    var source = 51;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MealReader.channel, (call) async {
      if (call.method == 'load') return {'page': source, 'zoom': 100};
      if (call.method == 'loadText') return {'fontSize': 38, ...saved};
      if (call.method == 'saveText') saved = Map<String, dynamic>.from(call.arguments as Map);
      if (call.method == 'save') source = (call.arguments as Map)['page'] as int;
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(MealReader.channel, null));
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<void> open() async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const MaterialApp(home: MealScreen()));
        for (var i = 0; i < 100 && find.byType(PaginatedMealText).evaluate().isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
    }
    await open();
    final progress = find.byKey(const ValueKey('meal-screen-progress'));
    final surface = find.byKey(const ValueKey('meal-reading-surface'));
    expect(find.byType(ListView), findsNothing);
    final firstProgress = tester.widget<Text>(progress).data!;
    expect(firstProgress, startsWith('1 / '));
    final count = int.parse(firstProgress.split(' / ').last);
    expect(count, greaterThan(1));
    await tester.drag(surface, const Offset(-280, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(progress).data, '2 / $count');
    expect(source, 51);
    expect(saved['textOffset'], greaterThan(0));
    final offset = saved['textOffset'];
    await tester.pumpWidget(const SizedBox()); await tester.pumpAndSettle();
    await open();
    expect(tester.widget<Text>(progress).data, '2 / $count');
    expect(saved['textOffset'], offset);
    await tester.tap(find.byKey(const ValueKey('meal-font-larger'))); await tester.pumpAndSettle();
    expect(saved['fontSize'], 40);
    expect(saved['textOffset'], offset);
    expect(source, 51);
    tester.view.physicalSize = const Size(800, 360); await tester.pumpAndSettle();
    expect(source, 51);
    expect(tester.takeException(), isNull);
    final center = tester.getCenter(surface);
    await tester.tapAt(center); await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(center); await tester.pumpAndSettle();
    expect(AppNavigation.instance.fullscreenMeal.value, isNotNull);
    await tester.drag(surface, const Offset(-600, 0)); await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final fullCenter = tester.getCenter(surface);
    await tester.tapAt(fullCenter); await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(fullCenter); await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(360, 800); await tester.pumpAndSettle();
    final screens = int.parse(tester.widget<Text>(progress).data!.split(' / ').last);
    for (var i = 0; i <= screens && source == 51; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right)); await tester.pumpAndSettle();
    }
    expect(source, 52);
    expect(tester.widget<Text>(progress).data, startsWith('1 / '));
    await tester.tap(find.byIcon(Icons.chevron_left)); await tester.pumpAndSettle();
    expect(source, 51);
    final previous = tester.widget<Text>(progress).data!.split(' / ');
    expect(previous.first, previous.last);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox()); await tester.pumpAndSettle();
  });
}
