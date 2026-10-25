import 'package:flutter/material.dart';
import '../services/app_preferences.dart';

/// Solid surface colors. Legacy preference names are retained for saved settings.
class MotifSurface extends StatelessWidget {
  const MotifSurface({super.key,this.child,this.menu=false,this.pattern,this.preview=false});
  final Widget? child;
  final bool menu,preview;
  final String? pattern;
  static const lightColors={
    'cream':Color(0xFFF8F4EB),'white':Color(0xFFFFFFFF),'sage':Color(0xFFEAF1E9),
    'sky':Color(0xFFEAF1F8),'lavender':Color(0xFFF1ECF6),'sand':Color(0xFFF3E9D9),
  };
  static const darkColors={
    'cream':Color(0xFF1D1D19),'white':Color(0xFF151515),'sage':Color(0xFF17221A),
    'sky':Color(0xFF17212D),'lavender':Color(0xFF221C2B),'sand':Color(0xFF292219),
  };
  @override
  Widget build(BuildContext context)=>ValueListenableBuilder<UiPreferences>(
    valueListenable:AppPreferences.instance,builder:(context,prefs,_) {
      final colors=Theme.of(context).brightness==Brightness.dark?darkColors:lightColors;
      final selected=pattern??(menu?prefs.menuMotif:prefs.backgroundMotif);
      return Material(color:colors[selected]??colors[menu?'white':'cream']!,
        child:child??const SizedBox.expand());
    });
}
