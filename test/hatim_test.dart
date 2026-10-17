import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/reading_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ReadingStore store;
  setUp(() {
    store = ReadingStore(directory: '', lastPage: 0, informationSeen: true,
      bookmarks: {}, downloaded: {});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (_) async => null);
  });
  test('skips marked pages and wraps to remaining pages', () async {
    await store.saveHatim([0, 1, 3]);
    expect(store.nextHatimPage(), 2);
    expect(store.nextHatimPage(604), 2);
    await store.saveHatim([2], resume: 4);
    expect(store.hatimResume, 4);
    expect(store.nextHatimPage(3), 4);
  });
  test('completion requires every page and can be undone', () async {
    await store.saveHatim(List.generate(605, (i) => i));
    expect(store.hatimComplete, isTrue);
    expect(store.nextHatimPage(), isNull);
    await store.saveHatim([120], read: false);
    expect(store.hatimComplete, isFalse);
    expect(store.nextHatimPage(), 120);
  });
  test('failed persistence preserves previous progress', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (_) async => throw PlatformException(code: 'disk'));
    await expectLater(store.saveHatim([0], resume: 1), throwsA(isA<PlatformException>()));
    expect(store.hatimPages, isEmpty);
    expect(store.hatimResume, isNull);
  });
  test('page effect saves only after persistence succeeds', () async {
    MethodCall? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (call) async { saved = call; return null; });
    await store.setPageEffect('curl');
    expect(saved!.method, 'setPageEffect');
    expect((saved!.arguments as Map)['effect'], 'curl');
    expect(store.pageEffect, 'curl');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ReadingStore.channel, (_) async => throw PlatformException(code: 'disk'));
    await expectLater(store.setPageEffect('slide'), throwsA(isA<PlatformException>()));
    expect(store.pageEffect, 'curl');
  });
}
