import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/screens/personalization_screen.dart';
import 'package:kuran_app/widgets/motif_surface.dart';
import 'package:kuran_app/widgets/motif_picker.dart';

void main() {
  for(final size in [const Size(360,640),const Size(800,360),const Size(800,1280),const Size(1280,800)]) {
    testWidgets('motif gallery chooses a city without overflow $size',(tester) async {
      tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      String? selected;
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:MotifPicker(menu:false,onSelected:(v)=>selected=v))));
      final tile=find.byKey(const ValueKey('motif-background-sand'));
      await tester.scrollUntilVisible(tile,180,scrollable:find.byType(Scrollable));await tester.pumpAndSettle();
      await tester.tap(tile);await tester.pumpAndSettle();
      expect(selected,'sand');expect(tester.takeException(),isNull);
    });
  }

  test('motif settings persist and invalid values use safe defaults', () {
    final selected=const UiPreferences().copyWith(backgroundMotif:'sage',menuMotif:'white',motifStrength:.15);
    final restored=UiPreferences.fromMap(selected.toMap());
    expect(restored.backgroundMotif,'sage');expect(restored.menuMotif,'white');expect(restored.motifStrength,.15);
    final invalid=UiPreferences.fromMap({'backgroundMotif':'missing','menuMotif':'invalid','motifStrength':9});
    expect(UiPreferences.fromMap({'motifStrength':.07}).motifStrength,.18);
    expect(UiPreferences.fromMap({'motifStyleVersion':2,'motifStrength':.07}).motifStrength,.07);
    expect(invalid.backgroundMotif,'cream');expect(invalid.menuMotif,'white');expect(invalid.motifStrength,.4);
  });
  testWidgets('background and popup motifs change independently',(tester) async {
    tester.view.physicalSize=const Size(600,1000);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel,(_) async=>null);
    AppPreferences.instance.restore(null);
    addTearDown(() {AppPreferences.instance.restore(null);messenger.setMockMethodCallHandler(ReadingStore.channel,null);});
    await tester.pumpWidget(const MaterialApp(home:PersonalizationScreen()));
    final backgroundPicker=find.byKey(const ValueKey('motif-picker-background'));
    await tester.scrollUntilVisible(backgroundPicker,250,scrollable:find.byType(Scrollable).first);
    await tester.pumpAndSettle();await tester.tap(backgroundPicker);await tester.pumpAndSettle();
    final background=find.byKey(const ValueKey('motif-background-sage'));
    await tester.scrollUntilVisible(background,180,scrollable:find.byType(Scrollable).last);await tester.pumpAndSettle();await tester.tap(background);await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.backgroundMotif,'sage');
    expect(AppPreferences.instance.value.menuMotif,'white');
    final menuPicker=find.byKey(const ValueKey('motif-picker-menu'));
    await tester.ensureVisible(menuPicker);await tester.tap(menuPicker);await tester.pumpAndSettle();
    final menu=find.byKey(const ValueKey('motif-menu-white'));
    await tester.scrollUntilVisible(menu,180,scrollable:find.byType(Scrollable).last);await tester.tap(menu);await tester.pumpAndSettle();
    expect(AppPreferences.instance.value.menuMotif,'white');
    expect(AppPreferences.instance.value.backgroundMotif,'sage');
    for(final motif in UiPreferences.motifs) {
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:MotifSurface(pattern:motif))));
      expect(tester.takeException(),isNull);
    }
  });
}
