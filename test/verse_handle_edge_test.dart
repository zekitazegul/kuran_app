import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/verse_regions.dart';
import 'package:kuran_app/widgets/verse_selection_overlay.dart';

void main() {
  for (final size in [const Size(360,640), const Size(800,360), const Size(800,1280), const Size(1280,800)]) {
    testWidgets('handles work along and outside verse boundaries $size', (tester) async {
      tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      const verses = [VerseRegion(98,1,[Rect.fromLTRB(.1,.1,.9,.3)]),
        VerseRegion(98,2,[Rect.fromLTRB(.1,.4,.9,.6)]), VerseRegion(98,3,[Rect.fromLTRB(.1,.7,.9,.9)])];
      List<VerseRegion> selected = [];
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: VerseSelectionOverlay(
        page: 598, verses: verses, imageSize: size, onChanged: (v) => selected = v, onSelected: (_, _) async {}))));
      final press = await tester.startGesture(Offset(size.width*.5,size.height*.2));
      await tester.pump(const Duration(milliseconds: 600));
      await press.moveTo(Offset(size.width*.5,size.height*.8)); await tester.pump();
      await press.up(); await tester.pump(); expect(selected.length,3);
      final start = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-start'))));
      await start.moveTo(Offset(size.width*.91,size.height*.5)); await tester.pump();
      await start.moveBy(const Offset(0,1)); await tester.pump(); await start.up();await tester.pump();
      expect(selected.map((v) => v.verse), [2,3]);
      final end = await tester.startGesture(tester.getCenter(find.byKey(const ValueKey('selection-end'))));
      await end.moveTo(Offset(size.width*.09,size.height*.5)); await tester.pump();
      await end.moveBy(const Offset(0,1)); await tester.pump(); await end.up();await tester.pump();
      expect(selected.map((v) => v.verse), [2]);
    });
  }
}
