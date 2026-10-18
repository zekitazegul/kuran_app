import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/home_pages.dart';
import 'package:kuran_app/widgets/personal_page_scope.dart';
import 'package:kuran_app/screens/listening_screen.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/l10n/translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    AppPreferences.instance.restore(null);
    AppNavigation.instance.fullscreenReader.value = null;
    AppNavigation.instance.fullscreenMeal.value = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, null);
  });

  testWidgets('starts on dashboard; swipe and add saves only personal page', (tester) async {
    Map<dynamic, dynamic>? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, (call) async {
      saved = (call.arguments as Map)['preferences'] as Map;
      return null;
    });
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['settings']);
    final controller = PageController(initialPage: 1);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
      controller: controller, dashboard: const Center(child: Text('dashboard content')),
      cards: const {'meal': Text('meal card'), 'settings': Text('settings card')},
    ))));
    expect(controller.page, 1);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(controller.page, 2);
    expect(find.text('meal card'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dashboard-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meal Oku'));
    await tester.pumpAndSettle();
    expect(find.text('meal card'), findsOneWidget);
    expect(AppPreferences.instance.value.dashboardOrder, ['settings']);
    expect(UiPreferences.fromMap(saved).personalCards, ['meal']);
    await tester.tap(find.byTooltip('Tanıtım ve destek'));
    await tester.pumpAndSettle();
    expect(controller.page, 0);
    expect(find.text('Destek'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('duplicate personal screens warn in every locale without saving or growing pages', (tester) async {
    final previousLanguage = AppLanguage.instance.value;
    addTearDown(() => AppLanguage.instance.value = previousLanguage);
    var writes = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (_) async { writes++; return null; });
    for (final language in ['tr', 'en', 'nl']) {
      for (final id in ['meal', 'hatim', 'search', 'history', 'surah:48']) {
        AppLanguage.instance.value = Locale(language);
        AppPreferences.instance.value = UiPreferences(customPages: [[id]]);
        final controller = PageController(initialPage: 3);
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
          controller: controller, dashboard: const Text('home'), cards: {id: Text('card $id')},
          features: {id: (_) => const Text('feature content')},
        ))));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('dashboard-add')));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add_circle_outline));
        await tester.pumpAndSettle();
        expect(find.text(translate('screenAlreadyAdded', language)), findsOneWidget);
        expect(AppPreferences.instance.value.personalPages, [[id]]);
        expect(controller.page, 3);
        expect(writes, 0);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      }
    }
  });

  test('old preferences start with an empty personal page', () {
    expect(UiPreferences.fromMap({'dashboardCards': ['meal'], 'dashboardVersion': 1}).personalCards, isEmpty);
    final prefs = const UiPreferences(personalCards: ['search']).copyWith(color: 'blue');
    expect(UiPreferences.fromMap(prefs.toMap()).personalCards, ['search']);
  });

  for (final id in ['meal', 'hatim', 'search', 'surah:48']) {
    testWidgets('$id reader owns swipes; full screen hides surrounding controls', (tester) async {
      AppPreferences.instance.value = UiPreferences(customPages: [[id]]);
      final home = PageController(initialPage: 2);
      final reader = PageController();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
        controller: home, dashboard: const Text('home'), cards: const {},
        features: {id: (context) => Column(children: [
          if (id == 'meal' && AppNavigation.instance.fullscreenMeal.value == null) PersonalPageScope.of(context)!.heading!,
          Expanded(child: PageView(controller: reader, children: const [Center(child: Text('page one')), Center(child: Text('page two'))])),
        ])},
      ))));
      await tester.pumpAndSettle();
      await tester.drag(find.text('page one'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(reader.page, 1);
      expect(home.page, 2);
      expect(find.byKey(const ValueKey('personal-page-handle-0')), findsOneWidget);
      final fullscreen = id == 'meal' ? AppNavigation.instance.fullscreenMeal : AppNavigation.instance.fullscreenReader;
      fullscreen.value = Object();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('personal-page-handle-0')), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(tester.getTopLeft(find.text('page two')).dy, greaterThanOrEqualTo(0));
      fullscreen.value = null;
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ana sayfa'));
      await tester.pumpAndSettle();
      expect(home.page, 1);
      await tester.pumpWidget(const SizedBox());
      home.dispose(); reader.dispose();
    });
  }

  testWidgets('bottom controls switch screens while reading swipes stay inside', (tester) async {
    AppPreferences.instance.value = const UiPreferences(customPages: [['meal'], ['search']]);
    final home = PageController(initialPage: 2);
    final reader = PageController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
      controller: home, dashboard: const Text('home'), cards: const {},
      features: {'meal': (_) => Column(children: [
        Expanded(child: PageView(controller: reader, children: const [Text('first slice'), Text('second slice')])),
        const PersonalPageSwipe(child: SizedBox(height: 60, width: double.infinity, child: Center(child: Text('bottom controls')))),
      ]), 'search': (_) => const PersonalPageSwipe(child: Center(child: Text('listening screen')))},
    ))));
    await tester.pumpAndSettle();
    await tester.drag(find.text('first slice'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(reader.page, 1);
    expect(home.page, 2);
    await tester.drag(find.text('bottom controls'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(home.page, 3);
    await tester.drag(find.text('listening screen'), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(home.page, 2);
    expect(reader.page, 1);
    await tester.pumpWidget(const SizedBox());
    home.dispose();
    reader.dispose();
  });

  test('legacy shortcut groups migrate to the single dashboard', () {
    final prefs = UiPreferences.fromMap({'personalPages': [['listen', 'meal']], 'dashboardVersion': 1});
    expect(prefs.personalPages, isEmpty);
    expect(prefs.dashboardOrder, contains('meal'));
    expect(prefs.dashboardOrder, isNot(contains('listen')));
    expect(UiPreferences.fromMap(prefs.toMap()).personalPages, isEmpty);
  });

  testWidgets('listening feature is directly usable inside a personal page', (tester) async {
    String? playing;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'playAudio') playing = 'shatri_surah_001';
        if (call.method == 'stopAudio') playing = null;
        return {'tracks': [{'id': 'shatri_surah_001', 'surah': 1, 'bytes': 1000}],
          'downloaded': ['shatri_surah_001'], 'playing': playing, 'reciter': 'shatri'};
      });
    AppPreferences.instance.value = const UiPreferences(personalCards: ['search']);
    final controller = PageController(initialPage: 2);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
      controller: controller, dashboard: const Text('home'), cards: const {'search': Text('shortcut card')},
      features: {'search': (_) => const ListeningScreen(embedded: true)},
    ))));
    await tester.pumpAndSettle();
    expect(find.text('shortcut card'), findsNothing);
    expect(find.text("SURELER"), findsOneWidget);
    AppNavigation.instance.fullscreenReader.value = Object();
    await tester.pumpAndSettle();
    expect(find.text("SURELER"), findsNothing);
    expect(find.byTooltip('Ana sayfa'), findsNothing);
    AppNavigation.instance.fullscreenReader.value = null;
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('listening-surah')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Dinle'));
    await tester.pumpAndSettle();
    expect(playing, 'shatri_surah_001');
    await tester.drag(find.text('Durdurma isteği ayet sonunda uygulanır.'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(controller.page, 1);
    expect(playing, 'shatri_surah_001');
    controller.jumpToPage(2);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Durdur'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    controller.dispose();
  });

  testWidgets('grows pages and deletes only the page dragged by its header', (tester) async {
    Map<dynamic, dynamic>? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ReadingStore.channel, (call) async {
      saved = (call.arguments as Map)['preferences'] as Map;
      return null;
    });
    AppPreferences.instance.value = const UiPreferences(customPages: [['meal'], ['search']], dashboardCards: ['settings']);
    final controller = PageController(initialPage: 1);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: HomePages(
      controller: controller, dashboard: const Text('dashboard content'),
      cards: const {'meal': Text('meal card'), 'search': Text('listen card')},
    ))));
    controller.jumpToPage(3);
    await tester.pumpAndSettle();
    expect(find.text('listen card'), findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('personal-page-handle-1'))));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('page-trash')), findsOneWidget);
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('page-trash'))));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.page, 1);
    expect(UiPreferences.fromMap(saved).personalPages, [['meal']]);
    expect(AppPreferences.instance.value.dashboardOrder, ['settings']);
    controller.jumpToPage(3);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dashboard-add')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('dashboard-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Sureler"));
    await tester.pumpAndSettle();
    expect(UiPreferences.fromMap(saved).personalPages, [['meal'], ['search']]);
    controller.jumpToPage(4);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('dashboard-add')), findsOneWidget);
    expect(find.text('listen card'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
