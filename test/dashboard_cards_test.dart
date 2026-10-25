import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/dashboard_cards.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    AppPreferences.instance.restore(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
  testWidgets('empty home shows add label until a card is added', (tester) async {
    AppPreferences.instance.value = const UiPreferences(dashboardCards: []);
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(controller: controller,
      child: DashboardCards(scrollController: controller, cards: const {'settings': Text('settings card')})))));
    expect(find.text('K\u0131sayol ekle'), findsOneWidget);
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['settings']);
    await tester.pump();
    expect(find.text('K\u0131sayol ekle'), findsNothing);
    expect(find.byKey(const ValueKey('dashboard-add')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets('home card dropped onto bottom bar persists once at the drop position and remains on home', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 0,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['meal'], bottomShortcuts: []);
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(bottomNavigationBar: const AppBottomBar(),
      body: SingleChildScrollView(controller: controller, child: DashboardCards(scrollController: controller,
        cards: const {'meal': SizedBox(height: 80, child: Text('meal card'))})))));
    for (var i = 0; i < 2; i++) {
      final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('dashboard-card-meal'))));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('navigation-add-target'))));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(AppPreferences.instance.value.bottomShortcuts, ['meal']);
      expect(UiPreferences.fromMap(AppPreferences.instance.value.toMap()).bottomShortcuts, ['meal']);
      expect(AppPreferences.instance.value.dashboardOrder, ['meal']);
    }
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['meal'], bottomShortcuts: ['home', 'exit']);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('dashboard-card-meal'))));
    await tester.pump(const Duration(milliseconds: 600));
    final bar = tester.getRect(find.byKey(const ValueKey('navigation-add-target')));
    final pointer = Offset(bar.left + bar.width / 2, bar.center.dy);
    await gesture.moveTo(pointer);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('dashboard-drag-icon')), findsOneWidget);
    expect(tester.getCenter(find.descendant(of: find.byKey(const ValueKey('dashboard-drag-icon')), matching: find.byType(Material)).first).dx, lessThan(pointer.dx));
    await gesture.up();
    await tester.pump();
    final arrival = find.byKey(const ValueKey('navigation-meal'));
    final initialX = tester.getCenter(arrival).dx;
    await tester.pump(const Duration(milliseconds: 190));
    expect(tester.getCenter(arrival).dx, greaterThan(initialX));
    await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.bottomShortcuts, ['home', 'meal', 'exit']);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    AppNavigation.instance.value = null;
  });
  test('fresh install includes hatim and explicitly empty dashboard stays empty', () {
    expect(const UiPreferences().dashboardOrder, ['hatim', 'history']);
    final empty = const UiPreferences().copyWith(dashboardCards: []);
    expect(UiPreferences.fromMap(empty.toMap()).dashboardOrder, isEmpty);
    final added = empty.copyWith(shortcuts: [...empty.shortcuts, const HomeShortcut(ShortcutKind.surah, 2)]);
    expect(added.dashboardOrder, ['surah:2']);
  });
  test('existing dashboard gains hatim once without changing other card order', () {
    final migrated = UiPreferences.fromMap({'dashboardCards': ['support', 'search']});
    expect(migrated.dashboardOrder, ['hatim', 'support', 'search']);
    final removed = migrated.copyWith(dashboardCards: ['support', 'search']);
    expect(UiPreferences.fromMap(removed.toMap()).dashboardOrder, ['support', 'search']);
  });
  testWidgets('plus restores a removed card and saves its position', (tester) async {
    Map? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      saved = (call.arguments as Map)['preferences'] as Map; return null;
    });
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['search']);
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(controller: controller,
      child: DashboardCards(scrollController: controller, cards: const {
        'search': Text('search card'), 'meal': Text('audio card'),
      })))));
    expect(find.text('audio card'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dashboard-add'))); await tester.pumpAndSettle();
    await tester.tap(find.text('Meal Oku')); await tester.pumpAndSettle();
    expect(find.text('audio card'), findsOneWidget);
    expect(saved?['dashboardCards'], ['search', 'meal']);
    await tester.pumpWidget(const SizedBox()); controller.dispose();
  });
  testWidgets('dragging Hatim saves order without opening a card', (tester) async {
    Map? saved;
    var opened = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      saved = (call.arguments as Map)['preferences'] as Map;
      return null;
    });
    AppPreferences.instance.value = const UiPreferences(dashboardCards: ['hatim', 'search', 'support']);
    final controller = ScrollController();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(controller: controller,
      child: DashboardCards(scrollController: controller, cards: {
        for (final id in ['hatim', 'search', 'support']) id: SizedBox(height: 80,
          child: ListTile(title: Text(id), onTap: () => opened++)),
      })))));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('dashboard-card-hatim'))));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('dashboard-card-support'))) + const Offset(0, 8));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.dashboardOrder, ['search', 'support', 'hatim']);
    expect(saved?['dashboardCards'], ['search', 'support', 'hatim']);
    expect(opened, 0);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
