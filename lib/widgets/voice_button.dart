import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/voice_control.dart';

class VoiceButton extends StatelessWidget {
  const VoiceButton({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: VoiceControl.busy,
    builder: (context,busy,_) => Tooltip(message:context.t('voiceCommand'),triggerMode:TooltipTriggerMode.manual,child:GestureDetector(onLongPress: VoiceControl.help, child: IconButton(
      onPressed: busy ? null : VoiceControl.listen,
      icon: Icon(busy ? Icons.hourglass_top : Icons.mic_none)))),
  );
}
