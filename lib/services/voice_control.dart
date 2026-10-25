import 'package:flutter/material.dart';
import 'voice_intents.dart';

/// Screens register their own actions; only the visible route handles a command.
class VoiceControl {
  static VoidCallback? listen;
  static VoidCallback? help;
  static final busy = ValueNotifier(false);
  static final Map<Object, ({bool Function() active, Future<bool> Function(VoiceCommand) run})> _screens = {};
  static void register(Object owner, bool Function() active, Future<bool> Function(VoiceCommand) run) {
    _screens[owner] = (active: active, run: run);
  }
  static void unregister(Object owner) => _screens.remove(owner);
  static Future<bool> dispatch(VoiceCommand command) async {
    for (final screen in _screens.values.toList().reversed) {
      if (screen.active() && await screen.run(command)) return true;
    }
    return false;
  }
}
