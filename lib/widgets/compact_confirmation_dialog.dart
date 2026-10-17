import 'package:flutter/material.dart';

/// A compact confirmation positioned within easy reach above the bottom edge.
class CompactConfirmationDialog extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final List<Widget> actions;

  const CompactConfirmationDialog({
    super.key,
    required this.title,
    this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    ),
    child: AlertDialog(
      alignment: Alignment.bottomCenter,
      insetPadding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 360),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      scrollable: true,
      title: title,
      content: content,
      actions: actions,
    ),
  );
}
