import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/hatim_prayer_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/l10n/translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<String> calls;
  late Completer<void> playback;
  setUp(() {
    calls = [];
    playback = Completer<void>();
    AppLanguage.instance.restore('tr');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, (call) async {
          calls.add(call.method);
          if (call.method == 'playHatimPrayer') {
            playback = Completer<void>();
            await playback.future;
            return null;
          }
          if (call.method == 'stopHatimPrayer' && !playback.isCompleted) {
            playback.complete();
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, null);
    AppLanguage.instance.restore('tr');
  });
  testWidgets(
    'Human recording starts, stops, replays and stops in background',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HatimPrayerScreen()));
      await tester.pumpAndSettle();
      expect(calls, ['playHatimPrayer']);
      expect(find.textContaining('Abdurrahman es-Sudeys'), findsOneWidget);
      expect(find.text('Durdur'), findsOneWidget);
      await tester.tap(find.text('Durdur'));
      await tester.pumpAndSettle();
      expect(find.text('Tekrar dinle'), findsOneWidget);
      await tester.tap(find.text('Tekrar dinle'));
      await tester.pumpAndSettle();
      expect(find.text('Durdur'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.idle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Tekrar dinle'), findsOneWidget);
      expect(calls.where((call) => call == 'playHatimPrayer').length, 2);
      expect(calls, isNot(contains('speakHatimPrayer')));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
  testWidgets('Playback failure is shown without synthesized fallback', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, (call) async {
          calls.add(call.method);
          if (call.method == 'playHatimPrayer') {
            throw PlatformException(code: 'PRAYER_AUDIO_ERROR');
          }
          return null;
        });
    await tester.pumpWidget(const MaterialApp(home: HatimPrayerScreen()));
    await tester.pumpAndSettle();
    expect(find.text(translate('prayerAudioError', 'tr')), findsOneWidget);
    expect(calls, ['playHatimPrayer']);
    expect(find.text('Tekrar dinle'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  for (final language in ['tr', 'en', 'nl']) {
    for (final size in [
      const Size(360, 640),
      const Size(640, 360),
      const Size(800, 1280),
      const Size(1280, 800),
    ]) {
      testWidgets('Prayer recording fits $language $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        AppLanguage.instance.restore(language);
        await tester.pumpWidget(const MaterialApp(home: HatimPrayerScreen()));
        await tester.pumpAndSettle();
        expect(
          find.text(translate('prayerRecordingDetails', language)),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.text(translate('prayerTurkishExample', language)),
          100,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      });
    }
  }
}
