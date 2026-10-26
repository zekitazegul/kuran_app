import '../data/verse_counts.dart';
import 'voice_commands.dart';

enum VoiceAction { surah, verse, page, juz, continueReading, pause, resume, stop,
  nextVerse, replay, showMeal, hideMeal, bookmark, bookmarks, larger, smaller,
  night, day, fullscreen, exitFullscreen, repeatVerse, repeatSurah, help }

class VoiceCommand {
  final VoiceAction action;
  final int? number;
  final int? verse;
  final bool play;
  final int repetitions;
  const VoiceCommand(this.action, {this.number, this.verse, this.play = false, this.repetitions = 1});
}

class VoiceIntents {
  static String normalizeNumbers(String speech) => _numbers(speech);
  static final _simple = <VoiceAction, List<String>>{
    VoiceAction.continueReading: ['kaldigimyerden devam et','son okudugumu ac','continue reading','resume reading','open last read','ga verder met lezen','open laatst gelezen'],
    VoiceAction.pause: ['duraklat','pause','pauseer'],
    VoiceAction.resume: ['devam et','resume','continue','ga verder','hervat'],
    VoiceAction.stop: ['durdur','sesi durdur','stop','stop playback','stop afspelen'],
    VoiceAction.nextVerse: ['sonraki ayet','next verse','volgend vers','volgende aya'],
    VoiceAction.replay: ['tekrar dinlet','tekrar dinle','yeniden cal','replay','play again','speel opnieuw'],
    VoiceAction.showMeal: ['bu ayetin mealini goster','meali goster','meali ac','meal ac','show translation','show this verse translation','toon vertaling','toon de vertaling van dit vers'],
    VoiceAction.hideMeal: ['meali kapat','meal kapat','close translation','hide translation','sluit vertaling','verberg vertaling'],
    VoiceAction.bookmark: ['bu sayfayi kaydet','ayrac ekle','bookmark this page','save this page','sla deze pagina op','voeg bladwijzer toe'],
    VoiceAction.bookmarks: ['ayraclarimi ac','open bookmarks','open mijn bladwijzers','open bladwijzers'],
    VoiceAction.larger: ['yaziyi buyut','increase font size','make text bigger','vergroot tekst','maak tekst groter'],
    VoiceAction.smaller: ['yaziyi kucult','decrease font size','make text smaller','verklein tekst','maak tekst kleiner'],
    VoiceAction.night: ['gece modunu ac','enable night mode','night mode','zet nachtmodus aan','nachtmodus'],
    VoiceAction.day: ['gece modunu kapat','gunduz modunu ac','disable night mode','day mode','zet nachtmodus uit','dagmodus'],
    VoiceAction.fullscreen: ['tam ekran','tam ekrani ac','fullscreen','full screen','volledig scherm'],
    VoiceAction.exitFullscreen: ['tam ekrandan cik','exit fullscreen','exit full screen','verlaat volledig scherm'],
    VoiceAction.help: ['hangi komutlari soyleyebilirim','sesli komutlar','yardim','what can i say','voice commands','help','wat kan ik zeggen','spraakopdrachten','hulp'],
  };

  static VoiceCommand? parse(String speech) {
    var text = _numbers(speech);
    var compact = VoiceCommands.normalize(text);
    for (final entry in _simple.entries) {
      if (entry.value.any((v) => VoiceCommands.normalize(v) == compact)) return VoiceCommand(entry.key);
    }
    // Only complete, positive commands match. Unrecognized speech has no effects.
    var repeats = 1;
    final repetition = RegExp(r'\b(\d+)\s*(?:kere|kez|defa|times|keer)\b').firstMatch(text);
    if (repetition != null) {
      repeats = int.parse(repetition[1]!);
      if (repeats < 1 || repeats > 999) return null;
      text = text.replaceRange(repetition.start, repetition.end, '').trim();
      compact = VoiceCommands.normalize(text);
      const currentSurah = ['bu sureyi tekrarla','bu sureyi tekrar et','bu sureyi oku','bu sureyi seslendir','bu sureyi dinlet','bu sureyi cal','repeat this surah','play this surah','repeat this chapter','herhaal deze soera','speel deze soera'];
      const currentVerse = ['bu ayeti tekrarla','bu ayeti tekrar et','bu ayeti oku','bu ayeti dinlet','repeat this verse','play this verse','herhaal dit vers','speel dit vers'];
      if (currentSurah.any((v) => VoiceCommands.normalize(v) == compact)) return VoiceCommand(VoiceAction.repeatSurah, play:true, repetitions:repeats);
      if (currentVerse.any((v) => VoiceCommands.normalize(v) == compact)) return VoiceCommand(VoiceAction.repeatVerse, play:true, repetitions:repeats);
    }
    for (final entry in <VoiceAction, List<RegExp>>{
      VoiceAction.page: [RegExp(r'^(?:sayfa|page|pagina)(\d+)(?:ac|yagit)?$'), RegExp(r'^(\d+)(?:sayfayiac|sayfaya git|sayfaya git|sayfaac|sayfayagit)$'), RegExp(r'^(?:open|goto|ganaar)(?:page|pagina)(\d+)$')],
      VoiceAction.juz: [RegExp(r'^(?:cuz|juz|djoez)(\d+)(?:ac|egit)?$'), RegExp(r'^(\d+)(?:cuze git|cuzegit|cuzuac|cuzac)$'), RegExp(r'^(?:open|goto|ganaar)(?:juz|cuz|djoez)(\d+)$')],
    }.entries) {
      for (final pattern in entry.value) {
        final match = pattern.firstMatch(compact);
        if (match != null && repetition == null) {
          final n = int.parse(match[1]!);
          if (n < 1 || n > (entry.key == VoiceAction.juz ? 30 : 604)) return null;
          return VoiceCommand(entry.key, number:n);
        }
      }
    }
    // Named surah + verse, or explicit chapter/verse numbers.
    final versePatterns = [
      RegExp(r'^(?:open|play|read|listento|speel|lees|open)?(?:surah|soera|sure)?(.+?)(?:verse|vers|ayet|ayeti|ayetini)(\d+)(?:ac|iac|yiac|dinle|dinlet|oku|seslendir|cal)?$'),
      RegExp(r'^(.+?)(\d+)(?:i|yi)?(?:ac|dinle|dinlet|oku|seslendir|cal)$'),
    ];
    for (final pattern in versePatterns) {
      final m = pattern.firstMatch(compact);
      if (m == null) continue;
      final n = VoiceCommands.surah(m[1]!);
      final v = int.parse(m[2]!);
      if (n != null && v >= 1 && v <= verseCounts[n-1]) {
        final play = repeats > 1 || RegExp(r'^(?:play|read|listento|speel|lees)|(?:dinle|dinlet|oku|seslendir|cal)$').hasMatch(compact);
        return VoiceCommand(VoiceAction.verse,number:n,verse:v,play:play,repetitions:repeats);
      }
    }
    var target = compact;
    var play = false;
    final prefix = RegExp(r'^(?:play|recite|read|listento|speel|lees|reciteer|repeat|herhaal)').firstMatch(target);
    final suffix = RegExp(r'(?:suresinioku|suresiniseslendir|suresinidinlet|suresinidinle|suresinical|suresinitekraret|oku|seslendir|dinlet|dinle|cal|tekraret)$').firstMatch(target);
    if (prefix != null) { target = target.substring(prefix.end); play=true; }
    else if (suffix != null) { target=target.substring(0,suffix.start); play=true; }
    if (repetition != null && !play) return null;
    final surah = VoiceCommands.surah(target);
    if (surah != null) return VoiceCommand(VoiceAction.surah,number:surah,play:play,repetitions:repeats);
    return null;
  }

  static String _numbers(String text) {
    text = text.toLowerCase().replaceAll('ı','i').replaceAll('ş','s').replaceAll('ç','c').replaceAll('ğ','g').replaceAll('ü','u').replaceAll('ö','o').replaceAll('â','a').replaceAll('î','i');
    text=text.replaceAll(RegExp("[’']"),' ').replaceAll(RegExp(r'[.,?!:]'),' ');
    // Speech engines usually return digits; also accept spoken cardinal numbers.
    final names=<String,int>{};
    const trUnits=['','bir','iki','uc','dort','bes','alti','yedi','sekiz','dokuz'];
    const trTens=['','on','yirmi','otuz','kirk','elli','altmis','yetmis','seksen','doksan'];
    const enUnits=['','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen'];
    const enTens=['','','twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety'];
    const nlUnits=['','een','twee','drie','vier','vijf','zes','zeven','acht','negen','tien','elf','twaalf','dertien','veertien','vijftien','zestien','zeventien','achttien','negentien'];
    const nlTens=['','','twintig','dertig','veertig','vijftig','zestig','zeventig','tachtig','negentig'];
    for(var n=1;n<=999;n++) {
      final h=n~/100,r=n%100;
      final tr=[if(h>0) '${h==1?'':'${trUnits[h]} '}yuz',if(r>=10)trTens[r~/10],if(r%10>0)trUnits[r%10]].join(' ');
      final en=[if(h>0)'${enUnits[h]} hundred',if(r>0) r<20?enUnits[r]:[enTens[r~/10],if(r%10>0)enUnits[r%10]].join(' ')].join(' ');
      final nl='${h>0?'${h==1?'':nlUnits[h]}honderd':''}${r==0?'':r<20?nlUnits[r]:'${r%10==0?'':'${nlUnits[r%10]}en'}${nlTens[r~/10]}'}';
      names[tr]=n;names[en]=n;names[nl]=n;
    }
    final pattern=RegExp('\\b(?:${(names.keys.toList()..sort((a,b)=>b.length.compareTo(a.length))).map(RegExp.escape).join('|')})\\b');
    return text.replaceAllMapped(pattern,(m)=>'${names[m[0]]}').replaceAll(RegExp(r'\s+'),' ').trim();
  }
}
