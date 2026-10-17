import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:kuran_app/widgets/reading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/page_slide.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ReadingStore store;
  late ui.Image image;
  setUp(() {
    AppLanguage.instance.value = const Locale('tr');
    store = ReadingStore(directory: '/reader-test', lastPage: 439,
      informationSeen: true, bookmarks: {}, downloaded: {}, pageAnimations: true);
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    image = picture.toImageSync(2, 2);
    picture.dispose();
    for (final page in [0, 45, 438, 439, 440, 441, 442, 604]) {
      final key = FileImage(File(store.pagePath(page)));
      PaintingBinding.instance.imageCache.putIfAbsent(key, () =>
        OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
  });
  tearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    image.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, null);
  });

  for (final hatim in [false, true]) {
    testWidgets('fullscreen reader keeps page audio and meal controls ($hatim)', (tester) async {
      String? playing;
      var pending = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'loadAudio') {
          return {
          'tracks': [{'id': 'shatri_page_45', 'page': 45, 'surah': 2, 'bytes': 1000}],
          'downloaded': ['shatri_page_45'], 'playing': playing, 'stopPending': pending,
          };
        }
        if (call.method == 'playAudio') playing = (call.arguments as Map)['id'] as String;
        if (call.method == 'stopAudio') pending = playing != null;
        return null;
      });
      await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 45, hatim: hatim)));
      await tester.pumpAndSettle();
      final center = tester.getCenter(find.byKey(const ValueKey('quran-reading-surface')));
      await tester.tapAt(center); await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(center); await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('reader-meal')), findsOneWidget);
      expect(tester.getBottomRight(find.byKey(const ValueKey('reader-meal'))).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byKey(const ValueKey('quran-reading-surface'))).dy));
      await tester.tap(find.byKey(const ValueKey('reader-listen'))); await tester.pumpAndSettle();
      expect(playing, 'shatri_page_45');
      expect(find.byTooltip('Durdur'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reader-listen'))); await tester.pumpAndSettle();
      expect(pending, true); expect(playing, 'shatri_page_45');
      expect(find.byTooltip('Ayet sonunda duracak'), findsOneWidget);
      playing = null; pending = false;
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('hatim page label opens page 45 while only checkbox marks read', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439, hatim: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sayfa / cüz işaretle'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hatim-select-page-0')));
    await tester.pumpAndSettle();
    expect(store.hatimPages, {0});
    expect(find.text('Sayfalar'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sayfa 45'), 500,
      scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first);
    await tester.tap(find.text('Sayfa 45'));
    await tester.pumpAndSettle();
    expect(find.text('45 / 604'), findsOneWidget);
    expect(store.hatimPages, {0});
    expect(store.hatimResume, 45);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('completed hatim prayer can return to last page and unmark it', (tester) async {
    store.hatimPages.addAll(List.generate(605, (i) => i));
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 604,
      initialPanel: 'prayer', hatim: true)));
    await tester.pumpAndSettle();
    expect(find.text('Hatminiz tamamlandı'), findsOneWidget);
    await tester.tap(find.text('Okumaya dön'));
    await tester.pumpAndSettle();
    expect(find.text('604 / 604'), findsOneWidget);
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('Hatminiz tamamlandı'), findsOneWidget);
    await tester.drag(find.text('Hatminiz tamamlandı'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(find.text('604 / 604'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hatim-read-checkbox')));
    await tester.pumpAndSettle();
    expect(store.hatimPages.contains(604), isFalse);
    expect(store.hatimComplete, isFalse);
    await tester.tap(find.byKey(const ValueKey('hatim-read-checkbox')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Yeni hatme başla'), 180,
      scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yeni hatme başla'));
    await tester.pumpAndSettle();
    expect(store.hatimPages, isEmpty);
    expect(find.text('0 / 604'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('history records visible pages after two seconds and pauses in background', (tester) async {
    final writes = <Map>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'saveReadingHistory') writes.add(call.arguments as Map);
        return null;
      });
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(writes, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(writes.length, 1);
    expect(store.history.first.firstPage, 439);
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));
    expect(writes.length, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(writes.length, 2);
    expect(store.history.first.firstPage, 440);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hatim checkbox toggles without turning the page; swipe remains manual', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439, hatim: true)));
    await tester.pumpAndSettle();
    final checkbox = find.byKey(const ValueKey('hatim-read-checkbox'));
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(store.hatimPages, contains(439));
    expect(find.text('439 / 604'), findsOneWidget);
    expect(tester.widget<FractionallySizedBox>(find.byKey(const ValueKey('hatim-page-curtain-439'))).heightFactor, 1);
    expect(find.byType(ImageFiltered), findsNothing);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(store.hatimPages, isNot(contains(439)));
    expect(tester.widget<FractionallySizedBox>(find.byKey(const ValueKey('hatim-page-curtain-439'))).heightFactor, 0);
    expect(find.text('439 / 604'), findsOneWidget);
    await tester.drag(find.byKey(const ValueKey('quran-reading-surface')), const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(find.text('440 / 604'), findsOneWidget);
    expect(store.hatimPages, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('landscape hatim controls fade out and return with a short bottom swipe', (tester) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439, hatim: true)));
    await tester.pumpAndSettle();
    final reader = find.byKey(const ValueKey('quran-reading-surface'));
    var center = tester.getCenter(reader);
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final fading = find.ancestor(of: find.byKey(const ValueKey('hatim-read-checkbox')), matching: find.byType(Opacity));
    expect(tester.widget<Opacity>(fading).opacity, lessThan(1));
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(fading).opacity, 0);
    final bounds = tester.getRect(reader);
    await tester.dragFrom(Offset(bounds.center.dx, bounds.bottom - 12), const Offset(0, -45));
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(fading).opacity, 1);
    expect(store.hatimPages, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('arrows can turn repeatedly without a paper animation', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    for (final page in [440, 441]) {
      await tester.tap(find.byTooltip('Sonraki sayfa'));
      await tester.pump();
      expect(find.byType(PageSlide), findsNothing);
      expect(find.text('$page / 604'), findsOneWidget);
      expect(tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Sonraki sayfa')).onPressed, isNotNull);
    }
    await tester.tap(find.byTooltip('Önceki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('440 / 604'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('page follows finger one to one and completes even a short drag', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    final reader = find.byKey(const ValueKey('quran-reading-surface'));
    final gesture = await tester.startGesture(tester.getCenter(reader));
    await gesture.moveBy(const Offset(35, 0));
    await tester.pump();
    final moving = find.byKey(const ValueKey('sliding-current-page'));
    expect(tester.widget<Transform>(moving).transform.getTranslation().x, closeTo(35, .01));
    await gesture.moveBy(const Offset(65, 0));
    await tester.pump();
    expect(tester.widget<Transform>(moving).transform.getTranslation().x, closeTo(100, .01));
    await gesture.moveBy(const Offset(-125, 0));
    await tester.pump();
    expect(tester.widget<Transform>(moving).transform.getTranslation().x, closeTo(-25, .01));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('438 / 604'), findsOneWidget);
    expect(store.lastPage, 438);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('edge taps and vertical overscroll never turn pages or exit fullscreen', (tester) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    final reader = find.byKey(const ValueKey('quran-reading-surface'));
    var bounds = tester.getRect(reader);
    for (final x in [bounds.left + 8, bounds.right - 8]) {
      await tester.tapAt(Offset(x, bounds.center.dy));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(store.lastPage, 439);
    }
    await tester.tapAt(bounds.center);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(bounds.center);
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    await tester.dragFrom(tester.getCenter(reader), const Offset(0, 160));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
    await tester.pump();
    await tester.dragFrom(tester.getCenter(reader), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(store.lastPage, 439);
    expect(find.byType(PageSlide), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(scroll.controller!.offset, scroll.controller!.position.maxScrollExtent);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('manual slide unlocks navigation after completion', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    final reader = find.byKey(const ValueKey('quran-reading-surface'));
    final bounds = tester.getRect(reader);
    final gesture = await tester.startGesture(bounds.center);
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(find.byType(PageSlide), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('440 / 604'), findsOneWidget);
    expect(tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Sonraki sayfa')).onPressed, isNotNull);
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('441 / 604'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('only double taps zoom; bottom-edge upward swipe exits fullscreen', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    ReadingPage page() => tester.widget<ReadingPage>(find.byType(ReadingPage));
    expect(page().crop, isNull);
    await tester.tapAt(tester.getCenter(find.byKey(const ValueKey('quran-reading-surface'))));
    await tester.pump(kDoubleTapTimeout); await tester.pumpAndSettle();
    expect(page().crop, isNull);
    Future<void> doubleTap() async {
      final center = tester.getCenter(find.byKey(const ValueKey('quran-reading-surface')));
      await tester.tapAt(center); await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(center); await tester.pumpAndSettle();
    }
    await doubleTap();
    expect(page().crop, store.edition.normalizedOuterCrop(439));
    expect(find.byType(AppBar), findsNothing);
    await doubleTap();
    expect(page().crop, store.edition.normalizedCrop(439));
    await doubleTap();
    expect(page().crop, isNull);
    expect(find.byType(AppBar), findsOneWidget);
    await doubleTap();
    expect(page().crop, store.edition.normalizedOuterCrop(439));
    await tester.tapAt(tester.getCenter(find.byKey(const ValueKey('quran-reading-surface'))));
    await tester.pump(kDoubleTapTimeout); await tester.pumpAndSettle();
    expect(page().crop, store.edition.normalizedOuterCrop(439));
    expect(find.byType(AppBar), findsNothing);
    final bounds = tester.getRect(find.byKey(const ValueKey('quran-reading-surface')));
    await tester.dragFrom(Offset(bounds.center.dx, bounds.bottom - 35), const Offset(0, -140));
    await tester.pumpAndSettle();
    expect(page().crop, isNull);
    expect(find.byType(AppBar), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

}
