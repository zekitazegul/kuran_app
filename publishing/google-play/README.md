# Google Play yayın hazırlığı

Bu dosyalar bir yayın hazırlığıdır. Play Console hesabı açılmadı ve uygulama
Google Play'e yüklenmedi. Mağaza metinleri hesap açıldığında kullanılabilir.

## Güncel yerel paket

- `dist/google-play/1.0.12+27/KuranApp-1.0.12-27.aab`: Google Play yükleme paketi.
- AAB imzası doğrulandı. 86 Flutter testi geçti; güncel Android birim testleri geçti.
- `whats-new.txt`: Play Console için TR/EN/NL sürüm notları.
- Play Console hesabı kullanıcıyla birlikte açılacak; uygulama kaydı ve mağaza gönderimi henüz yok.

## Hazır olanlar

- Uygulama kimliği: `com.zekitazegul.kuranapp`.
- Sürüm: `1.0.12`, build: `27`.
- Türkçe, İngilizce ve Hollandaca mağaza açıklamaları: `listings.json`.
- Üç dilde gizlilik metni: `privacy-content.json`; uygulama içi metinle eşleştirildi.
- Web gizlilik sayfası: `../../docs/privacy.html`.
- İmzalı yayın paketi: `build/app/outputs/bundle/release/app-release.aab`.
- Anahtarlar ve şifreler GitHub'a kaydedilmez.

## Hesap ve yayın sırası

1. [Play Console](https://play.google.com/console/signup) üzerinden kendi Google
   hesabınla geliştirici hesabını aç. Tek seferlik kayıt ücreti 25 ABD dolarıdır.
2. Hesap türünü gerçek durumuna göre seç; kimlik, iletişim ve istenen cihaz
   doğrulamalarını tamamla. Ödeme ve kimlik belgelerini bu depoya ekleme.
3. KuranApp uygulamasını oluştur. Varsayılan dil: Türkçe; uygulama türü: uygulama;
   ücret: ücretsiz. Uygulama kimliği ilk paket yüklendiğinde sabitlenir.
4. Herkese açık destek e-postasını, geliştirici iletişim bilgilerini ve hedef
   ülkeleri belirle. Destek e-postası: `ztazegul@yahoo.com`.
5. Hesap sahibi 17 Ekim 2026 tarihinde içerik sahipleriyle iletişimlerinin Google Play dağıtım izinlerini kapsadığını teyit etti. İzin belgelerini ve koşullarını sakla; [durum kaydı](content-rights.md).
6. Gizlilik sayfasını herkese açık HTTPS adresinde yayımla, URL'yi doğrula ve Play
   Console'a ekle. GitHub Pages kullanılırsa beklenen adres
   `https://zekitazegul.github.io/kuran_app/privacy.html` olur; adresin çalıştığı
   doğrulanmadan gönderme. Gizlilik iletişim adresi `ztazegul@yahoo.com`; GitHub Issues alternatifidir.
7. `listings.json` içeriğini üç dilde mağaza alanlarına gir. 512×512 PNG simge,
   1024×500 özellik görseli ve uygulamanın gerçek görünümünü gösteren en az iki
   telefon ekran görüntüsünü hazırla. Dile özgü görüntüleri ilgili dile yükle.
   Simge ve üç dilde özellik görselleri `graphics/` klasöründedir; mağazaya henüz yüklenmedi.
8. Veri güvenliği, reklam, uygulama erişimi, içerik derecelendirme ve hedef kitle
   formlarını gerçek bilgilerle doldur. Giriş hesabı gerekmez; uygulama içi reklam
   SDK'sı yoktur. Yaş derecesini tahmin ederek yazma; anket sonucu belirler.
9. AAB'yi önce dahili teste yükle. Play App Signing'i etkinleştirirken mevcut
   imzalama/yükleme anahtarını koru; anahtarı ve şifreleri güvenli yedekle.
10. Yeni kişisel hesaplarda en az 12 testçinin kesintisiz en az 14 gün katıldığı
    kapalı testi tamamla. Testçileri kendin davet et; burada kimseye mesaj gönderilmedi.
11. Test geri bildirimlerini kaydet ve üretim erişimi başvurusu yap. Onaydan sonra
    üretim sürümünü gönder. Google incelemesi tamamlanmadan uygulama yayında sayılmaz.

## Veri güvenliği değerlendirmesi

Yerel okuma kayıtları, ayraçlar, hatim, tercih ve meal konumları geliştirici
sunucusuna gönderilmez. Reklam/analiz SDK'sı yoktur. Ancak indirmeler GitHub ve
EveryAyah sunucularına HTTPS istekleri gönderir; IP ve istenen dosya bu sunucular
tarafından görülebilir. Dış destek/ödeme sayfası ayrıca kendi veri işlemesini yapar.
Üçüncü taraf hizmetlerin saklama ve işleme koşulları incelenmeden tüm veri güvenliği
alanları için otomatik olarak "veri toplanmıyor" seçilmemelidir. Son beyan hesap
sahibinin gerçek hizmet uygulamalarını değerlendirmesine dayanmalıdır.

## Doğrulama

```sh
flutter analyze
flutter test
cd android
./gradlew :app:testDebugUnitTest
```

Yayın derlemesi ve kopyası:

```sh
flutter build appbundle --release
```

Paketin SHA-256 değerini ve sürümünü `release-manifest.json` ile karşılaştır.
Mağaza ön raporunu gerçek cihazlarla test et. 64-bit ELF yükleme segmentlerinin
16 KB hizalamayı desteklemesi kontrol edildi; bu, 16 KB cihaz testi yerine geçmez.

## Resmî kaynaklar — 17 Ekim 2026 kontrolü

- [Hesap oluşturma ve ücret](https://support.google.com/googleplay/android-developer/answer/6112435?hl=tr)
- [Yeni kişisel hesapların test koşulları](https://support.google.com/googleplay/android-developer/answer/14151465?hl=tr)
- [Hedef API koşulları](https://developer.android.com/google/play/requirements/target-sdk)
- [Mağaza görselleri](https://support.google.com/googleplay/android-developer/answer/9866151?hl=tr)
- [Gizlilik ve kullanıcı verileri](https://support.google.com/googleplay/android-developer/answer/10144311?hl=tr)
- [Fikrî mülkiyet](https://support.google.com/googleplay/android-developer/answer/9888072?hl=tr)
- [16 KB sayfa boyutları](https://developer.android.com/guide/practices/page-sizes?hl=tr)

## Hazır görseller

`graphics/` klasöründeki 512×512 simge ve üç dilde 1024×500 özellik görselleri mevcut marka görselinden oluşturuldu. `screenshots/tr-TR/` gerçek telefondan alınan iki ekranı içerir. Ekran içeriği kesilmeden, mağazanın en fazla 2:1 oranını karşılamak için yanlara arka plan payı eklendi; çıktı 24-bit PNG 1170×2340 boyutundadır. İngilizce ve Hollandaca uygulama ekranı görüntüleri ayrıca alınmalıdır.

Gizlilik sayfasının GitHub Pages yayını otomatik onay incelemesi tarafından, `docs` klasörünün kamuya web sitesi olarak açılması için açık izin bulunmadığı gerekçesiyle reddedildi. Sayfa yayımlanmadı; hesap sahibinin onayı bekleniyor.
