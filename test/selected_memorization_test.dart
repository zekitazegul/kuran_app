import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/verse_actions.dart';

void main() {
  for(final locale in ['tr','en','nl']) {
    for(final size in [const Size(360,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
      for(final cross in [false,true]) {
        testWidgets('selected memorization defaults $locale $size cross=$cross',(tester) async {
          AppLanguage.instance.value=Locale(locale);
          tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
          addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
          final verses=cross ? const [VerseRegion(113,5,[]),VerseRegion(114,1,[])] :
            const [VerseRegion(114,2,[]),VerseRegion(114,3,[]),VerseRegion(114,4,[])];
          (int,int,int)? result;
          await tester.pumpWidget(MaterialApp(home:Builder(builder:(context)=>Scaffold(body:TextButton(
            onPressed:() async {result=await showMemorizeRange(context,verses.first,selection:verses);},child:const Text('open'))))));
          await tester.tap(find.text('open'));await tester.pumpAndSettle();
          expect(find.text(verseSelectionLabel(verses)),findsOneWidget);
          expect(tester.widgetList<TextFormField>(find.byType(TextFormField)).map((f)=>f.controller!.text),
            cross?['3']:['2','4','3']);
          await tester.enterText(find.byType(TextFormField).last,'2');
          await tester.tap(find.text(translate('verseRepeatStart',locale)));await tester.pumpAndSettle();
          expect(result,cross?(5,1,2):(2,4,2));expect(tester.takeException(),isNull);
        });
      }
    }
  }
}
