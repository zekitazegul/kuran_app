import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/services/voice_control.dart';
import 'package:kuran_app/widgets/voice_button.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'support/reading_images.dart';

void main() {
  for(final language in ['tr','en','nl']) {
    for(final size in [const Size(360,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
      testWidgets('whole surah repeats, pause, countdown, complete and bookmark $language $size',(tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        AppLanguage.instance.value=Locale(language);
        String speech={'tr':'Beyyine suresini 5 kere dinlet','en':'Play Surah Al-Bayyinah five times','nl':'Speel soera Al-Bayyinah vijf keer'}[language]!;
        String? playing;bool paused=false;int round=1,total=0,completed=0;Map? bookmarks;
        final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
          if(call.method=='load') {return {'directory':'/voice-controls','lastPage':200,'language':language,
            'downloaded':List.generate(605,(i)=>i),'bookmarks':[],'informationSeen':true,'guideSeen':true};}
          if(call.method=='recognizeVoice') {return [speech];}
          if(call.method=='loadAudio') {return {'tracks':[{'id':'chapter98','surah':98,'verse':null,'bytes':100}],
            'downloaded':['chapter98'],'playing':playing,'paused':paused,'currentSurah':playing==null?null:98,
            'currentVerse':playing==null?null:1,'repeatTotal':total,'repeatCurrent':round,
            'repeatRemaining':total-round,'repeatCompleted':completed};}
          if(call.method=='playAudio') {final args=call.arguments as Map;playing=args['id'];total=args['repetitions'];}
          if(call.method=='pauseAudio') {paused=true;}
          if(call.method=='resumeAudio') {paused=false;}
          if(call.method=='stopAudioImmediately') {playing=null;total=0;}
          if(call.method=='saveBookmarks') {bookmarks=call.arguments as Map;}
          return null;
        });
        addTearDown(() {messenger.setMockMethodCallHandler(ReadingStore.channel,null);AppPreferences.instance.restore(null);AppLanguage.instance.value=null;});
        cacheReadingImages('/voice-controls',[200,surahs[97].startPage]);
        await tester.runAsync(() async {await VerseRegions.load();});
        await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('home-voice')));await tester.pumpAndSettle();
        expect(playing,'chapter98');expect(total,5);
        expect(find.text(translate('voiceRepeatProgress',language,{'current':1,'total':5,'remaining':4})),findsOneWidget);
        Future<void> say(String tr,String en,String nl) async {
          speech={'tr':tr,'en':en,'nl':nl}[language]!;
          await tester.tap(find.byType(VoiceButton).first);await tester.pumpAndSettle();
        }
        await say('Duraklat','Pause','Pauseer');expect(paused,true);expect(round,1);
        await say('Devam et','Resume','Hervat');expect(paused,false);expect(total,5);
        round=2;await tester.pump(const Duration(seconds:2));await tester.pumpAndSettle();
        expect(find.text(translate('voiceRepeatProgress',language,{'current':2,'total':5,'remaining':3})),findsOneWidget);
        round=5;completed=5;playing=null;
        await tester.pump(const Duration(seconds:2));await tester.pumpAndSettle();
        expect(find.text(translate('voiceRepeatComplete',language,{'total':5})),findsOneWidget);
        await say('Bu sayfayı kaydet','Save this page','Sla deze pagina op');expect(bookmarks,isNotNull);
        await say('Gece modunu aç','Enable night mode','Zet nachtmodus aan');expect(AppPreferences.instance.value.themeMode,ThemeMode.dark);
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox());await tester.pump();
        expect(VoiceControl.listen,isNull);
      });
    }
  }
}
