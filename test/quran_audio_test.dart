import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/quran_audio.dart';
import 'package:kuran_app/screens/listening_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/data/verse_counts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(QuranAudio.channel, null));
  test('audio downloads once and can be played, deleted and downloaded again', () async {
    final downloaded = <String>{};
    var transfers = 0;
    String? playing;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(QuranAudio.channel, (call) async {
        final id = (call.arguments as Map?)?['id'] as String?;
        switch (call.method) {
          case 'loadAudio': return {'tracks': [
            {'id': 'fath', 'surah': 48, 'bytes': 1200},
            {'id': 'fath_1', 'surah': 48, 'verse': 1, 'bytes': 100},
          ], 'downloaded': downloaded.toList(), 'playing': playing};
          case 'downloadAudio': transfers++; downloaded.add(id!); return null;
          case 'playAudio': playing = id; return null;
          case 'stopAudio': playing = null; return null;
          case 'removeAudio': downloaded.remove(id); if (playing == id) playing = null; return null;
        }
        throw StateError(call.method);
      });
    final audio = QuranAudio(); await audio.load();
    final track = audio.find(48, null)!;
    expect(audio.find(48, 1)!.id, 'fath_1');
    expect(audio.find(48, 2), isNull);
    await expectLater(audio.play(track), throwsStateError);
    await audio.download(track); await audio.download(track);
    expect(transfers, 1);
    await audio.play(track); expect(audio.playing, 'fath');
    await audio.remove(track); expect(audio.playing, isNull);
    expect(audio.downloaded, isEmpty);
    await audio.download(track); expect(transfers, 2);
    await audio.load(); expect(audio.downloaded, {'fath'});
    expect(verseCounts.length, 114); expect(verseCounts[47], 29);
  });
  testWidgets('missing recordings are explained without enabling download or play', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(QuranAudio.channel, (call) async => call.method == 'loadAudio'
        ? {'tracks': [], 'downloaded': [], 'playing': null} : null);
    await tester.pumpWidget(const MaterialApp(home: ListeningScreen(initialSurah: 48)));
    await tester.pumpAndSettle();
    expect(find.textContaining('ses kaydı henüz eklenmedi'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await tester.tap(find.text('Seçilen ayet')); await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30'); await tester.pump();
    expect(find.text('Geçerli bir ayet numarası yaz.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); await tester.pump();
  });
}
