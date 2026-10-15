import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  testWidgets('home back asks Exit; Cancel stays and only OK exits', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
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
      await tester.binding.handlePopRoute(); await tester.pumpAndSettle();
      expect(find.text('Exit?'), findsOneWidget); expect(exits, 0);
      await tester.tap(find.text('Cancel')); await tester.pumpAndSettle();
      expect(find.text('Exit?'), findsNothing); expect(exits, 0);
      await tester.binding.handlePopRoute(); await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); await tester.pumpAndSettle();
      expect(exits, 1);
      await tester.pumpWidget(const SizedBox());
    } finally {
      messenger.setMockMethodCallHandler(ReadingStore.channel, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    }
  });
}
