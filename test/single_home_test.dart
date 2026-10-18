import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/screens/quran_screen.dart';
import 'package:kuran_app/screens/meal_screen.dart';
import 'package:kuran_app/screens/personalization_screen.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/meal_reader.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';

void main() {
  testWidgets('obsolete listening shortcuts disappear and translation returns home', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      if (call.method == 'load') { return {'directory':'/single-home', 'lastPage':0, 'bookmarks':[],
        'downloaded':List.generate(605,(i)=>i), 'informationSeen':true, 'guideSeen':true,
        'uiPreferences':{'dashboardVersion':1, 'dashboardCards':[], 'personalPages':[['listen'],['meal']]}}; }
      if (call.method == 'loadAudio') { return {'tracks':[{'id':'page0','page':0,'surah':1,'bytes':100}], 'downloaded':[], 'playing':null}; }
      return null;
    });
    messenger.setMockMethodCallHandler(MealReader.channel, (call) async => call.method == 'load' || call.method == 'loadText' ? {} : null);
    await tester.runAsync(() async {
      for (final path in ['assets/page_verses.json','assets/meal/turkish-pages.json','assets/meal/index.json']) {
        await rootBundle.loadString(path);
      }
    });
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording(); final image = picture.toImageSync(2,2); picture.dispose();
    PaintingBinding.instance.imageCache.putIfAbsent(FileImage(File('/single-home/page000.png')),
      () => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image:image.clone()))));
    addTearDown(() {
      messenger.setMockMethodCallHandler(ReadingStore.channel,null);
      messenger.setMockMethodCallHandler(MealReader.channel,null);
      AppPreferences.instance.restore(null);
      PaintingBinding.instance.imageCache.clear(); PaintingBinding.instance.imageCache.clearLiveImages(); image.dispose();
    });
    await tester.pumpWidget(const KuranApp()); await tester.pumpAndSettle();
    expect(find.byType(PageView),findsNothing);
    expect(AppPreferences.instance.value.personalPages,isEmpty);
    for (var i=0;i<2;i++) {
      expect(find.byKey(const ValueKey('dashboard-card-listen')),findsNothing);
      await tester.tap(find.byKey(const ValueKey('dashboard-card-meal'))); await tester.pump(const Duration(milliseconds:500));
      await tester.runAsync(() async => Future<void>.delayed(const Duration(milliseconds:500)));
      await tester.pump(); await tester.pump(const Duration(milliseconds:500));
      expect(find.byType(MealScreen),findsOneWidget);
      expect(tester.widget<QuranScreen>(find.byType(QuranScreen,skipOffstage:false)).initialPanel,'meal');
      AppNavigation.instance.open!(AppDestination.home); await tester.pumpAndSettle();
      expect(appNavigatorKey.currentState!.canPop(),isFalse);
    }
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('translation can be added but standalone listening is absent from shortcuts', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    AppPreferences.instance.value = const UiPreferences(bottomShortcuts:[]);
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
    await tester.pumpWidget(const MaterialApp(home:PersonalizationScreen()));
    await tester.tap(find.widgetWithText(ActionChip,'Meal Oku')); await tester.pumpAndSettle();
    expect(find.widgetWithText(ActionChip,"Kur'an dinle"),findsNothing);
    expect(AppPreferences.instance.value.bottomShortcuts,['meal']);
    await tester.pumpWidget(const SizedBox());
    messenger.setMockMethodCallHandler(ReadingStore.channel,null); AppPreferences.instance.restore(null);
  });
}
