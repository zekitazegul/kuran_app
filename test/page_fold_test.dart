import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/widgets/page_fold.dart';

void main() {
  test('the grabbed sheet edge follows the finger at different heights', () {
    for (final height in [30.0, 250.0, 650.0]) {
      for (final dx in [20.0, 150.0, 390.0]) {
        final anchor = Offset(0, height);
        final finger = Offset(dx, height - 70);
        final fold = PageFold(anchor, finger);
        expect((fold.reflect(anchor) - finger).distance, lessThan(0.000001));
        final point = Offset(190, height + 20);
        expect((fold.reflect(fold.reflect(point)) - point).distance, lessThan(0.000001));
      }
    }
  });

  test('both reading directions preserve the correct half of the sheet', () {
    final corners = [const Offset(0, 0), const Offset(400, 0),
      const Offset(400, 700), const Offset(0, 700)];
    for (final anchor in [const Offset(0, 600), const Offset(400, 600)]) {
      final finger = anchor + Offset(anchor.dx == 0 ? 150 : -150, -50);
      final fold = PageFold(anchor, finger);
      final visible = fold.clip(corners, folded: false);
      final folded = fold.clip(corners, folded: true);
      expect(visible.length, greaterThanOrEqualTo(3));
      expect(folded.length, greaterThanOrEqualTo(3));
      for (final point in visible) { expect(fold.distance(point), greaterThanOrEqualTo(-0.000001)); }
      for (final point in folded) { expect(fold.distance(point), lessThanOrEqualTo(0.000001)); }
    }
  });
}
