import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/widgets/app_distribution.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';

void main() {
  const updates = MethodChannel('com.zekitazegul.kuranapp/update');
  const sharing = MethodChannel('com.zekitazegul.kuranapp/share');
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(updates, (_) async => {'available': false});
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(updates, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sharing, null);
  });
  testWidgets('Shows installed version from native update check', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(updates, (call) async {
          if (call.method == 'checkUpdate') {
            return {'available': false, 'installedVersionName': '1.0.39'};
          }
          expect(
            call.arguments['manifestUrl'],
            contains('kuran_app/releases/latest'),
          );
          return 'current:1.0.39';
        });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppDistribution())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Güncellemeler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1.0.39'), findsOneWidget);
  });
  testWidgets('Failed update can be retried', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          updates,
          (_) async => throw PlatformException(code: 'network'),
        );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppDistribution())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Güncellemeler'));
    await tester.pumpAndSettle();
    expect(find.text(translate('updateCheckError', 'tr')), findsOneWidget);
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, 'Güncellemeler'))
          .onTap,
      isNotNull,
    );
  });
  testWidgets('Sharing invokes Android APK chooser', (tester) async {
    var invoked = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sharing, (call) async {
          expect(call.method, 'shareInstaller');
          invoked = true;
          return null;
        });
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppDistribution())),
    );
    await tester.tap(find.text('Uygulamayı paylaş'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuran Installer’ı paylaş'));
    await tester.pumpAndSettle();
    expect(invoked, isTrue);
  });
  for (final language in ['tr', 'en', 'nl']) {
    for (final size in [
      const Size(360, 640),
      const Size(800, 360),
      const Size(1024, 1366),
    ]) {
      testWidgets('Distribution fits $language at $size with large text', (
        tester,
      ) async {
        AppLanguage.instance.value = Locale(language);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(() => AppLanguage.instance.value = const Locale('tr'));
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: const Scaffold(
                body: SingleChildScrollView(child: AppDistribution()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(translate('distributionCheck', language)),
          findsOneWidget,
        );
        await tester.tap(find.text(translate('distributionCheck', language)));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate('distributionShare', language)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
  test('All distribution text has Turkish, English and Dutch translations', () {
    for (final entry in translations.entries.where(
      (entry) =>
          entry.key.startsWith('distribution') ||
          entry.key.startsWith('update') ||
          entry.key == 'shareError',
    )) {
      for (final language in ['tr', 'en', 'nl']) {
        expect(
          entry.value[language],
          isNotEmpty,
          reason: '${entry.key}: $language',
        );
      }
    }
  });
  for (final language in ['tr', 'en', 'nl']) {
    testWidgets('New-version badge and localized notes $language', (
      tester,
    ) async {
      AppLanguage.instance.restore(language);
      addTearDown(() => AppLanguage.instance.restore('tr'));
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(updates, (call) async {
            calls.add(call.method);
            return {
              'available': true,
              'versionName': '9.0',
              'releaseNotes': {
                'tr': 'Yeni okuma seçenekleri.',
                'en': 'New reading options.',
                'nl': 'Nieuwe leesopties.',
              },
            };
          });
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: AppDistribution())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(translate('updateNewBadge', language)), findsOneWidget);
      await tester.tap(find.text(translate('distributionCheck', language)));
      await tester.pumpAndSettle();
      expect(
        find.text(
          {
            'tr': 'Yeni okuma seçenekleri.',
            'en': 'New reading options.',
            'nl': 'Nieuwe leesopties.',
          }[language]!,
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ListTile, translate('distributionCheck', language)),
        findsOneWidget,
      );
      expect(calls, ['checkUpdate', 'checkUpdate']);
      await tester.tap(find.text(translate('distributionCheck', language)));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(
          FilledButton,
          translate('distributionUpdate', language),
        ),
        findsNothing,
      );
      expect(calls.length, 2);
      await tester.tap(find.text(translate('distributionCheck', language)));
      await tester.pumpAndSettle();
      expect(calls, ['checkUpdate', 'checkUpdate', 'checkUpdate']);
      expect(
        find.widgetWithText(
          FilledButton,
          translate('distributionUpdate', language),
        ),
        findsOneWidget,
      );
    });
  }
}
