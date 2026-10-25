import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/required_update_gate.dart';

void main() {
  for (final language in ['tr', 'en', 'nl']) {
    testWidgets('mandatory update stays after cancellation in $language', (tester) async {
      AppLanguage.instance.value = Locale(language);
      const channel = MethodChannel('com.zekitazegul.kuranapp/update');
      var checks = 0, installs = 0, used = false;
      final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkUpdate') {
          checks++;
          expect((call.arguments as Map)['force'], true);
          return {'available': true, 'versionName': '1.2.0', 'releaseNotes': {language: 'notes-$language'}};
        }
        installs++;
        return 'cancelled';
      });
      addTearDown(() { messenger.setMockMethodCallHandler(channel, null); AppLanguage.instance.value = null; });
      await tester.pumpWidget(MaterialApp(home: RequiredUpdateGate(child:
        TextButton(onPressed: () => used = true, child: const Text('reader')))));
      await tester.pumpAndSettle();
      expect(checks, 1);
      expect(find.text('notes-$language'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(installs, 1);
      expect(find.text('1.2.0'), findsOneWidget);
      expect(used, false);
    });
  }
}
