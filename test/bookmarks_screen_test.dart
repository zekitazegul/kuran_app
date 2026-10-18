import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/bookmarks_screen.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/home_pages.dart';

void main() {
  for (final embedded in [false, true]) {
    testWidgets('bookmarks is a list and opens a reader only after selecting a bookmark ($embedded)', (tester) async {
      final store = ReadingStore(directory: '/bookmarks-test', lastPage: 1,
        informationSeen: true, bookmarks: {439}, downloaded: Set.of(List.generate(605, (i) => i)));
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, null));
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.white, BlendMode.src);
      final picture = recorder.endRecording();
      final image = picture.toImageSync(2, 2);
      picture.dispose();
      PaintingBinding.instance.imageCache.putIfAbsent(FileImage(File(store.pagePath(439))), () =>
        OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
      AppPreferences.instance.value = const UiPreferences(customPages: [['bookmarks']]);
      final controller = PageController(initialPage: 2);
      await tester.pumpWidget(MaterialApp(home: embedded ? Scaffold(body: HomePages(
        controller: controller, dashboard: const Text('home'), cards: const {},
        features: {'bookmarks': (_) => BookmarksScreen(store: store)},
      )) : BookmarksScreen(store: store)));
      await tester.pumpAndSettle();
      expect(find.text('AYRAÇLAR'), findsOneWidget);
      expect(find.byType(QuranScreen), findsNothing);
      expect(find.byKey(const ValueKey('personal-reader-surah')), findsNothing);
      expect(find.byKey(const ValueKey('bookmark-439')), findsOneWidget);
      if (embedded) {
        await tester.drag(find.byKey(const ValueKey('bookmark-439')), const Offset(-300, 0));
        await tester.pumpAndSettle();
        expect(controller.page, 3);
        controller.jumpToPage(2);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('bookmark-439')));
      await tester.pumpAndSettle();
      expect(find.byType(QuranScreen), findsOneWidget);
      expect(find.text('439 / 604'), findsOneWidget);
      Navigator.of(tester.element(find.byType(QuranScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(QuranScreen), findsNothing);
      expect(find.text('AYRAÇLAR'), findsOneWidget);
      expect(find.byKey(const ValueKey('personal-reader-surah')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      AppPreferences.instance.restore(null);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      image.dispose();
    });
  }
}
