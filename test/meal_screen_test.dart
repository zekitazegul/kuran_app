import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/meal_screen.dart';
import 'package:kuran_app/services/meal_reader.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/widgets/paginated_meal_text.dart';
import 'package:kuran_app/widgets/personal_page_scope.dart';

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
    final tevbe = List<String>.from(pages[451] as List);
    final sixthVerse = tevbe.firstWhere((p) => p.startsWith('6. Bundan'));
    expect(sixthVerse, contains('sığınma hakkı isteğiyle yanına gelmek'));
    expect(sixthVerse, endsWith('bir topluluktur.¹'));
    final tevbeNote = tevbe.firstWhere((p) => p.startsWith('1. Baştan'));
    expect(tevbeNote, contains('birlikte ele alındığında, İslâm’ın'));
    expect(tevbe.indexOf(sixthVerse), lessThan(tevbe.indexOf(tevbeNote)));
    expect(sixthVerse, isNot(contains('âyet-i kerimeler')));
    final nextTevbePage = List<String>.from(pages[452] as List);
    expect(nextTevbePage.firstWhere((p) => p.startsWith('8. O')),
      contains('müşriklerin nasıl ahitleri olabilir'));
    expect(nextTevbePage.last, startsWith('2. Bu âyet-i kerimede'));
    expect((pages[450] as List).join(' '), contains('O’nun kudretinden'));
    expect((pages[453] as List).join(' '), contains('mü’min toplulukların'));
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

  testWidgets('vertical reading crosses source boundaries and still allows horizontal turns', (tester) async {
    final pages = [for (var page = 1; page <= 4; page++)
      [List.generate(30, (line) => 'Source $page line $line: reading continues without a page break.').join(' ')]];
    var savedPage = 2, savedOffset = 0;
    final key = GlobalKey<PaginatedMealTextState>();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 360, height: 500,
      child: PaginatedMealText(key: key, pages: pages, page: 2, offset: 0, fontSize: 22, enabled: true,
        onChanged: (page, offset) { savedPage = page; savedOffset = offset; })))));
    await tester.pumpAndSettle();
    final surface = find.byKey(const ValueKey('meal-reading-surface'));
    final scroll = tester.widget<CustomScrollView>(find.byType(CustomScrollView)).controller!;
    await tester.drag(surface, const Offset(0, -130));
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
    expect(savedPage, 2);
    expect(savedOffset, greaterThan(0));
    final partial = scroll.offset;
    final cancelled = await tester.startGesture(tester.getCenter(surface));
    await cancelled.moveBy(const Offset(-30, 0));
    await tester.pump();
    await cancelled.moveBy(const Offset(-20, 0));
    await tester.pump();
    await cancelled.cancel();
    await tester.pumpAndSettle();
    expect(scroll.offset, partial);
    expect(tester.widget<Transform>(find.byKey(const ValueKey('meal-horizontal-page')))
      .transform.storage[12], 0);
    final horizontalDrag = await tester.startGesture(tester.getCenter(surface));
    await horizontalDrag.moveBy(const Offset(-30, 0));
    await tester.pump();
    await horizontalDrag.moveBy(const Offset(-90, 0));
    await tester.pump(const Duration(milliseconds: 30));
    final slide = tester.widget<Transform>(find.byKey(const ValueKey('meal-horizontal-page')));
    expect(slide.transform.storage[12], lessThan(0));
    expect(slide.transform.storage[13], 0);
    expect(scroll.offset, partial, reason: 'Horizontal dragging must not animate vertical scrolling');
    await horizontalDrag.up();
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(partial));
    for (var i = 0; i < 40 && savedPage == 2; i++) {
      await tester.drag(surface, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(savedPage, 3);
    for (var i = 0; i < 80 && savedPage >= 2; i++) {
      await tester.drag(surface, const Offset(0, 300));
      await tester.pumpAndSettle();
    }
    expect(savedPage, 1, reason: 'Reading backwards also crosses the original anchor');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
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
        await tester.pumpWidget(MaterialApp(home: PersonalPageScope(
          heading: const Text('Meal Oku'), navigate: (_) {}, child: const MealScreen())));
        for (var i = 0; i < 100 && find.byType(PaginatedMealText).evaluate().isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
    }
    await open();
    for (final size in [const Size(320, 568), const Size(412, 915), const Size(800, 1280), const Size(1280, 800), const Size(640, 360)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Layout must fit $size');
      final area = tester.getSize(find.byKey(const ValueKey('meal-reading-area')));
      expect(area.height, greaterThan(0));
      expect(area.width, lessThanOrEqualTo(size.width));
      expect(find.text('Meal Oku'), findsOneWidget);
      final title = tester.getCenter(find.text('Meal Oku'));
      final fontControl = tester.getCenter(find.byKey(const ValueKey('meal-font-larger')));
      expect(fontControl.dy, closeTo(title.dy, 1));
      final localProgress = tester.getCenter(find.byKey(const ValueKey('meal-screen-progress')));
      final sourceProgress = tester.getCenter(find.byKey(const ValueKey('meal-source-progress')));
      final next = tester.getCenter(find.byIcon(Icons.chevron_right));
      expect(localProgress.dy, closeTo(sourceProgress.dy, 1));
      expect(localProgress.dy, closeTo(next.dy, 1));
      expect(find.byKey(const ValueKey('meal-combined-footer')), findsOneWidget);
    }
    tester.view.physicalSize = const Size(360, 800);
    await tester.pumpAndSettle();
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
    AppNavigation.instance.exitFullscreen();
    await tester.pumpAndSettle();
    expect(AppNavigation.instance.fullscreenMeal.value, isNull);
    expect(find.byKey(const ValueKey('meal-font-larger')), findsOneWidget);
    final restoredCenter = tester.getCenter(surface);
    await tester.tapAt(restoredCenter); await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(restoredCenter); await tester.pumpAndSettle();
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
