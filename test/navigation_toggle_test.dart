import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/screens/settings_screen.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/widgets/language_selector.dart';
import 'package:kuran_app/services/app_preferences.dart';

void main() {
  testWidgets('navigation destinations toggle closed; home stays open', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      if (call.method == 'load') {
        return {'directory': '/test', 'lastPage': 439, 'bookmarks': <int>[],
          'downloaded': List.generate(605, (i) => i), 'informationSeen': true, 'guideSeen': true};
      }
      return null;
    });
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(2, 2);
    picture.dispose();
    for (final page in [0, 439]) {
      final key = FileImage(File('/test/page${page.toString().padLeft(3, '0')}.png'));
      PaintingBinding.instance.imageCache.putIfAbsent(key, () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image.clone()))));
    }
    await tester.pumpWidget(const KuranApp());
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSelector), findsOneWidget);
    for (final destination in [AppDestination.hatim, AppDestination.surahs, AppDestination.bookmarks, AppDestination.search, AppDestination.history, AppDestination.settings]) {
      if (destination == AppDestination.hatim) {
        await tester.scrollUntilVisible(find.byKey(const ValueKey('dashboard-card-hatim')), 200,
          scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hatim'));
      } else {
        AppNavigation.instance.open!(destination);
      }
      if (destination == AppDestination.settings) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(tester.getTopLeft(find.byType(SettingsScreen)).dy, greaterThan(0));
      }
      await tester.pumpAndSettle();
      expect(appNavigatorKey.currentState!.canPop(), isTrue, reason: destination.name);
      expect(find.byType(LanguageSelector), findsNothing, reason: destination.name);
      expect(AppNavigation.instance.selected.value, destination);
      if (destination == AppDestination.hatim) {
        final title = tester.widget<AppBar>(find.byType(AppBar)).title! as Text;
        expect(title.data, startsWith('HATİM · '));
        expect(find.byType(QuranScreen), findsOneWidget);
      }
      AppNavigation.instance.open!(destination);
      if (destination == AppDestination.settings) {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        expect(tester.getTopLeft(find.byType(SettingsScreen)).dy, greaterThan(0));
      }
      await tester.pumpAndSettle();
      expect(appNavigatorKey.currentState!.canPop(), isFalse, reason: destination.name);
      expect(AppNavigation.instance.selected.value, AppDestination.home);
      expect(tester.takeException(), isNull);
    }
    for (var i = 0; i < 2; i++) {
      AppNavigation.instance.open!(AppDestination.home);
      await tester.pumpAndSettle();
      expect(appNavigatorKey.currentState!.canPop(), isFalse);
      expect(find.byType(HomeScreen), findsOneWidget);
    }
    expect(find.byType(PageView), findsNothing);
    expect(AppNavigation.instance.switchPage, isNull);
    for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
      tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
      await tester.pumpAndSettle();
      await tester.drag(find.byType(HomeScreen), const Offset(-200,0));
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);
      expect(appNavigatorKey.currentState!.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SizedBox());
    AppPreferences.instance.restore(null);
    await tester.pump();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    image.dispose();
    messenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
}
