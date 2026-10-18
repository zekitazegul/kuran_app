import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/reader_action_bar.dart';

void main() {
  for (final language in ['tr','en','nl']) {
    for (final size in [const Size(320,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
      testWidgets('labeled actions fit $language $size with large text', (tester) async {
        AppLanguage.instance.value = Locale(language);
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        final calls=<String>[];
        await tester.pumpWidget(MaterialApp(home: MediaQuery(
          data: MediaQueryData(size:size,textScaler:TextScaler.linear(1.8)),
          child: Scaffold(body: ReaderActionBar(loading:false,playing:false,stopping:false,
            onListen:()=>calls.add('listen'),onMeal:()=>calls.add('meal'))))));
        for (final key in ['reader-listen','reader-meal']) {
          final finder=find.byKey(ValueKey(key));
          expect(tester.getSize(finder).width,greaterThanOrEqualTo(48));
          expect(tester.getSize(finder).height,greaterThanOrEqualTo(48));
          await tester.tap(finder);
        }
        expect(calls,['listen','meal']);
        final left=tester.getTopLeft(find.byKey(const ValueKey('reader-listen'))).dx;
        final right=tester.getBottomRight(find.byKey(const ValueKey('reader-meal'))).dx;
        expect((left+right)/2,closeTo(size.width/2,.1));
        expect(find.byKey(const ValueKey('reader-reciter')),findsNothing);
        expect(find.text(translate('readerMealLabel',language)),findsOneWidget);
        expect(find.byIcon(Icons.menu_book_rounded),findsOneWidget);
        expect(tester.takeException(),isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
