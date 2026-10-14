import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/information_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/surah_screen.dart';
import 'services/reading_store.dart';

void main() => runApp(const KuranApp());

class KuranApp extends StatelessWidget {
  const KuranApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'Kuran App',
    theme: ThemeData(useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ReadingStore? _store;
  String? _error;
  bool _downloading = false;
  bool _pauseRequested = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final store = await ReadingStore.load();
      if (mounted) setState(() { _store = store; _error = null; });
    } catch (_) {
      if (mounted) setState(() => _error = 'Okuma kayıtları yüklenemedi. Bu sürüm Android içindir.');
    }
  }

  Future<void> _download() async {
    final store = _store!;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Bilgisayar hatlı Kur’an’ı indir'),
      content: const Text('Bilgisayar hatlı PDF (yaklaşık 24 MB) indirilecek ve sayfalar cihazınızda hazırlanacak. Hazırlanan görseller ek depolama alanı kullanır. Wi-Fi kullanmanız önerilir. İndirme sırasında uygulamayı açık tutun; duraklatıp daha sonra kaldığınız yerden sürdürebilirsiniz.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('İndirmeyi başlat'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() { _downloading = true; _pauseRequested = false; _error = null; });
    try {
      for (var page = 0; page <= 604; page++) {
        if (_pauseRequested || !mounted) break;
        if (store.downloaded.contains(page)) continue;
        await store.downloadPage(page);
        if (mounted) setState(() {});
      }
    } catch (error) {
      final detail = error is PlatformException ? (error.message ?? error.code) : error.toString();
      if (mounted) setState(() => _error = 'İndirme tamamlanamadı: $detail\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _read(int page) async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => QuranScreen(store: _store!, initialPage: page)));
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _pauseRequested = true; super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (store != null && !store.informationSeen) {
      return InformationScreen(onContinue: () async {
        await store.acknowledgeInformation();
        if (mounted) setState(() {});
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Kuran App'), actions: [
        IconButton(tooltip: 'Gizlilik ve erişimler', icon: const Icon(Icons.privacy_tip_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const InformationScreen()))),
      ]),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.menu_book, size: 80), const SizedBox(height: 16),
        const Text('Kur’an-ı Kerim', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Bilgisayar hattı · 114 sure', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (store == null && _error == null) const Center(child: CircularProgressIndicator()),
        if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        if (store == null && _error != null) OutlinedButton(onPressed: _load, child: const Text('Tekrar dene')),
        if (store != null && store.ready) ...[
          FilledButton.icon(onPressed: () => _read(store.lastPage), icon: const Icon(Icons.auto_stories),
            label: Text('Kaldığım yerden devam et · Sayfa ${store.lastPage}')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _read(0), child: const Text('Baştan oku')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => _read(439), child: const Text('Yasin Suresi · Bilgisayar hattı')),
          const SizedBox(height: 16),
          const Text('Bu baskıda Fatiha numarasızdır (0); basılı sayfa numaraları 1–604 arasındadır. Okuyucunun menüsünden sure seçebilir, sayfa numarasıyla gidebilir ve ayraçlarınıza ulaşabilirsiniz. Soldaki alana dokunarak sonraki, sağdaki alana dokunarak önceki sayfaya geçin. Ortadaki alana dokunarak çerçevesiz okuma modunu açıp kapatın. İki parmakla yakınlaştırabilirsiniz. Yatay görünümde yukarı kaydırarak okuyun; sayfanın sonunda yukarı kaydırmaya devam ederek sonraki sayfaya geçin.'),
        ] else if (store != null) ...[
          Text('Hazırlanan sayfalar: ${store.downloaded.length} / 605'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: store.downloaded.length / 605),
          const SizedBox(height: 16),
          if (_downloading) OutlinedButton(onPressed: _pauseRequested ? null : () => setState(() => _pauseRequested = true),
            child: Text(_pauseRequested ? 'Mevcut sayfa tamamlanıyor…' : 'İndirmeyi duraklat'))
          else FilledButton.icon(onPressed: _download, icon: const Icon(Icons.download),
            label: Text(store.downloaded.isEmpty ? 'Tam Kur’an’ı indir' : 'İndirmeye devam et')),
          const SizedBox(height: 16),
          const Text('Tam Kur’an bir kez indirildikten sonra internetsiz okunabilir. Mevcut Yasin sayfaları indirme gerektirmez.'),
        ],
        if (store == null || !store.ready) ...[
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
            builder: (_) => const SurahScreen(surahName: 'Yasin Suresi', pageCount: 6))),
            child: const Text('Yasin Suresi · Çevrimdışı')),
        ],
      ]),
    );
  }
}
