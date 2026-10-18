import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import 'compact_confirmation_dialog.dart';

/// Update these notes along with the version in pubspec.yaml for each release.
const latestUpdateNotes = [
  'mealShortcutToggleUpdate',
];

Future<void> showUpdateDialog(BuildContext context, String version) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CompactConfirmationDialog(
          title: Text(context.t('Yenilikler · {version}', {'version': version})),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final note in latestUpdateNotes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('• ${context.t(note)}'),
              ),
            ],
          ),
          actions: [FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('Kapat')),
          )],
        ),
      ),
    );
