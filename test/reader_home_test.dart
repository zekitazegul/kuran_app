import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/widgets/home_menu.dart';
import 'package:kuran_app/widgets/language_selector.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'support/reading_images.dart';

void main() {
  for (final language in ['tr','en','nl']) {
    for (final size in [const Size(360,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
      testWidgets('dashboard card and single-row menu $language $size', (tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        AppLanguage.instance.value=Locale(language);
        var lastPage=439;
        final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
          if(call.method=='load') {return {'directory':'/reader-home','lastPage':lastPage,'language':language,
            'downloaded':List.generate(605,(i)=>i),'bookmarks':[],'informationSeen':true,'guideSeen':true,
            'uiPreferences':{'dashboardVersion':1,'homeLayoutVersion':3,'dashboardCards':['history'],
              'shortcuts':[{'kind':'surah','number':48},{'kind':'juz','number':30}]}};}
          if(call.method=='savePage') {lastPage=(call.arguments as Map)['page'] as int;}
          if(call.method=='loadAudio')return {'tracks':[],'downloaded':[],'playing':null};
          return null;
        });
        addTearDown(() {messenger.setMockMethodCallHandler(ReadingStore.channel,null);AppPreferences.instance.restore(null);AppLanguage.instance.value=null;});
        cacheReadingImages('/reader-home',[439,440]);
        await tester.runAsync(() async {await VerseRegions.load();});
        await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
        expect(find.byType(QuranScreen),findsNothing);
        final header=find.byType(HomeHeader);
        final center=tester.getCenter(find.byKey(const ValueKey('home-menu'))).dy;
        expect(tester.getCenter(find.byKey(const ValueKey('home-voice'))).dy,closeTo(center,.01));
        expect(tester.getCenter(find.descendant(of:header,matching:find.text('KuranApp'))).dy,closeTo(center,.01));
        expect(tester.getCenter(find.byType(LanguageSelector)).dy,closeTo(center,.01));
        await tester.tap(find.byKey(const ValueKey('home-menu')));await tester.pumpAndSettle();
        final settings=find.byKey(const ValueKey('home-menu-settings'));
        final support=find.byKey(const ValueKey('home-menu-support'));
        expect(settings.hitTestable(),findsOneWidget);expect(support.hitTestable(),findsOneWidget);
        expect(tester.getCenter(settings).dy,lessThan(tester.getCenter(support).dy));
        final list=find.descendant(of:find.byType(HomeMenu),matching:find.byType(Scrollable)).first;
        await tester.scrollUntilVisible(find.byKey(const ValueKey('home-menu-juz:30')),150,scrollable:list);
        expect(find.byKey(const ValueKey('home-menu-surah:48')),findsOneWidget);
        tester.state<ScaffoldState>(find.byType(Scaffold).first).closeDrawer();await tester.pumpAndSettle();
        final resume=find.text(translate('Okumaya devam et',language));
        await tester.ensureVisible(resume);await tester.tap(resume);await tester.pumpAndSettle();
        AppNavigation.instance.exitFullscreen();await tester.pumpAndSettle();
        expect(find.text('439 / 604'),findsOneWidget);
        await tester.tap(find.byTooltip(translate('Sonraki sayfa',language)));await tester.pumpAndSettle();
        expect(lastPage,440);
        AppNavigation.instance.open!(AppDestination.home);await tester.pumpAndSettle();
        expect(find.byType(QuranScreen),findsNothing);
        expect(find.textContaining('440'),findsOneWidget);
        await tester.pumpWidget(const SizedBox());await tester.pump();
        await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
        expect(find.byType(QuranScreen),findsNothing);
        expect(find.textContaining('440'),findsOneWidget);
        expect(appNavigatorKey.currentState!.canPop(),false);
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox());await tester.pump();
      });
    }
  }
}
