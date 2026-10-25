import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/verse_selection_overlay.dart';

void main() {
  for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
    for (final reverse in [false, true]) {
      testWidgets('drag selection is ordered across surahs $size reverse=$reverse', (tester) async {
        tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
        addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
        const verses=[VerseRegion(113,5,[Rect.fromLTRB(.1,.1,.9,.3)]),
          VerseRegion(114,1,[Rect.fromLTRB(.1,.4,.9,.6)]),
          VerseRegion(114,2,[Rect.fromLTRB(.1,.7,.9,.9)])];
        List<VerseRegion> current=[];List<VerseRegion>? result;
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(builder: (context, rebuild) => VerseSelectionOverlay(
          page:604,verses:verses.map((v) => VerseRegion(v.surah, v.verse, v.boxes)).toList(),imageSize:size,onChanged:(v)=>rebuild(() => current=v),
          onSelected:(v,_) async {result=v;})))));
        final first=tester.getCenter(find.byKey(ValueKey(reverse?'verse-604-114-2-0':'verse-604-113-5-0')));
        final last=tester.getCenter(find.byKey(ValueKey(reverse?'verse-604-113-5-0':'verse-604-114-2-0')));
        final gesture=await tester.startGesture(first);
        await tester.pump(const Duration(milliseconds:600));
        expect(current.length,1);expect(result,isNull);
        await gesture.moveTo(last);await tester.pump();
        expect(current.map((v)=>(v.surah,v.verse)),[(113,5),(114,1),(114,2)]);
        expect(result,isNull);
        await gesture.up();await tester.pump();
        expect(result,isNull);
        expect(current.length,3);
        final endHandle = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-end'))));
        await endHandle.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-604-114-1-0'))));
        await tester.pump();
        await endHandle.moveBy(const Offset(0, 1));await tester.pump();
        await endHandle.up();await tester.pump();
        expect(current.length,2);
        final extend = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-end'))));
        await extend.moveTo(last.dy > first.dy ? last : first);await tester.pump();
        await extend.moveBy(const Offset(0, 1));await tester.pump();
        await extend.up();await tester.pump();
        expect(current.length,3);
        final shrinkStart = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-start'))));
        await shrinkStart.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-604-114-1-0'))));await tester.pump();
        await shrinkStart.moveBy(const Offset(0, 1));await tester.pump();
        await shrinkStart.up();await tester.pump();
        expect(current.length,2);
        final extendStart = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-start'))));
        await extendStart.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-604-113-5-0'))));await tester.pump();
        await extendStart.moveBy(const Offset(0, 1));await tester.pump();
        await extendStart.up();await tester.pump();
        expect(current.length,3);
        await tester.tap(find.byKey(const ValueKey('selection-actions')));await tester.pump();
        expect(result!.map((v)=>(v.surah,v.verse)),[(113,5),(114,1),(114,2)]);
        expect(current,isEmpty);
      });
    }
  }
  testWidgets('selection can shrink and cancellation never opens actions', (tester) async {
    List<VerseRegion> current=[];var actions=0;
    const verses=[VerseRegion(114,1,[Rect.fromLTRB(0,0,1,.3)]),
      VerseRegion(114,2,[Rect.fromLTRB(0,.35,1,.65)]),VerseRegion(114,3,[Rect.fromLTRB(0,.7,1,1)])];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: VerseSelectionOverlay(page:604,
      verses:verses,imageSize:const Size(800,600),onChanged:(v)=>current=v,onSelected:(v,_) async {actions++;}))));
    final gesture=await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('verse-604-114-1-0'))));
    await tester.pump(const Duration(milliseconds:600));
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-604-114-3-0'))));await tester.pump();
    expect(current.length,3);
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('verse-604-114-2-0'))));await tester.pump();
    expect(current.length,2);
    await gesture.cancel();await tester.pump();expect(actions,0);expect(current,isEmpty);
  });
}
