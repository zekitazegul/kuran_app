import '../data/surahs.dart';

/// Match complete commands, so e.g. Nas never accidentally matches Nasr.
class VoiceCommands {
  static const prefixes = ['', 'lutfen', 'bana', 'surah', 'soera', 'sure',
    'open', 'pleaseopen', 'opensurah', 'pleaseopensurah', 'opensoera',
    'openhoofdstuk', 'goto', 'gotosurah', 'ganaar', 'ganaarsoera'];
  static const suffixes = ['', 'ac', 'iac', 'yiac', 'suresi', 'suresini',
    'suresiniac', 'suresinegit', 'suresiac', 'suresiniacarmisin'];
  static String normalize(String value) => normalizeSurahName(value).replaceAll(RegExp('[^a-z0-9]'), '');

  static ({int surah, bool play})? parse(String text) {
    final command = normalize(text);
    for (final suffix in ['suresinioku', 'suresiniseslendir', 'suresinidinle', 'oku', 'seslendir', 'dinle']) {
      if (command.endsWith(suffix)) {
        final number = surah(command.substring(0, command.length - suffix.length));
        if (number != null) return (surah: number, play: true);
      }
    }
    for (final prefix in ['play', 'recite', 'read', 'listento', 'speel', 'lees', 'reciteer']) {
      if (command.startsWith(prefix)) {
        var target = command.substring(prefix.length);
        if (target.endsWith('af')) target = target.substring(0, target.length - 2);
        final number = surah(target);
        if (number != null) return (surah: number, play: true);
      }
    }
    final number = surah(text);
    return number == null ? null : (surah: number, play: false);
  }

  static int? surah(String text) {
    final command = normalize(text);
    if (command.isEmpty) return null;
    for (final entry in surahs) {
      final international = internationalSurahNames[entry.number - 1];
      final names = {normalize(entry.name), normalize(international),
        normalize(international.replaceFirst(RegExp(r"^(Al|An|Ar|As|Ash|At|Ad|Az)-"), '')),
        '${entry.number}', if (entry.number == 36) ...['yaseen', 'yasin']};
      for (final name in names) {
        for (final prefix in prefixes) {
          for (final suffix in suffixes) {
            if (command == '$prefix$name$suffix') return entry.number;
          }
        }
      }
    }
    return null;
  }
}
