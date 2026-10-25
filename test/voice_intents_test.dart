import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/voice_intents.dart';

void main() {
  test('all requested Turkish surah repeat verbs and spoken counts', () {
    for(final verb in ['oku','seslendir','dinlet','çal','tekrar et']) {
      for(final count in ['5','beş']) {
        final command=VoiceIntents.parse('Beyyine suresini $count kere $verb');
        expect(command?.action,VoiceAction.surah,reason:'$count $verb');
        expect(command?.number,98); expect(command?.repetitions,5);expect(command?.play,true);
      }
    }
    expect(VoiceIntents.parse('Bu sureyi 5 kere tekrar et')?.action,VoiceAction.repeatSurah);
    expect(VoiceIntents.parse('Bu ayeti 5 kez tekrarla')?.action,VoiceAction.repeatVerse);
    expect(VoiceIntents.parse('Play Surah Al-Bayyinah five times')?.repetitions,5);
    expect(VoiceIntents.parse('Speel soera Al-Bayyinah vijf keer')?.number,98);
    expect(VoiceIntents.parse('Repeat this surah 5 times')?.action,VoiceAction.repeatSurah);
    expect(VoiceIntents.parse('Herhaal dit vers vijf keer')?.action,VoiceAction.repeatVerse);
  });
  test('page juz and verse commands across three languages', () {
    for(final phrase in ['120. sayfayı aç','Open page one hundred twenty','Open pagina honderdtwintig']) {
      final c=VoiceIntents.parse(phrase);expect(c?.action,VoiceAction.page,reason:phrase);expect(c?.number,120);
    }
    for(final phrase in ['5. cüze git','Open juz five','Open djoez vijf']) {
      final c=VoiceIntents.parse(phrase);expect(c?.action,VoiceAction.juz,reason:phrase);expect(c?.number,5);
    }
    for(final phrase in ['Bakara 255’i aç','Open Surah Al-Baqarah verse 255','Open soera Al-Baqarah vers 255']) {
      final c=VoiceIntents.parse(phrase);expect(c?.action,VoiceAction.verse,reason:phrase);expect(c?.number,2);expect(c?.verse,255);expect(c?.play,false);
    }
    for(final phrase in ['Yasin 12’yi dinle','Play Surah Yasin verse 12','Speel soera Yasin vers 12']) {
      final c=VoiceIntents.parse(phrase);expect(c?.action,VoiceAction.verse,reason:phrase);expect(c?.number,36);expect(c?.verse,12);expect(c?.play,true);
    }
  });
  test('every control has equivalents in all locales', () {
    final phrases={
      VoiceAction.continueReading:['Kaldığım yerden devam et','Continue reading','Ga verder met lezen'],
      VoiceAction.pause:['Duraklat','Pause','Pauseer'],
      VoiceAction.resume:['Devam et','Resume','Hervat'],
      VoiceAction.stop:['Durdur','Stop','Stop'],
      VoiceAction.nextVerse:['Sonraki ayet','Next verse','Volgend vers'],
      VoiceAction.replay:['Tekrar dinlet','Play again','Speel opnieuw'],
      VoiceAction.showMeal:['Bu ayetin mealini göster','Show this verse translation','Toon de vertaling van dit vers'],
      VoiceAction.hideMeal:['Meali kapat','Close translation','Sluit vertaling'],
      VoiceAction.bookmark:['Bu sayfayı kaydet','Save this page','Sla deze pagina op'],
      VoiceAction.bookmarks:['Ayraçlarımı aç','Open bookmarks','Open bladwijzers'],
      VoiceAction.larger:['Yazıyı büyüt','Make text bigger','Maak tekst groter'],
      VoiceAction.smaller:['Yazıyı küçült','Make text smaller','Maak tekst kleiner'],
      VoiceAction.night:['Gece modunu aç','Enable night mode','Zet nachtmodus aan'],
      VoiceAction.day:['Gece modunu kapat','Disable night mode','Zet nachtmodus uit'],
      VoiceAction.fullscreen:['Tam ekran','Full screen','Volledig scherm'],
      VoiceAction.exitFullscreen:['Tam ekrandan çık','Exit full screen','Verlaat volledig scherm'],
      VoiceAction.help:['Hangi komutları söyleyebilirim','What can I say','Wat kan ik zeggen'],
    };
    for(final e in phrases.entries) {
      for(final p in e.value) {expect(VoiceIntents.parse(p)?.action,e.key,reason:p);}
    }
  });
  test('negated ambiguous and invalid commands never start playback', () {
    for(final p in ['Beyyine suresini 5 kere okuma','do not play Surah Yasin 5 times',
      'speel soera Yasin niet 5 keer','Beyyine suresini 0 kere oku','Beyyine suresini 1000 kere oku',
      'Open page 605','Open juz 31','Bakara 287 yi ac','Fatiha ve Yasin 5 kere oku',
      'Yasin suresini 5 kere ac','repeat this surah','5 times','play music']) {
      expect(VoiceIntents.parse(p),isNull,reason:p);
    }
  });
}
