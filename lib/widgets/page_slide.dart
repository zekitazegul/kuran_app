import 'package:flutter/material.dart';

/// Both pages move by the same distance as the reader's finger.
class PageSlide extends StatelessWidget {
  final Animation<double> animation;
  final bool toRight;
  final Widget current;
  final Widget next;
  const PageSlide({super.key, required this.animation, required this.toRight,
    required this.current, required this.next});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) =>
    AnimatedBuilder(animation: animation, builder: (context, _) {
      final direction = toRight ? 1.0 : -1.0;
      final distance = animation.value * constraints.maxWidth * direction;
      return ClipRect(child: Stack(fit: StackFit.expand, children: [
        Transform.translate(offset: Offset(distance - constraints.maxWidth * direction, 0), child: next),
        Transform.translate(key: const ValueKey('sliding-current-page'),
          offset: Offset(distance, 0), child: current),
      ]));
    }));
}
