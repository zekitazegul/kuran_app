import 'package:flutter/material.dart';

class PersonalPageScope extends InheritedWidget {
  final void Function(int delta) navigate;
  final Widget? heading;
  final ValueNotifier<String?>? readerTitle;
  const PersonalPageScope({super.key, required this.navigate, this.heading, this.readerTitle, required super.child});
  static PersonalPageScope? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<PersonalPageScope>();
  @override
  bool updateShouldNotify(PersonalPageScope oldWidget) => navigate != oldWidget.navigate || heading != oldWidget.heading;
}

class PersonalPageSwipe extends StatefulWidget {
  final Widget child;
  final void Function(int delta)? onNavigate;
  const PersonalPageSwipe({super.key, required this.child, this.onNavigate});
  @override
  State<PersonalPageSwipe> createState() => _PersonalPageSwipeState();
}

class _PersonalPageSwipeState extends State<PersonalPageSwipe> {
  double _distance = 0;
  @override
  Widget build(BuildContext context) {
    final scope = PersonalPageScope.of(context);
    final navigate = scope?.navigate ?? widget.onNavigate;
    if (navigate == null) return widget.child;
    return GestureDetector(
      key: const ValueKey('personal-page-bottom-swipe'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _distance = 0,
      onHorizontalDragUpdate: (details) => _distance += details.delta.dx,
      onHorizontalDragEnd: (_) {
        if (_distance.abs() >= 40) navigate(_distance < 0 ? 1 : -1);
      },
      child: widget.child,
    );
  }
}
