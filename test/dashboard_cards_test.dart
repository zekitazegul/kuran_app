import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/dashboard_cards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    AppPreferences.instance.restore(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
  test('fresh install includes hatim and explicitly empty dashboard stays empty', () {
    expect(const UiPreferences().dashboardOrder, ['hatim', 'search', 'bookmarks', 'support', 'settings']);
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
        'search': Text('search card'), 'listen': Text('audio card'),
      })))));
    expect(find.text('audio card'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('dashboard-add'))); await tester.pumpAndSettle();
    await tester.tap(find.text("Kur'an dinle")); await tester.pumpAndSettle();
    expect(find.text('audio card'), findsOneWidget);
    expect(saved?['dashboardCards'], ['search', 'listen']);
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
