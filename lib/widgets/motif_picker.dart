import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import '../services/app_preferences.dart';
import 'motif_surface.dart';

class MotifPicker extends StatelessWidget {
  const MotifPicker({super.key,required this.menu,required this.onSelected});
  final bool menu;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context)=>ValueListenableBuilder<UiPreferences>(
    valueListenable:AppPreferences.instance,builder:(context,prefs,_)=>GridView.builder(
      padding:const EdgeInsets.all(16),itemCount:UiPreferences.motifs.length,
      gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:220,
        mainAxisExtent:180,crossAxisSpacing:12,mainAxisSpacing:12),
      itemBuilder:(context,index) {
        final pattern=UiPreferences.motifs[index];
        final selected=(menu?prefs.menuMotif:prefs.backgroundMotif)==pattern;
        final colors=Theme.of(context).colorScheme;
        return Semantics(button:true,selected:selected,child:Material(
          key:ValueKey('motif-${menu?'menu':'background'}-$pattern'),clipBehavior:Clip.antiAlias,
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),
            side:BorderSide(color:selected?colors.primary:colors.outlineVariant,width:selected?2.5:1)),
          color:colors.surface,child:InkWell(onTap:()=>onSelected(pattern),child:Column(children:[
            Expanded(child:Stack(fit:StackFit.expand,children:[MotifSurface(pattern:pattern,preview:true),
              if(selected) Positioned(top:8,right:8,child:Icon(Icons.check_circle,color:colors.primary)),
            ])),
            Padding(padding:const EdgeInsets.all(8),child:Text(context.t('motif-$pattern'),
              textAlign:TextAlign.center,maxLines:3)),
          ]))));
      }));
}
