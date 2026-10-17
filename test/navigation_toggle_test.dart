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
      expect(AppNavigation.instance.selected.value, destination);
      if (destination == AppDestination.hatim) {
        final title = tester.widget<AppBar>(find.byType(AppBar)).title! as Text;
        expect(title.data, startsWith('Hatim · '));
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
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    image.dispose();
    messenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
}
