import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  final Future<void> Function()? onContinue;
  const InformationScreen({super.key, this.onContinue});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gizlilik ve uygulama erişimleri')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.privacy_tip_outlined, size: 64),
      const SizedBox(height: 24),
      const Text('Uygulama neye erişir?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      const Text('• İnternet: Bilgisayar hatlı Kur’an PDF’sini yalnızca indirmeyi başlattığınızda raw.githubusercontent.com üzerinden HTTPS ile indirir. Dosyanın SHA-256 özeti doğrulanır, ardından sayfalar cihazınızda görüntüye dönüştürülür. İndirme tamamlanınca çevrimdışı okuyabilirsiniz. Sunucu, bağlantı sırasında IP adresinizi görebilir. Mobil veri ücretleri uygulanabilir; Wi-Fi önerilir.\n\n'
        '• Uygulamaya özel depolama: İndirilen sayfalar, ayraçlar ve son okunan sayfa cihazınızda saklanır. Galerinize veya diğer dosyalarınıza erişilmez. Uygulamayı kaldırmak bu kayıtları siler. Android bulut yedeklemesi bu sürümde kapalıdır.\n\n'
        '• Ekran: Uygulama ön plandayken ekran otomatik kapanmaz. Bu, pil tüketimini artırabilir. Başka uygulamaya geçtiğinizde normal ekran zaman aşımı geri gelir.\n\n'
        'Kamera, mikrofon, konum, rehber, bildirim veya genel dosya erişimi izni istenmez. Hesap, reklam ve analiz SDK’sı bulunmaz. Okuma geçmişiniz ve ayraçlarınız tarafımızca bir sunucuya gönderilmez.\n\n'
        'Bu ekran bir Android izin talebi değildir; uygulamanın davranışlarını açıklayan bilgilendirmedir.\n\n'
        'Kaynak: Kullanıcının sağladığı Diyanet İşleri Başkanlığı, Kur’an-ı Kerim (Rahle Boy), bilgisayar hatlı PDF. Hattat: Süleyman Feyzullahoğlu. PDF’deki numarasız Fatiha ve basılı 1–604 sayfaları korunur; sure seçimi bu baskıya göre yapılır. Bu uygulama Diyanet tarafından onaylanmış resmî bir uygulama değildir.'),
      const SizedBox(height: 24),
      if (onContinue != null) FilledButton(onPressed: () async {
        try { await onContinue!(); } catch (_) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bilgilendirme kaydedilemedi. Tekrar deneyin.')));
        }
      }, child: const Text('Anladım, devam et')),
    ]),
  );
}
