import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Geometry of a sheet held at [anchor] and pulled to [finger].
/// The crease bisects those points; reflecting the original anchor across it
/// puts it exactly under the finger. This is independent of animation timing.
class PageFold {
  final Offset midpoint;
  final Offset normal;
  PageFold(Offset anchor, Offset finger)
      : midpoint = (anchor + finger) / 2,
        normal = (finger - anchor) / math.max((finger - anchor).distance, 0.001);

  double distance(Offset point) => (point - midpoint).dx * normal.dx +
      (point - midpoint).dy * normal.dy;

  Offset reflect(Offset point) => point - normal * (2 * distance(point));

  List<Offset> clip(List<Offset> polygon, {required bool folded}) {
    final result = <Offset>[];
    for (var i = 0; i < polygon.length; i++) {
      final a = polygon[i], b = polygon[(i + 1) % polygon.length];
      final da = distance(a), db = distance(b);
      final aInside = folded ? da <= 0 : da >= 0;
      final bInside = folded ? db <= 0 : db >= 0;
      if (aInside) result.add(a);
      if (aInside != bInside) result.add(a + (b - a) * (da / (da - db)));
    }
    return result;
  }
}
