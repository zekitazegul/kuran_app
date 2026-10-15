import '../widgets/language_selector.dart';
import '../l10n/translations.dart';
import 'package:flutter/material.dart';
import '../widgets/quran_artwork.dart';

class GuideScreen extends StatelessWidget {
  final Future<void> Function()? onContinue;
  const GuideScreen({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.t('Kullanım kılavuzu')), actions: [LanguageSelector()]),
    body: ListView(padding: EdgeInsets.all(24), children: [
      Center(child: QuranArtwork(size: 140, decorative: true)),
      SizedBox(height: 16),
      Text(context.t('Okumaya hoş geldin'), style: Theme.of(context).textTheme.headlineMedium),
      SizedBox(height: 8),
      Text(context.t('Bu kısa rehbere istediğin zaman Ayarlar’dan ulaşabilirsin.')),
      SizedBox(height: 24),
      _GuideTile(Icons.touch_app_outlined, context.t('Dokunarak ilerle'),
        context.t('Sol kenardaki yaklaşık 1 cm şeride dokun: sonraki sayfa. Sağ kenardaki şeride dokun: önceki sayfa. Geniş orta alana bir kez dokun: çerçevesiz tam ekranı aç veya kapat.')),
      _GuideTile(Icons.swipe_outlined, context.t('Sayfayı çevir'),
        context.t('Sayfayı parmağınla sağa veya sola sürükle. Ayarlar’dan sayfa çevirme animasyonunu kapatabilirsin.')),
      _GuideTile(Icons.zoom_in, context.t('Daha büyük oku'),
        context.t('İki parmakla yakınlaştır. Ortaya dokunduğunda dış çerçeve ve kenar yazıları gizlenir; ayetler büyür. Sayfanın en üstündeyken aşağı çekerek tam ekrandan çıkabilirsin.')),
      _GuideTile(Icons.touch_app, context.t('Çift dokunarak büyüt'),
        context.t('İlk çift dokunuş çerçevenin dış sınırına, ikinci çift dokunuş iç sınırına kadar büyütür. Sonraki çift dokunuşlar bu iki görünüm arasında geçer. Ortaya tek dokunarak tam ekrandan çıkabilirsin.')),
      _GuideTile(Icons.screen_rotation_outlined, context.t('Yatay okuma'),
        context.t('Telefonu yatay çevir, yukarı kaydırarak oku. Sayfanın sonunda yukarı kaydırmaya devam ettiğinde sonraki sayfa en üstten açılır.')),
      _GuideTile(Icons.bookmarks_outlined, context.t('Kaldığın yer kaybolmaz'),
        context.t('Son okunan sayfa otomatik kaydedilir. Okuyucudaki ayraç simgesiyle birden fazla sayfayı saklayabilirsin.')),
      _GuideTile(Icons.format_list_numbered, context.t('Sure ve sayfa seçimi'),
        context.t('Ana ekrandan veya okuyucu menüsünden sure seç, ayraçlarını aç ya da sayfa numarası yaz. Mevcut baskılarda Fatiha 0, diğer sayfalar 1–604 olarak gösterilir. Her hattın ayraçları ve son okunan sayfası ayrı saklanır.')),
      _GuideTile(Icons.cloud_download_outlined, context.t('Bir kez indir, çevrimdışı oku'),
        context.t('Tam mushafı ilk kullanımda indir. PDF boyutu seçilen hatta göre değişir; sayfa hazırlama ek alan kullanır. Duraklatıp devam edebilirsin. İndirme sırasında uygulamayı açık tut.')),
      if (onContinue != null) Padding(padding: EdgeInsets.only(top: 16), child: FilledButton(
        onPressed: () async {
          try { await onContinue!(); } catch (_) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('Tercih kaydedilemedi. Tekrar deneyin.'))));
          }
        }, child: Text(context.t('Okumaya başlayalım')))),
    ]),
  );
}

class _GuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _GuideTile(this.icon, this.title, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsets.only(bottom: 16),
    child: Card(child: Padding(padding: EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary), SizedBox(height: 12),
        Text(context.t(title), style: Theme.of(context).textTheme.titleMedium), SizedBox(height: 6), Text(context.t(text)),
      ]))));
}
