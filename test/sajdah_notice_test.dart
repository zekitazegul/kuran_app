import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/data/sajdah_verses.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/widgets/sajdah_notice.dart';

void main() {
  test('prostration entries match the supplied printed index', () {
    expect(sajdahVerses.length, 14);
    expect(sajdahVerses[175], (7, 206));
    expect(sajdahVerses[597], (96, 19));
    expect(sajdahVerses[439], isNull);
  });
  testWidgets('notice waits three seconds, fades and resets on page change', (tester) async {
    AppLanguage.instance.value = const Locale('tr');
    Widget reader(int page) => MaterialApp(home: Scaffold(body:
      SajdahNotice(page: page, editionId: 'computer')));
    await tester.pumpWidget(reader(175));
    expect(find.textContaining('secde ayeti'), findsOneWidget);
    AnimatedOpacity opacity() => tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacity().opacity, 1);
    await tester.pump(const Duration(milliseconds: 2999));
    expect(opacity().opacity, 1);
    await tester.pump(const Duration(milliseconds: 1));
    expect(opacity().opacity, 0);
    expect(opacity().duration, const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(reader(176));
    expect(find.textContaining('secde ayeti'), findsNothing);
    await tester.pumpWidget(reader(175));
    expect(opacity().opacity, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
