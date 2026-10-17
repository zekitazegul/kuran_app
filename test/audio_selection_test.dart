import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/screens/listening_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/quran_audio.dart';

void main() {
  for (final fail in [false, true]) {
    testWidgets('bulk delete confirms selection and retains failures ($fail)', (tester) async {
      AppLanguage.instance.value = const Locale('tr');
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final removed = <String>[];
      final downloaded = <String>{'track1', 'track2', 'track3'};
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(QuranAudio.channel, (call) async {
        if (call.method == 'loadAudio') {
          return {'tracks': [for (var i = 1; i <= 3; i++) {'id': 'track$i', 'surah': i, 'bytes': 100}],
            'downloaded': downloaded.toList(), 'playing': null};
        }
        if (call.method == 'removeAudio') {
          final id = (call.arguments as Map)['id'] as String;
          if (fail && id == 'track2') throw PlatformException(code: 'disk');
          removed.add(id);
          downloaded.remove(id);
        }
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(QuranAudio.channel, null));
      await tester.pumpWidget(const MaterialApp(home: ListeningScreen()));
      await tester.pumpAndSettle();
      final first = find.byKey(const ValueKey('downloaded-audio-track1'));
      final second = find.byKey(const ValueKey('downloaded-audio-track2'));
      final third = find.byKey(const ValueKey('downloaded-audio-track3'));
      await tester.longPress(first);
      await tester.pumpAndSettle();
      expect(find.text('1 seçildi'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(3));
      await tester.tap(second);
      await tester.pumpAndSettle();
      expect(find.text('2 seçildi'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('audio-delete-selected')));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 ses kaydı silinecek'), findsOneWidget);
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(removed, isEmpty);
      expect(find.text('2 seçildi'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('audio-delete-selected')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kaldır'));
      await tester.pumpAndSettle();
      expect(first, findsNothing);
      expect(third, findsOneWidget);
      if (fail) {
        expect(removed, ['track1']);
        expect(second, findsOneWidget);
        expect(find.text('1 seçildi'), findsOneWidget);
        expect(find.textContaining('Ses işlemi tamamlanamadı'), findsOneWidget);
        await tester.tap(find.byTooltip('Seçimi iptal et'));
        await tester.pumpAndSettle();
      } else {
        expect(removed, ['track1', 'track2']);
        expect(second, findsNothing);
      }
      expect(find.byType(Checkbox), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
