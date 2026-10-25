import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/home_menu.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';

void main() {
  for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
    testWidgets('menu icons match actions at $size', (tester) async {
      tester.view.physicalSize=size; tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      const expected={'home':Icons.home_outlined,'exit':Icons.arrow_back_rounded,'page':Icons.numbers_rounded,
        'search':Icons.search,'meal':Icons.menu_book_outlined,'hatim':Icons.auto_stories_outlined,
        'history':Icons.history,'bookmarks':Icons.bookmarks_outlined,'settings':Icons.settings_outlined,'support':Icons.support_agent};
      for (final entry in expected.entries) {
        await tester.pumpWidget(MaterialApp(home:Scaffold(body:HomeMenu(
          preferences:UiPreferences(menuCards:[entry.key]),shortcutName:(s)=>s.id,onSelected:(_) {}))));
        expect(find.descendant(of:find.byKey(ValueKey('home-menu-${entry.key}')),matching:find.byIcon(entry.value)),findsOneWidget);
        expect(tester.takeException(),isNull);
      }
      expect(expected.values.toSet().length,expected.length);
    });
  }

  test('first installation defaults and five-shortcut limit', () {
    final prefs=UiPreferences.fromMap(null);
    expect(prefs.bottomShortcuts,['surahs','home','exit']);
    expect(prefs.dashboardOrder,['hatim','history']);
    expect(prefs.copyWith(bottomShortcuts:['home','surahs','exit','meal','hatim','history']).bottomShortcuts.length,5);
    expect(UiPreferences.fromMap({'navigationVersion':2,'bottomShortcuts':['home','surahs','exit','meal','hatim','history']}).bottomShortcuts.length,5);
  });
  testWidgets('home and navigation plus buttons add independent shortcuts', (tester) async {
    tester.view.physicalSize=const Size(600,1000);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    AppLanguage.instance.value=const Locale('tr');
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
      if(call.method=='load') { return {'directory':'/shortcuts','lastPage':28,'language':'tr',
        'bookmarks':[],'downloaded':List.generate(605,(i)=>i),'informationSeen':true,'guideSeen':true}; }
      return null;
    });
    addTearDown(() {AppPreferences.instance.restore(null);messenger.setMockMethodCallHandler(ReadingStore.channel,null);});
    await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dashboard-card-hatim')),findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-card-history')),findsOneWidget);
    final home=tester.getCenter(find.byKey(const ValueKey('navigation-home')));
    expect(home.dx,closeTo(300,1));
    expect(find.byKey(const ValueKey('navigation-add')),findsNothing);
    await AppPreferences.instance.save(AppPreferences.instance.value.copyWith(bottomShortcuts:['home']));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-add')));await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-add')));await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('navigation-choice-hatim')),findsNothing);
    await tester.tap(find.byKey(const ValueKey('navigation-add')));await tester.pumpAndSettle();
    final sheet=tester.widget<Material>(find.descendant(of:find.byType(BottomSheet),matching:find.byType(Material)).first);
    expect(sheet.shape,isA<RoundedRectangleBorder>());
    expect(sheet.clipBehavior,Clip.antiAlias);
    await tester.tap(find.byKey(const ValueKey('navigation-choice-hatim')));await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.bottomShortcuts,contains('hatim'));
    expect(find.byKey(const ValueKey('navigation-add')),findsNothing);
    appNavigatorKey.currentState!.pop();await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('dashboard-add')));
    await tester.tap(find.byKey(const ValueKey('dashboard-add')));await tester.pumpAndSettle();
    // Pick the meal card without affecting navigation choices.
    await tester.tap(find.text('Meal Oku').last);await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.dashboardOrder,contains('meal'));
    expect(AppPreferences.instance.value.bottomShortcuts, isNot(contains('meal')));
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox());await tester.pump();
    AppNavigation.instance.value=null;
  });

  testWidgets('long press reorders menu without pin or drag icons', (tester) async {
    final preferences=AppPreferences.instance;
    preferences.restore({'dashboardCards':['hatim','search','history'], 'dashboardVersion':1,
      'bottomShortcuts':['home','exit'],'navigationVersion':2});
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    Map? saved;
    messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
      if(call.method=='saveUiPreferences') saved=(call.arguments as Map)['preferences'] as Map;
      return null;
    });
    addTearDown(() {preferences.restore(null);messenger.setMockMethodCallHandler(ReadingStore.channel,null);});
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ValueListenableBuilder<UiPreferences>(
      valueListenable: preferences, builder: (context,value,_) => HomeMenu(preferences:value,
        shortcutName:(s)=>s.id,onSelected:(_) {})))));
    expect(find.byIcon(Icons.push_pin),findsNothing);
    expect(find.byIcon(Icons.push_pin_outlined),findsNothing);
    expect(find.byIcon(Icons.drag_handle),findsNothing);
    final gesture=await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('home-menu-hatim'))));
    await tester.pump(const Duration(milliseconds:600));
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('home-menu-history'))));
    await tester.pump();await gesture.up();await tester.pumpAndSettle();
    expect(preferences.value.menuOrder.take(3),['search','history','hatim']);
    preferences.restore(saved);await tester.pumpAndSettle();
    expect(preferences.value.menuOrder.first,'search');
    expect(preferences.value.bottomShortcuts,['home','exit']);
    final homeCards=[...preferences.value.dashboardOrder];
    await tester.tap(find.byKey(const ValueKey('menu-add')));await tester.pumpAndSettle();
    if(find.byKey(const ValueKey('menu-new-custom')).evaluate().isNotEmpty) {
      await tester.tap(find.byKey(const ValueKey('menu-new-custom')));await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextField),'Fatiha');await tester.pumpAndSettle();
    await tester.tap(find.text('1. Fatiha'));await tester.pumpAndSettle();
    expect(preferences.value.shortcuts.any((s)=>s.id=='surah:1'),true);
    expect(preferences.value.menuOrder,contains('surah:1'));
    expect(preferences.value.dashboardOrder,homeCards);
    await preferences.save(preferences.value.copyWith(menuCards:preferences.value.menuOrder.where((id)=>id!='surah:1').toList()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('menu-add')));await tester.pumpAndSettle();
    await tester.tap(find.text('surah:1'));await tester.pumpAndSettle();
    expect(preferences.value.menuOrder,contains('surah:1'));
    expect(preferences.value.shortcuts.where((s)=>s.id=='surah:1').length,1);
    expect(tester.takeException(),isNull);
  });
}
