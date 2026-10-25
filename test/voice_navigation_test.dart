import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/data/surahs.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'support/reading_images.dart';

void main() {
  for(final language in ['tr','en','nl']) {
    for(final result in ['open','play','cancel','unrecognized','unavailable']) {
      testWidgets('voice command $result in $language preserves or opens the reading page', (tester) async {
        tester.view.physicalSize=const Size(360,640);tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        AppLanguage.instance.value=Locale(language);
        var lastPage=200;var listening=0; Map? playback; final downloads=<String>[];
        final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
          if(call.method=='load') {return {'directory':'/voice-test','lastPage':lastPage,'language':language,
            'downloaded':List.generate(605,(i)=>i),'bookmarks':[],'informationSeen':true,'guideSeen':true};}
          if(call.method=='loadAudio')return {'tracks':[for(var v=1;v<=3;v++) {'id':'36:$v','surah':36,'verse':v,'bytes':100}], 'downloaded':downloads,'playing':playback==null?null:'36:1'};
          if(call.method=='downloadAudio')downloads.add((call.arguments as Map)['id'] as String);
          if(call.method=='playAudioRange')playback=call.arguments as Map;
          if(call.method=='savePage')lastPage=(call.arguments as Map)['page'] as int;
          if(call.method=='recognizeVoice') {
            listening++;
            expect((call.arguments as Map)['language'],{'tr':'tr-TR','en':'en-US','nl':'nl-NL'}[language]);
            if(result=='unavailable')throw PlatformException(code:'VOICE_UNAVAILABLE');
            if(result=='play') return [{'tr':'Yasin suresini oku','en':'Read Surah Yasin','nl':'Lees soera Yasin'}[language]!];
            return result=='cancel'?<String>[]:result=='unrecognized'?['Yasin suresini açma']:
              ['unrelated recognition',{'tr':'Yasin suresini aç','en':'Open Surah Yaseen','nl':'Open soera Yasin'}[language]!];
          }
          return null;
        });
        addTearDown(() {messenger.setMockMethodCallHandler(ReadingStore.channel,null);AppPreferences.instance.restore(null);AppLanguage.instance.value=null;});
        cacheReadingImages('/voice-test',[200,surahs[35].startPage]);
        await tester.runAsync(() async {await VerseRegions.load();});
        await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
        expect(listening,0);
        await tester.tap(find.byKey(const ValueKey('home-voice')));await tester.pumpAndSettle();
        expect(listening,1);
        if(result=='open' || result=='play') {
          if(result=='play') {
            expect(playback, containsPair('surah',36));
            expect(playback, containsPair('first',1));
            expect(playback, containsPair('last',3));
            expect(playback, containsPair('repetitions',1));
            expect(downloads.length,3);
            expect(AppNavigation.instance.fullscreenReader.value,isNotNull);
          }
          expect(appNavigatorKey.currentState!.canPop(),true);
          expect(tester.widget<QuranScreen>(find.byType(QuranScreen)).initialPage,surahs[35].startPage);
          expect(lastPage,surahs[35].startPage);
          if (result=='open' && language=='tr') {
            final box=find.byKey(const ValueKey('verse-439-36-2-0'));
            await tester.longPress(box);await tester.pumpAndSettle();
            final scroll=find.descendant(of:find.byType(QuranScreen),matching:find.byType(SingleChildScrollView)).first;
            expect(tester.widget<SingleChildScrollView>(scroll).physics,isA<NeverScrollableScrollPhysics>());
            final handle=find.byKey(const ValueKey('selection-end'));
            await tester.dragFrom(tester.getCenter(handle),const Offset(0,60));await tester.pumpAndSettle();
            await tester.tap(find.byKey(const ValueKey('selection-actions')));await tester.pumpAndSettle();
            expect(find.textContaining('36:2 \u2013'),findsOneWidget);
            appNavigatorKey.currentState!.pop();await tester.pumpAndSettle();
          }

          AppNavigation.instance.open!(AppDestination.home);await tester.pumpAndSettle();
          expect(find.byType(QuranScreen),findsNothing);
          expect(find.textContaining('${surahs[35].startPage}'),findsOneWidget);
          expect(appNavigatorKey.currentState!.canPop(),false);
        } else {
          expect(lastPage,200);expect(appNavigatorKey.currentState!.canPop(),false);
          if(result!='cancel')expect(find.text(translate(result=='unrecognized'?'voiceNotUnderstood':'voiceUnavailable',language)),findsOneWidget);
        }
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox());await tester.pump();
      });
    }
  }
}
