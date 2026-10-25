import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/widgets/feature_demo.dart';
import 'package:kuran_app/widgets/app_bottom_bar.dart';
import 'package:kuran_app/services/app_language.dart';

void main() {
  testWidgets('existing users see only the new motif tutorial step',(tester) async {
    await tester.pumpWidget(const MaterialApp(home:FeatureDemo(initialStep:4)));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'),findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('demo-next')));await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-restart')));await tester.pumpAndSettle();
    expect(find.text('1 / 1'),findsOneWidget);
    expect(tester.takeException(),isNull);
  });

  for(final locale in ['tr','en','nl']) {
    for(final size in [const Size(360,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
      testWidgets('demo completes, replays and returns home $locale $size',(tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        AppLanguage.instance.value=Locale(locale);var home=0;
        final old=AppNavigation.instance.open;
        AppNavigation.instance.open=(destination) { expect(destination,AppDestination.home);home++; };
        addTearDown(()=>AppNavigation.instance.open=old);
        await tester.pumpWidget(MaterialApp(home:Builder(builder:(context)=>Scaffold(body:TextButton(
          onPressed:()=>showFeatureDemo(context),child:const Text('start'))))));
        await tester.tap(find.text('start'));await tester.pumpAndSettle();
        for(var i=0;i<5;i++) {
          expect(tester.getRect(find.byKey(const ValueKey('demo-next'))).bottom,lessThan(size.height));
          await tester.tap(find.byKey(const ValueKey('demo-next')));await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('demo-restart')));await tester.pumpAndSettle();
        expect(find.text('1 / 5'),findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('demo-skip')));
        await tester.tap(find.byKey(const ValueKey('demo-skip')));await tester.pumpAndSettle();
        expect(home,1);expect(find.byType(FeatureDemo),findsNothing);
        expect(tester.takeException(),isNull);
      });
    }
  }
}
