import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/widgets/voice_button.dart';
import 'package:kuran_app/widgets/home_menu.dart';
import 'package:kuran_app/services/voice_control.dart';

void main() {
  testWidgets('microphone tap listens and long press opens help instead of a tooltip',(tester) async {
    int help=0,listens=0;
    VoiceControl.help=()=>help++;
    VoiceControl.listen=()=>listens++;
    addTearDown(() {VoiceControl.help=null;VoiceControl.listen=null;});
    await tester.pumpWidget(MaterialApp(home:Scaffold(appBar:HomeHeader(onMenu:(){},onVoice:VoiceControl.listen),body:const VoiceButton())));
    await tester.longPress(find.byKey(const ValueKey('home-voice')));await tester.pumpAndSettle();
    expect(help,1);expect(listens,0);
    await tester.longPress(find.byType(VoiceButton));await tester.pumpAndSettle();
    expect(help,2);expect(listens,0);
    await tester.tap(find.byKey(const ValueKey('home-voice')));await tester.tap(find.byType(VoiceButton));
    expect(listens,2);
  });
}
