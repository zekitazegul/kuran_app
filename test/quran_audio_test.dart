import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/quran_audio.dart';
import 'package:kuran_app/screens/listening_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/data/verse_counts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(QuranAudio.channel, null));
  test('only complete verse reciters are offered', () {
    final catalog = jsonDecode(File('assets/audio.json').readAsStringSync()) as Map;
    final tracks = catalog['tracks'] as List;
    expect(tracks.length, verseCounts.reduce((a, b) => a + b) * 5);
    expect((catalog['reciters'] as List).map((r) => r['id']).toSet(), {'shatri','alafasy','minshawi','abdulbasit','maher'});
    expect((catalog['reciters'] as List).any((r) => r['partial'] == true), false);
    for (final reader in ['shatri', 'alafasy', 'minshawi', 'abdulbasit', 'maher']) {
      final selected = tracks.where((t) => t['reciter'] == reader).toList();
      for (var surah = 1; surah <= 114; surah++) {
        final verses = selected.where((t) => t['surah'] == surah).map((t) => t['verse']).toSet();
        expect(verses, {for (var v = 1; v <= verseCounts[surah - 1]; v++) v});
      }
      for (final track in selected) {
        expect(Uri.parse(track['url'] as String).host, 'everyayah.com');
        expect(Uri.parse(track['url'] as String).scheme, 'https');
        expect(track['bytes'], greaterThan(0));
        expect(RegExp(r'^[a-f0-9]{32}$').hasMatch(track['md5'] as String), isTrue);
      }
    }
  });

  test('page audio covers every verse exactly once and spans surah boundaries', () {
    final data = jsonDecode(File('assets/page_verses.json').readAsStringSync()) as Map;
    final pages = data['pages'] as List;
    expect(pages.length, 605);
    final refs = pages.expand((page) => page as List).map((v) => '${v['surah']}:${v['verse']}').toList();
    expect(refs, [for (var s = 1; s <= 114; s++) for (var v = 1; v <= verseCounts[s - 1]; v++) '$s:$v']);
    expect((pages[45] as List).map((v) => v['verse']).toList(), [270, 271, 272, 273, 274]);
    expect(pages.any((page) => (page as List).map((v) => v['surah']).toSet().length > 1), isTrue);
  });

  test('Shatri is default and selected reciter is restored from native settings', () async {
    var selected = 'shatri';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(QuranAudio.channel, (call) async {
      if (call.method == 'selectAudioReciter') { selected = (call.arguments as Map)['id'] as String; return null; }
      return {'tracks': [], 'downloaded': [], 'playing': null, 'reciter': selected,
        'reciters': [{'id': 'shatri', 'name': 'Abu Bakr Ash-Shatri'}, {'id': 'alafasy', 'name': 'Mishary Rashid Alafasy'}]};
    });
    final audio = QuranAudio();
    await audio.load();
    expect(audio.reciter, 'shatri');
    await audio.selectReciter('alafasy');
    final restored = QuranAudio(); await restored.load();
    expect(restored.reciter, 'alafasy');
  });

  testWidgets('stop request stays pending until the verse completes', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    String? playing;
    var pending = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(QuranAudio.channel, (call) async {
      if (call.method == 'playAudio') { playing = 'shatri_surah_001'; return null; }
      if (call.method == 'stopAudio') { pending = true; return null; }
      return {'tracks': [{'id': 'shatri_surah_001', 'surah': 1, 'bytes': 1000}],
        'downloaded': ['shatri_surah_001'], 'playing': playing, 'stopPending': pending, 'currentVerse': playing == null ? null : 1};
    });
    await tester.pumpWidget(const MaterialApp(home: ListeningScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Meal Oku'), findsNothing);
    expect(find.text("KUR'AN DİNLE"), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(const ValueKey('listening-surah'))).dy,
      lessThan(tester.getTopLeft(find.byType(DropdownButtonFormField<String>)).dy));
    expect(find.textContaining('ndirilen sesler'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Dinle'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Durdur'));
    await tester.pumpAndSettle();
    expect(playing, 'shatri_surah_001');
    expect(find.text('Ayet sonunda duracak'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Ayet sonunda duracak')).onPressed, isNull);
    playing = null; pending = false;
    await tester.pump(const Duration(seconds: 2)); await tester.pumpAndSettle();
    expect(find.text('Ayet sonunda duracak'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  test('audio downloads once and can be played, deleted and downloaded again', () async {
    final downloaded = <String>{};
    var transfers = 0;
    String? playing;
    var stopPending = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(QuranAudio.channel, (call) async {
        final id = (call.arguments as Map?)?['id'] as String?;
        switch (call.method) {
          case 'loadAudio': return {'tracks': [
            {'id': 'fath', 'surah': 48, 'bytes': 1200},
            {'id': 'fath_1', 'surah': 48, 'verse': 1, 'bytes': 100},
          ], 'downloaded': downloaded.toList(), 'playing': playing, 'stopPending': stopPending};
          case 'downloadAudio': transfers++; downloaded.add(id!); return null;
          case 'playAudio': playing = id; return null;
          case 'stopAudio': stopPending = true; return null;
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
    await expectLater(audio.remove(track), throwsStateError);
    await expectLater(audio.play(track), throwsStateError);
    await audio.stop();
    expect(audio.playing, 'fath');
    expect(audio.stopPending, isTrue);
    playing = null; stopPending = false;
    await audio.load();
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
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ayet')); await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30'); await tester.pump();
    expect(find.text('Geçerli bir ayet numarası yaz.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); await tester.pump();
  });
}
