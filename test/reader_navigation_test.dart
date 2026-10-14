import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/page_turn.dart';

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
    for (var page = 438; page <= 442; page++) {
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

  testWidgets('arrows can turn repeatedly without a paper animation', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    for (final page in [440, 441]) {
      await tester.tap(find.byTooltip('Sonraki sayfa'));
      await tester.pump();
      expect(find.byType(PageTurn), findsNothing);
      expect(find.text('$page / 604'), findsOneWidget);
      expect(tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Sonraki sayfa')).onPressed, isNotNull);
    }
    await tester.tap(find.byTooltip('Önceki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('440 / 604'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('animated edge turn unlocks navigation after completion', (tester) async {
    await tester.pumpWidget(MaterialApp(home: QuranScreen(store: store, initialPage: 439)));
    await tester.pumpAndSettle();
    final reader = find.byKey(const ValueKey('quran-reading-surface'));
    final bounds = tester.getRect(reader);
    await tester.tapAt(Offset(bounds.left + 8, bounds.center.dy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(PageTurn), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('440 / 604'), findsOneWidget);
    expect(tester.widget<IconButton>(find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Sonraki sayfa')).onPressed, isNotNull);
    await tester.tap(find.byTooltip('Sonraki sayfa'));
    await tester.pumpAndSettle();
    expect(find.text('441 / 604'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
