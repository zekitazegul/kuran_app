import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/services/app_preferences.dart';

void main() {
  testWidgets('bottom swipe resolves navigation registered after the bar is built', (tester) async {
    AppNavigation.instance.switchPage = null;
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 439,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    await tester.pumpWidget(const MaterialApp(home: Scaffold(bottomNavigationBar: AnimatedAppBottomBar())));
    final switches = <int>[];
    AppNavigation.instance.switchPage = switches.add;
    await tester.drag(find.byType(AnimatedAppBottomBar), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(switches, [1]);
    await tester.drag(find.byType(AnimatedAppBottomBar), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(switches, [1, -1]);
    await tester.pumpWidget(const SizedBox());
    AppNavigation.instance.switchPage = null;
    AppNavigation.instance.value = null;
  });

  testWidgets('long pressing and dropping on trash removes and persists shortcut', (tester) async {
    final previous = AppPreferences.instance.value;
    AppPreferences.instance.value = const UiPreferences(bottomShortcuts: ['home', 'hatim', 'history']);
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 0,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(bottomNavigationBar: AppBottomBar())));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('navigation-hatim'))));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('navigation-trash')), findsOneWidget);
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('navigation-trash'))));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.bottomShortcuts, ['home', 'history']);
    expect(find.byKey(const ValueKey('navigation-hatim')), findsNothing);
    expect(find.byKey(const ValueKey('navigation-trash')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    AppPreferences.instance.value = previous;
    AppNavigation.instance.value = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
  testWidgets('long press dragging Home to the right saves the order', (tester) async {
    final previous = AppPreferences.instance.value;
    AppPreferences.instance.value = const UiPreferences(bottomShortcuts: ['home', 'history', 'settings']);
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 0,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    Map? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, (call) async {
      saved = (call.arguments as Map)['preferences'] as Map;
      return null;
    });
    await tester.pumpWidget(const MaterialApp(home: Scaffold(bottomNavigationBar: AppBottomBar())));
    final start = tester.getCenter(find.byKey(const ValueKey('navigation-home')));
    final end = tester.getCenter(find.byKey(const ValueKey('navigation-settings')));
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(end + const Offset(130, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.bottomShortcuts, ['history', 'settings', 'home']);
    expect(saved!['bottomShortcuts'], ['history', 'settings', 'home']);
    await tester.pumpWidget(const SizedBox());
    AppPreferences.instance.value = previous;
    AppNavigation.instance.value = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(ReadingStore.channel, null);
  });
  testWidgets('removed Hatim stays hidden and active destination has a persistent highlight', (tester) async {
    final previousPreferences = AppPreferences.instance.value;
    AppPreferences.instance.value = const UiPreferences(bottomShortcuts: ['home', 'history']);
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 0,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    AppNavigation.instance.selected.value = AppDestination.home;
    AppNavigation.instance.open = (destination) => AppNavigation.instance.selected.value = destination;
    await tester.pumpWidget(const MaterialApp(home: Scaffold(bottomNavigationBar: AppBottomBar())));
    expect(find.byKey(const ValueKey('navigation-hatim')), findsNothing);
    Color? highlight(String id) => (tester.widget<AnimatedContainer>(
      find.byKey(ValueKey('navigation-$id'))).decoration as BoxDecoration).color;
    expect(highlight('home'), isNot(Colors.transparent));
    await tester.tap(find.byKey(const ValueKey('navigation-history')));
    await tester.pumpAndSettle();
    expect(highlight('history'), isNot(Colors.transparent));
    expect(highlight('home'), Colors.transparent);
    await tester.tap(find.byKey(const ValueKey('navigation-home')));
    await tester.pumpAndSettle();
    expect(highlight('home'), isNot(Colors.transparent));
    expect(highlight('history'), Colors.transparent);
    await tester.pumpWidget(const SizedBox());
    AppPreferences.instance.value = previousPreferences;
    AppNavigation.instance.open = null;
    AppNavigation.instance.value = null;
  });
  testWidgets('landscape fullscreen fades and slides the bar away, portrait restores it', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AppNavigation.instance.value = ReadingStore(directory: '/test', lastPage: 439,
      informationSeen: true, guideSeen: true, bookmarks: {}, downloaded: {});
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Column(children: [
      Expanded(child: SizedBox()), AnimatedAppBottomBar(),
    ]))));
    await tester.pumpAndSettle();
    final bar = find.byType(AnimatedAppBottomBar);
    final height = tester.getSize(bar).height;
    expect(height, greaterThan(0));
    AppNavigation.instance.fullscreenReader.value = Object();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    final fade = tester.widget<Opacity>(find.descendant(of: bar, matching: find.byType(Opacity)).first);
    expect(fade.opacity, inExclusiveRange(0, 1));
    expect(tester.getSize(bar).height, lessThan(height));
    final slide = tester.widget<FractionalTranslation>(find.descendant(of: bar, matching: find.byType(FractionalTranslation)));
    expect(slide.translation.dy, greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, 0);
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, greaterThan(0));
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    AppNavigation.instance.fullscreenReader.value = null;
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).height, height);
    await tester.pumpWidget(const SizedBox());
    AppNavigation.instance.value = null;
  });
}
