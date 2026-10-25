import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/main.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/services/reading_store.dart';
import 'package:kuran_app/services/shortcut_transfer.dart';

void main() {
  testWidgets('menu to bottom copies once; hovering menu opens and warns on duplicate', (tester) async {
    tester.view.physicalSize=const Size(600,1000);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    AppLanguage.instance.value=const Locale('tr');
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(ReadingStore.channel,(call) async {
      if(call.method=='load') { return {'directory':'/drag','lastPage':28,'language':'tr',
        'downloaded':List.generate(605,(i)=>i),'bookmarks':[],'informationSeen':true,'guideSeen':true}; }
      return null;
    });
    addTearDown(() {messenger.setMockMethodCallHandler(ReadingStore.channel,null);AppPreferences.instance.restore(null);});
    await tester.pumpWidget(const KuranApp());await tester.pumpAndSettle();
    Future<void> drag(Finder from,Offset target) async {
      final gesture=await tester.startGesture(tester.getCenter(from));
      await tester.pump(const Duration(milliseconds:600));
      await gesture.moveTo(target);await tester.pumpAndSettle();
      await gesture.moveBy(const Offset(1,0));await tester.pump();
      await gesture.up();await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('home-menu')));await tester.pumpAndSettle();
    await drag(find.byKey(const ValueKey('home-menu-hatim')),tester.getCenter(find.byKey(const ValueKey('home-menu-history'))));
    expect(AppPreferences.instance.value.menuOrder.first,'history');
    expect(tester.getCenter(find.byKey(const ValueKey('home-menu-history'))).dy,
      lessThan(tester.getCenter(find.byKey(const ValueKey('home-menu-hatim'))).dy));
    await drag(find.byKey(const ValueKey('home-menu-hatim')),tester.getCenter(find.byKey(const ValueKey('navigation-home'))));
    expect(AppPreferences.instance.value.bottomShortcuts,contains('hatim'));
    expect(AppPreferences.instance.value.menuOrder,contains('hatim'));
    await tester.tapAt(const Offset(590,400));await tester.pumpAndSettle();
    final menuPosition=tester.getCenter(find.byKey(const ValueKey('home-menu')));
    await drag(find.byKey(const ValueKey('navigation-hatim')),menuPosition);
    expect(find.byKey(const ValueKey('menu-drop')),findsOneWidget);
    expect(find.text('Bu k\u0131sayol burada zaten var.'),findsOneWidget);
    expect(AppPreferences.instance.value.menuOrder.where((s)=>s=='hatim').length,1);
    await tester.tapAt(const Offset(590,400));await tester.pumpAndSettle();
    await ShortcutTransfer.remove('menu','bookmarks');
    await ShortcutTransfer.put('bottom','bookmarks');await tester.pumpAndSettle();
    await drag(find.byKey(const ValueKey('navigation-bookmarks')),menuPosition);
    expect(AppPreferences.instance.value.menuOrder,contains('bookmarks'));
    expect(AppPreferences.instance.value.bottomShortcuts,contains('bookmarks'));
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox());await tester.pump();
  });
}
