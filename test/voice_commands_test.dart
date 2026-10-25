import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/services/voice_commands.dart';

void main() {
  test('spoken reading commands select playback without accepting negation', () {
    for(final command in ['Fetih suresini oku','Fetih suresini seslendir','Read Surah Al-Fath','Play Surah Al-Fath','Lees soera Al-Fath']) {
      expect(VoiceCommands.parse(command),(surah:48,play:true));
    }
    expect(VoiceCommands.parse('Fetih suresini ac'),(surah:48,play:false));
    expect(VoiceCommands.parse('Fetih suresini okuma'),isNull);
    expect(VoiceCommands.parse('do not read Surah Al-Fath'),isNull);
  });

  test('every surah can be opened by its displayed Turkish or international name', () {
    for (final surah in surahs) {
      expect(VoiceCommands.surah('${surah.name} suresini aç'), surah.number);
      expect(VoiceCommands.surah('Open Surah ${internationalSurahNames[surah.number - 1]}'), surah.number);
      expect(VoiceCommands.surah('Open soera ${internationalSurahNames[surah.number - 1]}'), surah.number);
    }
  });
  test('recognition variants and numbered surahs are supported', () {
    for (final command in ['Yasin suresini aç.', 'Lütfen Yâsîn suresini aç', 'Open Surah Yaseen', 'Open soera 36']) {
      expect(VoiceCommands.surah(command), 36, reason: command);
    }
    expect(VoiceCommands.surah('İhlâs suresini aç'), 112);
    expect(VoiceCommands.surah('Nas suresini aç'), 114);
    expect(VoiceCommands.surah('Nasr suresini aç'), 110);
  });
  test('unrelated, negative, ambiguous and out-of-range speech does not navigate', () {
    for (final command in ['', 'Yasin suresini açma', 'do not open Surah Yasin', 'open surah 115', '36 ayet', 'play music', 'Yasin ve Fatiha']) {
      expect(VoiceCommands.surah(command), isNull, reason: command);
    }
  });
}
