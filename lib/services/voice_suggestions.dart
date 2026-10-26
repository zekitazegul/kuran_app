import '../data/surahs.dart';
import '../data/verse_counts.dart';
import 'voice_commands.dart';
import 'voice_intents.dart';

/// Suggestions are displayed for review; they never execute a guessed intent.
class VoiceSuggestions {
  static const _controls = [
    ['Kaldığım yerden devam et', 'Continue reading', 'Ga verder met lezen'],
    ['Duraklat', 'Pause', 'Pauseer'], ['Devam et', 'Resume', 'Hervat'],
    ['Durdur', 'Stop', 'Stop'], ['Sonraki ayet', 'Next verse', 'Volgend vers'],
    ['Tekrar dinlet', 'Play again', 'Speel opnieuw'],
    ['Bu ayetin mealini göster', 'Show this verse translation', 'Toon de vertaling van dit vers'],
    ['Meali aç', 'Show translation', 'Toon vertaling'],
    ['Meali kapat', 'Close translation', 'Sluit vertaling'],
    ['Bu sayfayı kaydet', 'Save this page', 'Sla deze pagina op'],
    ['Ayraçlarımı aç', 'Open bookmarks', 'Open bladwijzers'],
    ['Yazıyı büyüt', 'Make text bigger', 'Maak tekst groter'],
    ['Yazıyı küçült', 'Make text smaller', 'Maak tekst kleiner'],
    ['Gece modunu aç', 'Enable night mode', 'Zet nachtmodus aan'],
    ['Gece modunu kapat', 'Disable night mode', 'Zet nachtmodus uit'],
    ['Tam ekran', 'Full screen', 'Volledig scherm'],
    ['Tam ekrandan çık', 'Exit full screen', 'Verlaat volledig scherm'],
    ['Sesli komutlar', 'Voice commands', 'Spraakopdrachten'],
  ];

  static String? suggest(String speech, String language) {
    final input = VoiceIntents.normalizeNumbers(speech);
    final compact = VoiceCommands.normalize(input);
    if (compact.length < 4) return null;
    final digits = RegExp(r'\d+').allMatches(input).map((m) => m[0]!).toList();
    final locale = language == 'en' ? 1 : language == 'nl' ? 2 : 0;
    var best = .72;
    String? suggestion;
    void consider(List<String> variants) {
      for (final phrase in variants) {
        final candidateDigits = RegExp(r'\d+').allMatches(phrase).map((m) => m[0]!).toList();
        // A correction must never silently change a page, verse or repeat count.
        if (digits.join(',') != candidateDigits.join(',')) continue;
        final candidate = VoiceCommands.normalize(phrase);
        final length = compact.length > candidate.length ? compact.length : candidate.length;
        if ((compact.length - candidate.length).abs() / length > 1 - best) continue;
        final score = 1 - _distance(compact, candidate) / length;
        if (score > best) { best = score; suggestion = variants[locale]; }
      }
    }
    for (final variants in _controls) { consider(variants); }
    for (final surah in surahs) {
      final tr = surah.name;
      final name = internationalSurahNames[surah.number - 1];
      for (final alias in {name, name.replaceFirst(RegExp(r'^(Al|An|Ar|As|Ash|At|Ad|Az)-'), ''), tr}) {
        consider(['$tr suresini aç', 'Open Surah $alias', 'Open soera $alias']);
        consider(['$tr suresini dinle', 'Play Surah $alias', 'Speel soera $alias']);
        consider(['$tr suresini oku', 'Read Surah $alias', 'Lees soera $alias']);
        if (digits.length == 1) {
          final n = int.tryParse(digits.first) ?? 0;
          if (n >= 1 && n <= verseCounts[surah.number - 1]) {
            consider(['$tr ayet $n aç', 'Open Surah $alias verse $n', 'Open soera $alias vers $n']);
            consider(['$tr $n’yi aç', 'Open Surah $alias verse $n', 'Open soera $alias vers $n']);
            consider(['$tr $n’yi dinle', 'Play Surah $alias verse $n', 'Speel soera $alias vers $n']);
          }
          if (n >= 1 && n <= 999) {
            consider(['$tr suresini $n kere oku', 'Play Surah $alias $n times', 'Speel soera $alias $n keer']);
            consider(['$tr suresini $n kere dinlet', 'Read Surah $alias $n times', 'Lees soera $alias $n keer']);
            consider(['$tr suresini $n kez seslendir', 'Repeat Surah $alias $n times', 'Herhaal soera $alias $n keer']);
          }
        }
        if (digits.length == 2) {
          final verse = int.tryParse(digits[0]) ?? 0;
          final repeats = int.tryParse(digits[1]) ?? 0;
          if (verse >= 1 && verse <= verseCounts[surah.number - 1] && repeats >= 1 && repeats <= 999) {
            consider(['$tr $verse’yi $repeats kere dinle', 'Play Surah $alias verse $verse $repeats times', 'Speel soera $alias vers $verse $repeats keer']);
          }
        }
      }
    }
    if (digits.length == 1) {
      final n = int.tryParse(digits.first) ?? 0;
      if (n >= 1 && n <= 604) consider(['$n sayfayı aç', 'Open page $n', 'Open pagina $n']);
      if (n >= 1 && n <= 30) consider(['$n cüze git', 'Open juz $n', 'Open djoez $n']);
      if (n >= 1 && n <= 999) {
        consider(['Bu sureyi $n kere tekrar et', 'Repeat this surah $n times', 'Herhaal deze soera $n keer']);
        consider(['Bu ayeti $n kere tekrar et', 'Repeat this verse $n times', 'Herhaal dit vers $n keer']);
      }
    }
    // Only show suggestions that the real command parser can handle.
    return suggestion != null && VoiceIntents.parse(suggestion!) != null ? suggestion : null;
  }

  static int _distance(String a, String b) {
    var previous = List.generate(b.length + 1, (i) => i);
    var beforePrevious = previous;
    for (var i = 1; i <= a.length; i++) {
      final row = List.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final deletion = previous[j] + 1;
        final insertion = row[j - 1] + 1;
        final substitution = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
        var value = deletion < insertion ? deletion : insertion;
        if (substitution < value) value = substitution;
        if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1] && beforePrevious[j - 2] + 1 < value) {
          value = beforePrevious[j - 2] + 1;
        }
        row[j] = value;
      }
      beforePrevious = previous;
      previous = row;
    }
    return previous.last;
  }
}
