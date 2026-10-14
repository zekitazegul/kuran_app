import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  final Future<void> Function()? onContinue;
  const GuideScreen({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kullanım kılavuzu')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Text('Okumaya hoş geldin', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Bu kısa rehbere istediğin zaman Ayarlar’dan ulaşabilirsin.'),
      const SizedBox(height: 24),
      const _GuideTile(Icons.touch_app_outlined, 'Dokunarak ilerle',
        'Sol alana dokun: sonraki sayfa. Sağ alana dokun: önceki sayfa. Ortaya dokun: çerçevesiz okuma modunu aç veya kapat.'),
      const _GuideTile(Icons.swipe_outlined, 'Sayfayı çevir',
        'Sayfayı parmağınla sağa veya sola sürükle. Ayarlar’dan sayfa çevirme animasyonunu kapatabilirsin.'),
      const _GuideTile(Icons.zoom_in, 'Daha büyük oku',
        'İki parmakla yakınlaştır. Ortaya dokunduğunda dış çerçeve ve kenar yazıları gizlenir; ayetler büyür.'),
      const _GuideTile(Icons.screen_rotation_outlined, 'Yatay okuma',
        'Telefonu yatay çevir, yukarı kaydırarak oku. Sayfanın sonunda yukarı kaydırmaya devam ettiğinde sonraki sayfa en üstten açılır.'),
      const _GuideTile(Icons.bookmarks_outlined, 'Kaldığın yer kaybolmaz',
        'Son okunan sayfa otomatik kaydedilir. Okuyucudaki ayraç simgesiyle birden fazla sayfayı saklayabilirsin.'),
      const _GuideTile(Icons.format_list_numbered, 'Sure ve sayfa seçimi',
        'Ana ekrandan veya okuyucu menüsünden sure seç, ayraçlarını aç ya da sayfa numarası yaz. Bilgisayar hatlı baskıda Fatiha 0, diğer sayfalar 1–604 olarak gösterilir.'),
      const _GuideTile(Icons.cloud_download_outlined, 'Bir kez indir, çevrimdışı oku',
        'Tam mushafı ilk kullanımda indir. Yaklaşık 24 MB PDF indirilir; sayfa hazırlama ek alan kullanır. Duraklatıp devam edebilirsin. İndirme sırasında uygulamayı açık tut.'),
      if (onContinue != null) Padding(padding: const EdgeInsets.only(top: 16), child: FilledButton(
        onPressed: () async {
          try { await onContinue!(); } catch (_) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tercih kaydedilemedi. Tekrar deneyin.')));
          }
        }, child: const Text('Okumaya başlayalım'))),
    ]),
  );
}

class _GuideTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _GuideTile(this.icon, this.title, this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 16),
    child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(text),
      ]))));
}
