import 'package:flutter/material.dart';
import '../l10n/translations.dart';
import 'app_bottom_bar.dart';

// Increment when adding a new feature tutorial; bug-fix builds reuse the revision.
const featureDemoRevision=3;

Future<void> showFeatureDemo(BuildContext context,{int initialStep=0}) async {
  await showDialog<void>(context:context,barrierDismissible:false,builder:(_)=>FeatureDemo(initialStep:initialStep));
  AppNavigation.instance.open?.call(AppDestination.home);
}
class FeatureDemo extends StatefulWidget {
  const FeatureDemo({super.key,this.initialStep=0});
  final int initialStep;
  @override
  State<FeatureDemo> createState()=>_FeatureDemoState();
}
class _FeatureDemoState extends State<FeatureDemo> {
  int _step=0,_replay=0;
  bool _finished=false;
  static const titles=['demoVoiceTitle','demoAddTitle','demoDragTitle','demoHandlesTitle','demoMotifTitle'];
  static const descriptions=['demoVoiceBody','demoAddBody','demoDragBody','demoHandlesBody','demoMotifBody'];
  @override
  void initState() { super.initState();_step=widget.initialStep.clamp(0,titles.length-1).toInt(); }
  Widget _stage(BuildContext context)=>SizedBox(height:140,child:LayoutBuilder(
    builder:(context,size)=>TweenAnimationBuilder<double>(key:ValueKey((_step,_replay)),
      tween:Tween(begin:0,end:1),duration:MediaQuery.disableAnimationsOf(context)?Duration.zero:
        const Duration(milliseconds:1400),builder:(context,value,_) {
        final icon=switch(_step){0=>Icons.mic,1=>Icons.add_circle_outline,2=>Icons.auto_stories_outlined,
          3=>Icons.drag_handle,_=>Icons.palette_outlined};
        return DecoratedBox(decoration:BoxDecoration(color:Theme.of(context).colorScheme.surfaceContainer,
          borderRadius:BorderRadius.circular(16)),child:Stack(children:[
          Positioned(left:16,top:16,child:Icon(_step==2?Icons.menu:Icons.menu_book_outlined,size:32)),
          const Positioned(left:16,right:16,bottom:12,child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,
            children:[Icon(Icons.search),Icon(Icons.home),Icon(Icons.add),Icon(Icons.arrow_back)])),
          Positioned(left:24+(size.maxWidth-96)*value,top:_step==2?16+48*value:40,
            child:Column(children:[Icon(icon,size:32,color:Theme.of(context).colorScheme.primary),
              const Icon(Icons.touch_app_outlined,size:32)])),
        ]));
      })));
  @override
  Widget build(BuildContext context) {
    if(_finished) {
      return PopScope(canPop:false,child:Dialog(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:480),
        child:SingleChildScrollView(child:Padding(padding:const EdgeInsets.all(24),
          child:Column(mainAxisSize:MainAxisSize.min,children:[
            const Icon(Icons.check_circle_outline,size:56),const SizedBox(height:16),
            Text(context.t('demoComplete'),style:Theme.of(context).textTheme.titleLarge),
            const SizedBox(height:12),Text(context.t('demoAgainHint')),const SizedBox(height:20),
            Wrap(spacing:12,runSpacing:8,children:[
              TextButton(key:const ValueKey('demo-restart'),onPressed:()=>setState(() {
                _step=widget.initialStep;_replay=0;_finished=false;
              }),child:Text(context.t('demoWatchAgain'))),
              FilledButton(key:const ValueKey('demo-close'),onPressed:()=>Navigator.pop(context),
                child:Text(context.t('Kapat'))),
            ]),
          ]))))));
    }
    return PopScope(canPop:false,child:Dialog(child:SizedBox(width:480,
      height:(MediaQuery.sizeOf(context).height*.82).clamp(240.0,620.0),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Padding(padding:const EdgeInsets.fromLTRB(16,8,8,0),child:Row(children:[
          Expanded(child:Text(context.t('featureDemo'),style:Theme.of(context).textTheme.titleMedium)),
          TextButton(key:const ValueKey('demo-skip'),onPressed:()=>Navigator.pop(context),
            child:Text(context.t('demoSkip'))),
        ])),
        Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Text('${_step-widget.initialStep+1} / ${titles.length-widget.initialStep}')),
        const Divider(),
        Expanded(child:SingleChildScrollView(key:ValueKey('demo-content-$_step'),
          padding:const EdgeInsets.symmetric(horizontal:16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Text(context.t(titles[_step]),style:Theme.of(context).textTheme.titleMedium),
            const SizedBox(height:12),_stage(context),
            TextButton.icon(key:const ValueKey('demo-replay'),onPressed:()=>setState(()=>_replay++),
              icon:const Icon(Icons.replay),label:Text(context.t('demoReplay'))),
            Text(context.t(descriptions[_step])),const SizedBox(height:8),
          ]))),
        const Divider(),
        Padding(padding:const EdgeInsets.fromLTRB(16,0,16,12),child:Align(alignment:Alignment.centerRight,
          child:FilledButton(key:const ValueKey('demo-next'),onPressed:() {
            if(_step==titles.length-1) { setState(()=>_finished=true); }
            else { setState(()=>_step++); }
          },child:Text(context.t(_step==titles.length-1?'demoFinish':'demoNext'))))),
      ]))));
  }
}
