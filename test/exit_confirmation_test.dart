import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  testWidgets('bottom arrow goes back one screen and only confirms exit at home', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var exits = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exits++;
      return null;
    });
    messenger.setMockMethodCallHandler(ReadingStore.channel, (_) async => {
      'directory': '/test', 'lastPage': 439, 'bookmarks': <int>[],
      'downloaded': List<int>.generate(605, (i) => i), 'informationSeen': true, 'guideSeen': true,
    });
    await tester.pumpWidget(const KuranApp()); await tester.pumpAndSettle();
    unawaited(appNavigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('first screen')))));
    await tester.pumpAndSettle();
    unawaited(appNavigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('second screen')))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-exit'))); await tester.pumpAndSettle();
    expect(find.text('first screen'), findsOneWidget);
    expect(find.text('second screen'), findsNothing);
    expect(find.text('Çıkış?'), findsNothing); expect(exits, 0);
    await tester.tap(find.byKey(const ValueKey('navigation-exit'))); await tester.pumpAndSettle();
    expect(find.text('first screen'), findsNothing);
    expect(find.text('Çıkış?'), findsNothing); expect(exits, 0);
    await tester.tap(find.byKey(const ValueKey('navigation-exit'))); await tester.pumpAndSettle();
    expect(find.text('Çıkış?'), findsOneWidget); expect(exits, 0);
    await tester.tap(find.text('İptal')); await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    messenger.setMockMethodCallHandler(ReadingStore.channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });
  for (final entry in const {
    'tr': ['Çıkış?', 'İptal', 'Tamam'],
    'en': ['Exit?', 'Cancel', 'OK'],
    'nl': ['Afsluiten?', 'Annuleren', 'OK'],
  }.entries) {
  testWidgets('localized exit confirmation in ${entry.key}', (tester) async {
    AppLanguage.instance.value = Locale(entry.key);
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    var exits = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exits++;
      return null;
    });
    messenger.setMockMethodCallHandler(ReadingStore.channel, (call) async => {
      'directory': '/test', 'lastPage': 439, 'bookmarks': <int>[],
      'downloaded': List<int>.generate(605, (i) => i),
      'informationSeen': true, 'guideSeen': true,
    });
    try {
      await tester.pumpWidget(const KuranApp()); await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('navigation-exit'))); await tester.pumpAndSettle();
      expect(find.text(entry.value[0]), findsOneWidget); expect(exits, 0);
      final dialog = tester.getRect(find.byKey(const ValueKey('exit-confirmation')));
      final navigation = tester.getRect(find.byKey(const ValueKey('navigation-exit')));
      expect(dialog.height, lessThan(100));
      expect(dialog.bottom, lessThan(navigation.top));
      expect(navigation.top - dialog.bottom, lessThan(40));
      await tester.tap(find.text(entry.value[1])); await tester.pumpAndSettle();
      expect(find.text(entry.value[0]), findsNothing); expect(exits, 0);
      await tester.binding.handlePopRoute(); await tester.pumpAndSettle();
      await tester.tap(find.text(entry.value[2])); await tester.pumpAndSettle();
      expect(exits, 1);
      await tester.pumpWidget(const SizedBox());
    } finally {
      messenger.setMockMethodCallHandler(ReadingStore.channel, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    }
  });
  }
}
