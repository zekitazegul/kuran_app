import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'support/reading_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/screens/personalization_screen.dart';
import 'package:kuran_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('legacy personal page shortcuts migrate to home without duplicates', () {
    final prefs = UiPreferences.fromMap({'dashboardVersion': 1, 'dashboardCards': ['settings', 'meal'],
      'personalPages': [['listen'], ['meal'], ['hatim'], ['listen'], []]});
    expect(prefs.dashboardOrder, ['settings', 'meal', 'hatim']);
    expect(prefs.personalPages, isEmpty);
    expect(UiPreferences.fromMap(prefs.toMap()).dashboardOrder, prefs.dashboardOrder);
  });
  test('existing repeated screens keep only their first occurrence', () {
    const prefs = UiPreferences(customPages: [
      ['hatim'], ['bookmarks'], ['meal'], ['hatim'],
      ['bookmarks'], [], ['listen'], [],
    ]);
    final expected = [
      ['hatim'], ['bookmarks'], ['meal'], ['listen'], <String>[],
    ];
    expect(prefs.personalPages, expected);
    expect(UiPreferences.fromMap(prefs.toMap()).personalPages, [['hatim'],['bookmarks'],['meal'],<String>[]]);
  });
  Map<dynamic, dynamic>? saved;
  setUp(() {
    saved = null;
    AppLanguage.instance.value = const Locale('tr');
    AppPreferences.instance.restore(null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        expect(call.method, 'saveUiPreferences');
        saved = (call.arguments as Map)['preferences'] as Map;
        return null;
      });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, null);
    AppPreferences.instance.restore(null);
  });
  testWidgets('changing theme keeps settings open and updates the app theme', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async {
        if (call.method == 'load') {
          return {
          'directory': '/test', 'lastPage': 439, 'bookmarks': <int>[],
          'downloaded': List<int>.generate(605, (i) => i),
          'informationSeen': true, 'guideSeen': true, 'uiPreferences': saved,
          };
        }
        if (call.method == 'saveUiPreferences') {
          saved = (call.arguments as Map)['preferences'] as Map;
          return null;
        }
        throw StateError(call.method);
      });
    cacheReadingImages('/test', [439]);
    await tester.pumpWidget(const KuranApp());
    await tester.pumpAndSettle();
    AppNavigation.instance.exitFullscreen();await tester.pumpAndSettle();
    expect(find.text('Kütüphanem'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('home-menu'))); await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-menu-settings'))); await tester.pumpAndSettle();
    await tester.tap(find.text('Görünüm ve okuma')); await tester.pumpAndSettle();
    final appearance = find.widgetWithText(ListTile, 'Görünüm ve kısayollar');
    await tester.ensureVisible(appearance); await tester.pumpAndSettle();
    await tester.tap(appearance); await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Koyu'), 180,
      scrollable: find.byType(Scrollable).first); await tester.pumpAndSettle();
    await tester.tap(find.text('Koyu')); await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    expect(saved!['theme'], 'dark');
    expect(find.text('GÖRÜNÜM VE KISAYOLLAR'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('theme, color and mixed shortcuts survive serialization', () async {
    await AppPreferences.instance.save(const UiPreferences(themeMode: ThemeMode.dark, color: 'blue',
      shortcuts: [HomeShortcut(ShortcutKind.surah, 56), HomeShortcut(ShortcutKind.juz, 30)]));
    AppPreferences.instance.restore(saved);
    final restored = AppPreferences.instance.value;
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.color, 'blue');
    expect(restored.shortcuts.map((s) => s.id), ['surah:56', 'juz:30']);
    expect(restored.shortcuts.last.firstPage, 581);
    expect(const HomeShortcut(ShortcutKind.juz, 1).firstPage, 0);
  });
  test('invalid entries and duplicates are discarded; empty list stays empty', () {
    final prefs = UiPreferences.fromMap({'theme': 'unknown', 'color': 'unknown', 'shortcuts': [
      {'kind': 'surah', 'number': 56}, {'kind': 'surah', 'number': 56},
      {'kind': 'juz', 'number': 31}, {'kind': 'other', 'number': 2},
    ]});
    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.color, 'green');
    expect(prefs.shortcuts.map((s) => s.id), ['surah:56']);
    expect(UiPreferences.fromMap({'shortcuts': []}).shortcuts, isEmpty);
    expect(UiPreferences.fromMap(null).shortcuts.map((s) => s.id), ['surah:48', 'surah:36']);
  });
  testWidgets('user can add a surah shortcut by searching without accents', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PersonalizationScreen()));
    final add = find.widgetWithText(OutlinedButton, 'Kısayol ekle');
    await tester.scrollUntilVisible(add, 300);
    await tester.ensureVisible(add); await tester.pumpAndSettle();
    await tester.tap(add); await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Vakia');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('56.'));
    await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.shortcuts.last.id, 'surah:56');
    expect((saved!['shortcuts'] as List).last, {'kind': 'surah', 'number': 56});
    await tester.pumpWidget(const SizedBox());
  });
}
