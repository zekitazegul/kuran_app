import 'package:flutter/material.dart';
import 'motif_surface.dart';

class BottomUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const BottomUpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final surface = MotifSurface(child: child);
    if (MediaQuery.disableAnimationsOf(context)) return surface;
    return SlideTransition(
      position: animation.drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.fastOutSlowIn))),
      child: surface,
    );
  }
}
