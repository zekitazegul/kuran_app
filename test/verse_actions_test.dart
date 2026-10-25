import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/sajdah_verses.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/verse_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('all three scripts have every verse and all prostration targets', () {
    final data = jsonDecode(File('assets/verse_regions.json').readAsStringSync()) as Map;
    final refs = jsonDecode(File('assets/page_verses.json').readAsStringSync())['pages'] as List;
    for (final edition in ['computer', 'hat2', 'husrev']) {
      final pages = data[edition] as List;
      expect(pages.length, 605);
      for (var page = 0; page < 605; page++) {
        expect((pages[page] as List).map((v) => '${v[0]}:${v[1]}'),
          (refs[page] as List).map((v) => '${v['surah']}:${v['verse']}'), reason: '$edition $page');
        for (final v in pages[page] as List) {
          expect(v[2], isNotEmpty, reason: '$edition $page ${v[0]}:${v[1]}');
          for (final box in v[2] as List) {
            expect(box[0], lessThan(box[2])); expect(box[1], lessThan(box[3]));
            expect(box.every((n) => n >= 0 && n <= 1), isTrue);
          }
        }
      }
      for (final entry in sajdahVerses.entries) {
        expect((pages[entry.key] as List).any((v) => v[0] == entry.value.$1 && v[1] == entry.value.$2), isTrue);
      }
    }
  });

  test('verse overlays use the image contain and crop transform', () {
    expect(verseDisplayRect(const Rect.fromLTRB(.25,.25,.75,.75), const Size(400,400), const Size(200,400), null),
      const Rect.fromLTRB(150,100,250,300));
    expect(verseDisplayRect(const Rect.fromLTRB(.25,.25,.75,.75), const Size(400,400), const Size(200,400),
      const Rect.fromLTRB(.25,.25,.75,.75)), const Rect.fromLTRB(100,0,300,400));
  });

  for (final locale in ['tr', 'en', 'nl']) {
    for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
      testWidgets('meal bubble and range validation $locale $size', (tester) async {
        AppLanguage.instance.value = Locale(locale);
        tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        const verse = VerseRegion(2, 255, []);
        (int,int,int)? result;
        await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(body: Column(children: [
          TextButton(onPressed: () => showVerseMeal(context, verse,
            selection: [verse, const VerseRegion(2,256,[])]), child: const Text('meal')),
          TextButton(onPressed: () async { result = await showMemorizeRange(context, verse); }, child: const Text('range')),
        ])))));
        await tester.tap(find.text('meal')); await tester.pump(const Duration(milliseconds: 300));
        await tester.runAsync(() async { await Future<void>.delayed(const Duration(milliseconds: 150)); });
        await tester.pumpAndSettle();
        expect(find.text(translate('verseMealSource',locale)), findsOneWidget);
        expect(find.byType(SelectableText), findsOneWidget);
        expect(tester.widget<SelectableText>(find.byType(SelectableText)).data, contains('2:255'));
        expect(tester.widget<SelectableText>(find.byType(SelectableText)).data, contains('2:256'));
        expect(find.byType(SingleChildScrollView), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip(translate('Kapat',locale))); await tester.pumpAndSettle();
        await tester.tap(find.text('range')); await tester.pumpAndSettle();
        expect(tester.widget<TextFormField>(find.byType(TextFormField).first).controller!.text, '1');
        expect(tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text, '286');
        expect(tester.widget<TextFormField>(find.byType(TextFormField).last).controller!.text, '3');
        await tester.enterText(find.byType(TextFormField).at(1),'287');
        await tester.tap(find.text(translate('verseRepeatStart',locale))); await tester.pumpAndSettle();
        expect(find.text(translate('verseSurahLimit',locale, {'surah': surahName(surahs[1],locale), 'count':286})), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).first,'256');
        await tester.enterText(find.byType(TextFormField).at(1),'255');
        await tester.tap(find.text(translate('verseRepeatStart',locale))); await tester.pumpAndSettle();
        expect(find.text(translate('verseInvalidRange',locale)), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).at(1),'257');
        await tester.enterText(find.byType(TextFormField).last,'0');
        await tester.tap(find.text(translate('verseRepeatStart',locale))); await tester.pumpAndSettle();
        expect(find.text(translate('verseInvalidRepeats',locale)), findsOneWidget);
        await tester.enterText(find.byType(TextFormField).last,'2');
        await tester.tap(find.text(translate('verseRepeatStart',locale))); await tester.pumpAndSettle();
        expect(result, (256,257,2)); expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('holding a verse downloads and plays only that verse in the reader', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    final calls = <String>[];
    final downloaded = <String>[];
    String? playing;
    bool memorizing = false;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      if (call.method == 'loadAudio') { return {'tracks': [for (var i = 1; i <= 3; i++) {'id':'v$i','surah':1,'verse':i,'bytes':100}],
        'downloaded': downloaded, 'playing': playing, 'memorizing': memorizing}; }
      if (call.method == 'downloadAudio') { downloaded.add('v1'); calls.add('download'); }
      if (call.method == 'playAudio') { playing = (call.arguments as Map)['id']; calls.add('play:$playing'); }
      if (call.method == 'playAudioSelection') {
        expect(call.arguments, {'ids':['v1','v2','v3'], 'repetitions':1, 'cumulative':false});
        playing = 'selection'; calls.add('selection');
      }
      if (call.method == 'playAudioRange') {
        expect(call.arguments, {'surah':1, 'first':1, 'last':3, 'repetitions':2, 'cumulative':true});
        playing = 'range'; memorizing = true; calls.add('cumulative');
      }
      if (call.method == 'advanceMemorization') { calls.add('advance'); playing = null; memorizing = false; }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(ReadingStore.channel, null));
    tester.view.physicalSize = const Size(360,640); tester.view.devicePixelRatio = 1;
    final store = ReadingStore(directory: '/verse-test', lastPage: 0, informationSeen: true, bookmarks: {}, downloaded: {});
    final recorder = ui.PictureRecorder(); Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording(); final image = picture.toImageSync(539,780); picture.dispose();
    final provider = FileImage(File(store.pagePath(0)));
    PaintingBinding.instance.imageCache.putIfAbsent(provider, () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
    await tester.runAsync(() async { await VerseRegions.load(); });
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 0)));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const ValueKey('verse-0-1-1-0'))); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('selection-actions'))); await tester.pumpAndSettle();
    expect(find.text('Seslendir'), findsOneWidget, reason: tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join(' | ')); expect(find.text('Ezber'), findsOneWidget);
    await tester.tap(find.text('Seslendir')); await tester.pump(const Duration(milliseconds: 500));
    expect(calls,isEmpty);
    await tester.tap(find.text('İndirmeyi başlat')); await tester.pumpAndSettle();
    expect(calls,['download','play:v1']); expect(find.byType(QuranScreen),findsOneWidget);
    expect(find.byType(Dialog),findsNothing);
    playing = null; downloaded.addAll(['v2','v3']);
    await tester.pump(const Duration(milliseconds:600));
    final drag = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('verse-0-1-3-0'))));
    await tester.pump(const Duration(milliseconds:600));
    await drag.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-0-1-1-0'))));
    await tester.pump(); await drag.up(); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('selection-actions'))); await tester.pumpAndSettle();
    expect(find.text('1:1 – 1:3'),findsOneWidget);
    expect(find.text('Ezber'),findsOneWidget);
    await tester.tap(find.text('Seslendir')); await tester.pumpAndSettle();
    expect(calls.last,'selection'); playing=null;

    final memorizeDrag = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('verse-0-1-1-0'))));
    await tester.pump(const Duration(milliseconds:600));
    await memorizeDrag.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-0-1-3-0'))));
    await memorizeDrag.up();await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('selection-actions'))); await tester.pumpAndSettle();
    await tester.tap(find.text('Ezber')); await tester.pumpAndSettle();
    expect(tester.widgetList<TextFormField>(find.byType(TextFormField)).map((f)=>f.controller!.text), ['1','3','3']);
    await tester.enterText(find.byType(TextFormField).at(1), '3');
    await tester.enterText(find.byType(TextFormField).last, '2');
    await tester.tap(find.text('Ezbere başla')); await tester.pumpAndSettle();
    expect(calls.last, 'cumulative');
    expect(find.text('İlerle'), findsOneWidget);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(find.text('İlerle'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('İlerle')); await tester.pumpAndSettle();
    expect(calls.last, 'advance');
    expect(find.text('İlerle'), findsNothing);
    await tester.pumpWidget(const SizedBox()); await tester.pump();
    final sajdahProvider = FileImage(File(store.pagePath(175)));
    PaintingBinding.instance.imageCache.putIfAbsent(sajdahProvider, () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 175)));
    await tester.pumpAndSettle();
    final highlight = find.descendant(of: find.byKey(const ValueKey('verse-175-7-206-0')), matching: find.byType(ColoredBox));
    expect(tester.widget<ColoredBox>(highlight).color, const Color(0x55FFB300));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.widget<ColoredBox>(highlight).color, const Color(0x55FFB300));
    await tester.pumpWidget(const SizedBox()); await tester.pump();
    PaintingBinding.instance.imageCache.clear(); PaintingBinding.instance.imageCache.clearLiveImages(); image.dispose();
  });
}
