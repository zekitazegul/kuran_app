import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/voice_intents.dart';
import 'package:kuran_app/services/voice_suggestions.dart';

void main() {
  test('corrects similar surah names and controls in each interface language', () {
    const examples = {
      'tr': {'Yasni suresini aç': 'Yâsin suresini aç', 'Feth suresini dinle': 'Fetih suresini dinle', 'yazıyı büyütür': 'Yazıyı büyüt'},
      'en': {'Open Surah Yasinx': 'Open Surah Ya-Sin', 'make text biger': 'Make text bigger'},
      'nl': {'open soera Yasni': 'Open soera Ya-Sin', 'maak tekst grotr': 'Maak tekst groter'},
    };
    for (final locale in examples.entries) {
      for (final example in locale.value.entries) {
        final suggestion = VoiceSuggestions.suggest(example.key, locale.key);
        expect(suggestion, example.value, reason: '${locale.key}: ${example.key}');
        expect(VoiceIntents.parse(suggestion!), isNotNull);
      }
    }
  });
  test('keeps requested page verse and repeat numbers', () {
    for (final example in [
      ('120 sayfayı açç', 'tr', VoiceAction.page, 120, null, 1),
      ('Open paeg one hundred twenty', 'en', VoiceAction.page, 120, null, 1),
      ('open pagina 1200', 'nl', null, null, null, null),
      ('Bakra 255 yi aç', 'tr', VoiceAction.verse, 2, 255, 1),
      ('Yasni suresini 5 kere oku', 'tr', VoiceAction.surah, 36, null, 5),
      ('Yasni 12 yi 5 kere dinle', 'tr', VoiceAction.verse, 36, 12, 5),
    ]) {
      final suggestion = VoiceSuggestions.suggest(example.$1, example.$2);
      if (example.$3 == null) { expect(suggestion, isNull); continue; }
      expect(suggestion, isNotNull, reason: example.$1);
      final command = VoiceIntents.parse(suggestion!);
      expect(command?.action, example.$3, reason: suggestion);
      expect(command?.number, example.$4);
      expect(command?.verse, example.$5);
      expect(command?.repetitions, example.$6);
    }
  });
  test('does not invent a correction for unrelated speech or invalid targets', () {
    for (final input in ['', 'xyz', 'hava bugün çok güzel', 'play music', 'Open page 605', 'Open juz 31', 'Bakara 287 yi ac', 'Yasin suresini 1000 kere oku']) {
      expect(VoiceSuggestions.suggest(input, 'tr'), isNull, reason: input);
    }
  });
}
