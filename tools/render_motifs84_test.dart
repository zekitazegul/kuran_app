import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuran_app/l10n/translations.dart';
import 'package:kuran_app/services/app_language.dart';
import 'package:kuran_app/services/app_preferences.dart';
import 'package:kuran_app/widgets/motif_surface.dart';

void main() {
  testWidgets('render motif design gallery',(tester) async {
    tester.view.physicalSize=const Size(1080,800);tester.view.devicePixelRatio=1;
    final fontFile=File('C:/Windows/Fonts/segoeui.ttf');
    await tester.runAsync(() async {
      if(await fontFile.exists()) {
        final loader=FontLoader('PreviewUI')..addFont(Future.value(ByteData.sublistView(await fontFile.readAsBytes())));
        await loader.load();
      }
    });
    AppLanguage.instance.value=const Locale('tr');
    AppPreferences.instance.restore({'color':'blue','motifStyleVersion':2,'motifStrength':.22});
    final key=GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key:key,child:MaterialApp(theme:ThemeData(fontFamily:'PreviewUI'),
      home:Scaffold(body:Column(children:[const Padding(padding:EdgeInsets.all(16),child:Text('KuranApp',style:TextStyle(fontSize:26))),
        Expanded(child:GridView.count(crossAxisCount:3,childAspectRatio:1.03,
          children:[for(final pattern in UiPreferences.motifs.where((p)=>p!='plain'))
            Builder(builder:(context)=>Padding(padding:const EdgeInsets.all(8),child:Card(clipBehavior:Clip.antiAlias,
              child:Column(children:[Expanded(child:MotifSurface(pattern:pattern)),
                Padding(padding:const EdgeInsets.all(8),child:Text(context.t('motif-$pattern'),style:const TextStyle(fontSize:18))),
              ]))))]))])))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary=key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image=await boundary.toImage(pixelRatio:1.5);
      final data=await image.toByteData(format:ui.ImageByteFormat.png);
      final out=Directory('build/verification84');await out.create(recursive:true);
      await File('${out.path}/motif-gallery.png').writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox());
    tester.view.resetPhysicalSize();tester.view.resetDevicePixelRatio();
  });
}
