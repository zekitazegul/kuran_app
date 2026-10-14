import 'package:flutter/material.dart';
import '../services/app_language.dart';

const translations = <String, Map<String, String>>{
  'Hat ön izleme': {'en': 'Script preview', 'nl': 'Schriftvoorbeeld'},
  '{edition} · Hat ön izleme': {'en': '{edition} · Script preview', 'nl': '{edition} · Schriftvoorbeeld'},
  'Hüsrev hattını indir': {'en': 'Download Hüsrev edition', 'nl': 'Hüsrev-uitgave downloaden'},
  'Bilgisayar hattını indir': {'en': 'Download Computer Script edition', 'nl': 'Computerschrift downloaden'},
  'Bilgisayar Hattı 2’yi indir': {'en': 'Download Computer Script 2', 'nl': 'Computerschrift 2 downloaden'},
  'Seçilen hat cihazına indirilecek. Wi-Fi kullanmanı ve işlem boyunca uygulamayı açık tutmanı öneririz. İndirmeyi duraklatıp daha sonra devam edebilirsin.': {'en': 'The selected edition will be downloaded to your device. We recommend Wi-Fi and keeping the app open during the process. You can pause and resume later.', 'nl': 'De gekozen uitgave wordt naar je apparaat gedownload. We raden wifi aan en adviseren de app tijdens het proces open te houden. Je kunt pauzeren en later verdergaan.'},
  "2 / 2 · Sayfalar cihaza indiriliyor": {"en": "2 / 2 · Downloading pages to your device", "nl": "2 / 2 · Pagina’s downloaden naar je apparaat"},
  "İndirilen: {done}/{total}": {"en": "Downloaded: {done}/{total}", "nl": "Gedownload: {done}/{total}"},
  "İndirme durduruluyor…": {"en": "Stopping download…", "nl": "Download stoppen…"},
  "İndirmeyi iptal et": {"en": "Cancel download", "nl": "Download annuleren"},
  "İndirme mevcut sayfadan sonra durdurulacak. İndirilen sayfalar korunur; daha sonra devam edebilirsin.": {"en": "The download will stop after the current page. Downloaded pages are kept so you can resume later.", "nl": "De download stopt na de huidige pagina. Gedownloade pagina’s blijven bewaard, zodat je later verder kunt gaan."},
  "İndirme iptal edildi. İndirilen sayfalar korundu.": {"en": "Download cancelled. Downloaded pages were kept.", "nl": "Download geannuleerd. Gedownloade pagina’s zijn bewaard."},
  "{edition} · Kur’an sayfalarını indir": {"en": "{edition} · Download Quran pages", "nl": "{edition} · Koranpagina’s downloaden"},
  "Hattı cihazımdan kaldır": {"en": "Remove edition from my device", "nl": "Schriftuitgave van mijn apparaat verwijderen"},
  "{edition} dosyaları cihazdan silinecek. Ayraçların ve son okuduğun sayfa korunacak. Tekrar okumak için bu hattı yeniden indirmen gerekir.": {"en": "Files for {edition} will be deleted from this device. Your bookmarks and last-read page will be kept. Download this edition again to read it.", "nl": "De bestanden van {edition} worden van dit apparaat verwijderd. Je bladwijzers en laatst gelezen pagina blijven bewaard. Download deze uitgave opnieuw om te lezen."},
  "Kaldır": {"en": "Remove", "nl": "Verwijderen"},
  "Hat cihazından kaldırıldı.": {"en": "Edition removed from your device.", "nl": "Schriftuitgave van je apparaat verwijderd."},
  "Hat kaldırılamadı. Tekrar dene.": {"en": "Could not remove this edition. Try again.", "nl": "De uitgave kon niet worden verwijderd. Probeer het opnieuw."},
  "2 / 2 · Sayfalar cihazda hazırlanıyor": {"en": "2 / 2 · Preparing pages on your device", "nl": "2 / 2 · Pagina’s voorbereiden op je apparaat"},
  "1 / 2 · Dosya indiriliyor": {"en": "1 / 2 · Downloading file", "nl": "1 / 2 · Bestand downloaden"},
  "Hazır: {done} / {total} sayfa · Kalan: {remaining}": {"en": "Ready: {done} / {total} pages · Remaining: {remaining}", "nl": "Gereed: {done} / {total} pagina’s · Resterend: {remaining}"},
  "PDF cihazında. Okuma için sayfalar hazırlanıyor; ek internet indirmesi yapılmıyor.": {"en": "The PDF is on your device. Pages are being prepared for reading; no additional internet download is taking place.", "nl": "De PDF staat op je apparaat. Pagina’s worden klaargemaakt om te lezen; er wordt niets extra van internet gedownload."},
  "Hazırlamayı duraklat": {"en": "Pause preparation", "nl": "Voorbereiding pauzeren"},
  "Sayfaları hazırlamaya devam et": {"en": "Resume preparing pages", "nl": "Pagina’s verder voorbereiden"},
  'İndirilecek sayfalar: {size} MB': {'en': 'Pages to download: {size} MB', 'nl': 'Te downloaden pagina’s: {size} MB'},
  'İndirilen: {done} MB · Kalan: {remaining} MB': {'en': 'Downloaded: {done} MB · Remaining: {remaining} MB', 'nl': 'Gedownload: {done} MB · Resterend: {remaining} MB'},
  'Fetih suresinden hat örneği': {'en': 'Script preview from Surah Al-Fath', 'nl': 'Schriftvoorbeeld uit soera Al-Fath'},
  '{edition} · Fetih suresinden hat örneği': {'en': '{edition} · Script preview from Surah Al-Fath', 'nl': '{edition} · Schriftvoorbeeld uit soera Al-Fath'},
  'Kur’an sayfalarını indir': {'en': 'Download Quran pages', 'nl': 'Koranpagina’s downloaden'},
  'Toplam boyut: {size} MB': {'en': 'Total size: {size} MB', 'nl': 'Totale grootte: {size} MB'},
  'İndirilen sayfalar: {done} MB · Kalan: {remaining} MB': {'en': 'Downloaded pages: {done} MB · Remaining: {remaining} MB', 'nl': 'Gedownloade pagina’s: {done} MB · Resterend: {remaining} MB'},
  'İndirme tamamlandı. Sayfalar okumaya açılıyor…': {'en': 'Download complete. Preparing pages for reading…', 'nl': 'Download voltooid. Pagina’s worden klaargemaakt…'},
  'Bul ve oku': {'en': 'Find and read', 'nl': 'Zoek en lees'},
  'Sure · Cüz · Sayfa': {'en': 'Surah · Juz · Page', 'nl': 'Soera · Djoez · Pagina'},
  'Tümü': {'en': 'All', 'nl': 'Alles'},
  'Sayfa': {'en': 'Page', 'nl': 'Pagina'},
  'Sure adı, cüz veya sayfa numarası': {'en': 'Surah name, juz or page number', 'nl': 'Soeranaam, djoez of paginanummer'},
  'Örn. Ali imran, cüz 3, 439': {'en': 'E.g. Ali Imran, juz 3, 439', 'nl': 'Bijv. Ali Imran, djoez 3, 439'},
  'Aramayı temizle': {'en': 'Clear search', 'nl': 'Zoekopdracht wissen'},
  'Sonuç bulunamadı. Sure adı, 1–30 arası cüz veya 0–604 arası sayfa yazabilirsin.': {'en': 'No results. Enter a surah name, juz 1–30 or page 0–604.', 'nl': 'Geen resultaten. Voer een soeranaam, djoez 1–30 of pagina 0–604 in.'},
  'Birlikte güzelleştirelim': {'en': 'Make it better together', 'nl': 'Samen maken we het mooier'},
  'Bir teşekkür, bir fikir ya da bir kahve… Katkının her türü değerli.': {'en': 'A thank-you, an idea or a coffee… Every contribution is appreciated.', 'nl': 'Een bedankje, een idee of een kopje koffie… Elke bijdrage is welkom.'},
  'Fikrini paylaş': {'en': 'Share your thoughts', 'nl': 'Deel je ideeën'},
  'Bir kahve ikram et': {'en': 'Buy a coffee', 'nl': 'Trakteer op koffie'},
  'Tamamen isteğe bağlı · Geri bildirim ücretsiz': {'en': 'Entirely optional · Feedback is free', 'nl': 'Geheel vrijwillig · Feedback is gratis'},
  'Destek ve geri bildirim sayfamız tarayıcıda açılacak. Mesaj göndermek ücretsiz, kahve ikramı tamamen isteğe bağlıdır.': {'en': 'Our support and feedback page will open in your browser. Feedback is free; buying a coffee is entirely optional.', 'nl': 'Onze steun- en feedbackpagina opent in je browser. Feedback is gratis; een kopje koffie aanbieden is geheel vrijwillig.'},
  'Uygulama hakkında': {'en': 'About the app', 'nl': 'Over de app'},
  'Geliştirici: Zeki Tazegul': {'en': 'Developer: Zeki Tazegul', 'nl': 'Ontwikkelaar: Zeki Tazegul'},
  'aboutDescription': {
    'tr': 'KuranApp, Kur’an-ı Kerim’i farklı hatlarla, çevrimdışı ve reklamsız okumak için geliştirildi. Sure ve cüz seçimi, ayraçlar, kaldığın yerden devam etme ve çerçevesiz tam ekran okuma özellikleriyle kendi okuma düzenini oluşturabilirsin.',
    'en': 'KuranApp lets you read the Quran offline and without ads in different script editions. Find surahs and juz, save bookmarks, resume your reading and use borderless fullscreen mode.',
    'nl': 'Met KuranApp lees je de Koran offline en zonder advertenties in verschillende schriftuitgaven. Kies soera’s en djoez, bewaar bladwijzers, lees verder waar je gebleven bent en gebruik de schermvullende leesmodus.'},
  'supportInvitation': {
    'tr': 'Uygulamayı faydalı buluyorsan geliştiriciye bir kahve ısmarlayarak destek olabilirsin. Bu tamamen isteğe bağlıdır; tüm okuma özellikleri ücretsizdir.',
    'en': 'If you find the app useful, you can support its developer by buying a coffee. Support is entirely optional; all reading features are free.',
    'nl': 'Vind je de app nuttig? Steun de ontwikkelaar met een kopje koffie. Dit is geheel vrijwillig; alle leesfuncties zijn gratis.'},
  'Sure / Cüz': {'en': 'Surah / Juz', 'nl': 'Soera / Djoez'},
  'Cüzler': {'en': 'Juz', 'nl': 'Djoez'},
  'Cüz {number}': {'en': 'Juz {number}', 'nl': 'Djoez {number}'},
  'Sure veya cüz ara': {'en': 'Search surah or juz', 'nl': 'Zoek soera of djoez'},
  'Fetih': {'en': 'Al-Fath', 'nl': 'Al-Fath'},
  'Yasin': {'en': 'Ya-Sin', 'nl': 'Ya-Sin'},
  "Kur’an-ı Kerim": {
    "en": "Quran",
    "nl": "Koran"
  },
  "Kuran App": {
    "tr": "KuranApp",
    "en": "KuranApp",
    "nl": "KuranApp"
  },
  "Ayarlar": {
    "en": "Settings",
    "nl": "Instellingen"
  },
  "Dil seç": {
    "en": "Choose language",
    "nl": "Taal kiezen"
  },
  "Dil tercihi kaydedilemedi.": {
    "en": "Language preference could not be saved.",
    "nl": "De taalvoorkeur kon niet worden opgeslagen."
  },
  "OKUMA VAKTİ": {
    "en": "TIME TO READ",
    "nl": "TIJD OM TE LEZEN"
  },
  "Okumaya devam et": {
    "en": "Continue reading",
    "nl": "Verder lezen"
  },
  "Kütüphanem": {
    "en": "My library",
    "nl": "Mijn bibliotheek"
  },
  "Sureler": {
    "en": "Surahs",
    "nl": "Soera’s"
  },
  "Ayraçlarım": {
    "en": "My bookmarks",
    "nl": "Mijn bladwijzers"
  },
  "Baştan oku": {
    "en": "Read from the beginning",
    "nl": "Vanaf het begin lezen"
  },
  "Fatiha Suresi": {
    "en": "Al-Fatihah",
    "nl": "Al-Fatihah"
  },
  "Yasin Suresi": {
    "en": "Ya-Sin",
    "nl": "Ya-Sin"
  },
  "Fatiha": {
    "en": "Al-Fatihah",
    "nl": "Al-Fatihah"
  },
  "Sayfaya git": {
    "en": "Go to page",
    "nl": "Ga naar pagina"
  },
  "Mushafını hazırla": {
    "en": "Prepare your Quran",
    "nl": "Je Koran voorbereiden"
  },
  "Bir kez indir, her yerde çevrimdışı oku.": {
    "en": "Download once, read offline anywhere.",
    "nl": "Eenmaal downloaden, overal offline lezen."
  },
  "Mevcut sayfa tamamlanıyor…": {
    "en": "Finishing the current page…",
    "nl": "De huidige pagina wordt voltooid…"
  },
  "İndirmeyi duraklat": {
    "en": "Pause download",
    "nl": "Download pauzeren"
  },
  "Tam Kur’an’ı indir": {
    "en": "Download the full Quran",
    "nl": "De volledige Koran downloaden"
  },
  "İndirmeye devam et": {
    "en": "Resume download",
    "nl": "Download hervatten"
  },
  "Tekrar dene": {
    "en": "Try again",
    "nl": "Opnieuw proberen"
  },
  "İptal": {
    "en": "Cancel",
    "nl": "Annuleren"
  },
  "İndirmeyi başlat": {
    "en": "Start download",
    "nl": "Download starten"
  },
  "Bilgisayar hattı": {
    "en": "Computer Script",
    "nl": "Computerschrift"
  },
  "Bilgisayar Hattı 2": {
    "en": "Computer Script 2",
    "nl": "Computerschrift 2"
  },
  "Hüsrev hattı": {
    "en": "Hüsrev Script",
    "nl": "Hüsrev-schrift"
  },
  "Paylaştığınız ikinci mushaf": {
    "en": "Second Quran edition",
    "nl": "Tweede Koraneditie"
  },
  "Paylaştığınız Hüsrev hatlı mushaf": {
    "en": "Hüsrev Quran edition",
    "nl": "Koraneditie in Hüsrev-schrift"
  },
  "OKUMA DENEYİMİ": {
    "en": "READING EXPERIENCE",
    "nl": "LEESERVARING"
  },
  "Sayfa çevirme animasyonu": {
    "en": "Page-turn animation",
    "nl": "Animatie bij omslaan"
  },
  "Kâğıt kıvrımı efektini kullan": {
    "en": "Use the paper-fold effect",
    "nl": "Het papierkruleffect gebruiken"
  },
  "Tercih kaydedilemedi.": {
    "en": "Preference could not be saved.",
    "nl": "De voorkeur kon niet worden opgeslagen."
  },
  "KUR’AN HATTI": {
    "en": "QURAN SCRIPT",
    "nl": "KORANSCHRIFT"
  },
  "Bu hattı ana ekrandan indirebilirsin.": {
    "en": "You can download this edition from the home screen.",
    "nl": "Je kunt deze editie downloaden vanaf het startscherm."
  },
  "Hat seçimi kaydedilemedi.": {
    "en": "Script selection could not be saved.",
    "nl": "De schriftkeuze kon niet worden opgeslagen."
  },
  "YARDIM VE BİLGİ": {
    "en": "HELP AND INFORMATION",
    "nl": "HULP EN INFORMATIE"
  },
  "Kullanım kılavuzu": {
    "en": "User guide",
    "nl": "Gebruikershandleiding"
  },
  "Gizlilik ve erişimler": {
    "en": "Privacy and access",
    "nl": "Privacy en toegang"
  },
  "BİRLİKTE BÜYÜTELİM": {
    "en": "SUPPORT DEVELOPMENT",
    "nl": "STEUN DE ONTWIKKELING"
  },
  "Bir kahveyle destek ol": {
    "en": "Buy the developer a coffee",
    "nl": "Trakteer de ontwikkelaar op koffie"
  },
  "İsteğe bağlı destek · Hiçbir özellik ödeme gerektirmez": {
    "en": "Optional support · All features remain free",
    "nl": "Vrijwillige steun · Alle functies blijven gratis"
  },
  "Destek bağlantısı yakında": {
    "en": "Support link coming soon",
    "nl": "Steunlink binnenkort beschikbaar"
  },
  "Geliştiriciye destek": {
    "en": "Support the developer",
    "nl": "Steun de ontwikkelaar"
  },
  "Dış ödeme sitesine yönlendirileceksin. Destek tamamen isteğe bağlıdır; okuma özelliklerini etkilemez. Ödeme bilgilerin bu uygulamada işlenmez.": {
    "en": "You will open an external payment website. Support is entirely optional and does not affect reading features. This app does not process your payment details.",
    "nl": "Je opent een externe betaalwebsite. Steun is volledig vrijwillig en heeft geen invloed op de leesfuncties. Deze app verwerkt geen betaalgegevens."
  },
  "Vazgeç": {
    "en": "Cancel",
    "nl": "Annuleren"
  },
  "Devam et": {
    "en": "Continue",
    "nl": "Doorgaan"
  },
  "Destek bağlantısı açılamadı.": {
    "en": "The support link could not be opened.",
    "nl": "De steunlink kon niet worden geopend."
  },
  "Okumak her zaman ücretsiz.": {
    "en": "Reading is always free.",
    "nl": "Lezen is altijd gratis."
  },
  "Son okunan sayfa kaydedilemedi.": {
    "en": "The last-read page could not be saved.",
    "nl": "De laatst gelezen pagina kon niet worden opgeslagen."
  },
  "Sayfa görüntüsü okunamadı.": {
    "en": "The page image could not be loaded.",
    "nl": "De pagina-afbeelding kon niet worden geladen."
  },
  "Henüz ayraç yok. Okuduğunuz sayfada ayraç simgesine dokunun.": {
    "en": "No bookmarks yet. Tap the bookmark icon on a page to save it.",
    "nl": "Nog geen bladwijzers. Tik op het bladwijzerpictogram op een pagina om deze op te slaan."
  },
  "Ayraçlar": {
    "en": "Bookmarks",
    "nl": "Bladwijzers"
  },
  "Ayraç kaydedilemedi.": {
    "en": "The bookmark could not be saved.",
    "nl": "De bladwijzer kon niet worden opgeslagen."
  },
  "Sure seç": {
    "en": "Choose surah",
    "nl": "Soera kiezen"
  },
  "Tam ekran": {
    "en": "Full screen",
    "nl": "Volledig scherm"
  },
  "Sonraki sayfa": {
    "en": "Next page",
    "nl": "Volgende pagina"
  },
  "Önceki sayfa": {
    "en": "Previous page",
    "nl": "Vorige pagina"
  },
  "Ayracı kaldır": {
    "en": "Remove bookmark",
    "nl": "Bladwijzer verwijderen"
  },
  "Ayraç ekle": {
    "en": "Add bookmark",
    "nl": "Bladwijzer toevoegen"
  },
  "Sure adı veya numarası": {
    "en": "Surah name or number",
    "nl": "Naam of nummer van de soera"
  },
  "Gizlilik ve uygulama erişimleri": {
    "en": "Privacy and app access",
    "nl": "Privacy en app-toegang"
  },
  "Uygulama neye erişir?": {
    "en": "What does the app access?",
    "nl": "Waar heeft de app toegang toe?"
  },
  "Bilgilendirme kaydedilemedi. Tekrar deneyin.": {
    "en": "Could not save your acknowledgement. Please try again.",
    "nl": "De bevestiging kon niet worden opgeslagen. Probeer het opnieuw."
  },
  "Anladım, devam et": {
    "en": "Understood, continue",
    "nl": "Begrepen, doorgaan"
  },
  "Okumaya hoş geldin": {
    "en": "Welcome to reading",
    "nl": "Welkom bij het lezen"
  },
  "Bu kısa rehbere istediğin zaman Ayarlar’dan ulaşabilirsin.": {
    "en": "You can reopen this short guide from Settings at any time.",
    "nl": "Je kunt deze korte handleiding altijd opnieuw openen via Instellingen."
  },
  "Okumaya başlayalım": {
    "en": "Start reading",
    "nl": "Begin met lezen"
  },
  "Tercih kaydedilemedi. Tekrar deneyin.": {
    "en": "Could not save your preference. Please try again.",
    "nl": "De voorkeur kon niet worden opgeslagen. Probeer het opnieuw."
  },
  "Dokunarak ilerle": {
    "en": "Tap to navigate",
    "nl": "Navigeren met tikken"
  },
  "Sayfayı çevir": {
    "en": "Turn the page",
    "nl": "De pagina omslaan"
  },
  "Daha büyük oku": {
    "en": "Read larger text",
    "nl": "Groter lezen"
  },
  "Yatay okuma": {
    "en": "Landscape reading",
    "nl": "Liggend lezen"
  },
  "Kaldığın yer kaybolmaz": {
    "en": "Keep your place",
    "nl": "Je leesplek blijft bewaard"
  },
  "Sure ve sayfa seçimi": {
    "en": "Choosing surahs and pages",
    "nl": "Soera’s en pagina’s kiezen"
  },
  "Bir kez indir, çevrimdışı oku": {
    "en": "Download once, read offline",
    "nl": "Eenmaal downloaden, offline lezen"
  },
  "Okuma kayıtları yüklenemedi. Bu sürüm Android içindir.": {
    "en": "Reading records could not be loaded. This version is for Android.",
    "nl": "De leesgegevens konden niet worden geladen. Deze versie is voor Android."
  },
  "Seçili hattın PDF’si indirilecek ve sayfalar cihazınızda hazırlanacak. Hazırlanan görseller ek depolama alanı kullanır. Wi-Fi kullanmanız önerilir. İndirme sırasında uygulamayı açık tutun; duraklatıp daha sonra kaldığınız yerden sürdürebilirsiniz.": {
    "en": "The PDF for your selected script will be downloaded and pages prepared on your device. Prepared images use additional storage. Wi-Fi is recommended. Keep the app open during the download; you can pause and resume later.",
    "nl": "De PDF voor het gekozen schrift wordt gedownload en de pagina’s worden op je apparaat voorbereid. Afbeeldingen gebruiken extra opslagruimte. Wifi wordt aanbevolen. Houd de app tijdens het downloaden open; je kunt later pauzeren en hervatten."
  },
  "Ahşap rahle üzerinde altın bezemeli yeşil Kur’an-ı Kerim": {
    "en": "An open Quran resting naturally on a wooden rehal",
    "nl": "Een open Koran die natuurlijk op een houten boekenstandaard rust"
  },
  "Bu hat henüz kullanıma sunulmadı.": {
    "en": "This script is not available yet.",
    "nl": "Dit schrift is nog niet beschikbaar."
  },
  "Güvenilmeyen indirme adresi.": {
    "en": "The download address is not trusted.",
    "nl": "Het downloadadres wordt niet vertrouwd."
  },
  "Geçersiz indirme yönlendirmesi.": {
    "en": "The download redirect is invalid.",
    "nl": "De downloadverwijzing is ongeldig."
  },
  "Çok fazla indirme yönlendirmesi.": {
    "en": "Too many download redirects.",
    "nl": "Te veel downloadverwijzingen."
  },
  "Beklenmeyen PDF boyutu.": {
    "en": "The PDF size was unexpected.",
    "nl": "De PDF heeft een onverwachte grootte."
  },
  "PDF boyutu doğrulanamadı.": {
    "en": "The PDF size could not be verified.",
    "nl": "De PDF-grootte kon niet worden geverifieerd."
  },
  "PDF doğrulaması başarısız; dosya kullanılmadı.": {
    "en": "PDF verification failed; the file was not used.",
    "nl": "De PDF-controle is mislukt; het bestand is niet gebruikt."
  },
  "PDF sayfa sayısı beklenenden farklı.": {
    "en": "The PDF page count was unexpected.",
    "nl": "Het aantal PDF-pagina’s is anders dan verwacht."
  },
  "PDF kaydedilemedi.": {
    "en": "The PDF could not be saved.",
    "nl": "De PDF kon niet worden opgeslagen."
  },
  "Sayfa oluşturulamadı.": {
    "en": "The page could not be prepared.",
    "nl": "De pagina kon niet worden voorbereid."
  },
  "PDF sayfası görüntüye dönüştürülemedi.": {
    "en": "The PDF page could not be rendered.",
    "nl": "De PDF-pagina kon niet worden weergegeven."
  },
  "Sayfa kaydedilemedi.": {
    "en": "The page could not be saved.",
    "nl": "De pagina kon niet worden opgeslagen."
  },
  "Sayfa {page}": {
    "en": "Page {page}",
    "nl": "Pagina {page}"
  },
  "s. {page}": {
    "en": "p. {page}",
    "nl": "p. {page}"
  },
  "{count} sure": {
    "en": "{count} surahs",
    "nl": "{count} soera’s"
  },
  "{count} kayıt": {
    "en": "{count} saved",
    "nl": "{count} opgeslagen"
  },
  "{edition} · Mushafı indir": {
    "en": "{edition} · Download Quran",
    "nl": "{edition} · Koran downloaden"
  },
  "Hazırlanan sayfalar: {done} / {total}": {
    "en": "Pages prepared: {done} / {total}",
    "nl": "Voorbereide pagina’s: {done} / {total}"
  },
  "{edition} · Reklamsız okuma": {
    "en": "{edition} · Ad-free reading",
    "nl": "{edition} · Lezen zonder advertenties"
  },
  "Sayfa numarası ({first}–{last})": {
    "en": "Page number ({first}–{last})",
    "nl": "Paginanummer ({first}–{last})"
  },
  "{first} ile {last} arasında bir sayı yazın.": {
    "en": "Enter a number between {first} and {last}.",
    "nl": "Voer een getal tussen {first} en {last} in."
  },
  "İndirme tamamlanamadı: {detail}\n\nİndirilen sayfalar korunur; tekrar deneyerek devam edebilirsiniz.": {
    "en": "Download could not be completed: {detail}\n\nDownloaded pages are kept. Try again to resume.",
    "nl": "Download kon niet worden voltooid: {detail}\n\nGedownloade pagina’s blijven bewaard. Probeer opnieuw om verder te gaan."
  },
  "İndirme hatası": {
    "en": "Download error",
    "nl": "Downloadfout"
  },
  "Sol kenardaki yaklaşık 1 cm şeride dokun: sonraki sayfa. Sağ kenardaki şeride dokun: önceki sayfa. Geniş orta alana bir kez dokun: çerçevesiz tam ekranı aç veya kapat.": {
    "en": "Tap the roughly 1 cm strip on the left edge for the next page, or the right edge for the previous page. Tap once in the wide central area to enter or leave borderless full screen.",
    "nl": "Tik op de strook van ongeveer 1 cm aan de linkerrand voor de volgende pagina, of aan de rechterrand voor de vorige. Tik eenmaal in het brede middengebied om de randloze schermvullende modus te openen of sluiten."
  },
  "Sayfayı parmağınla sağa veya sola sürükle. Ayarlar’dan sayfa çevirme animasyonunu kapatabilirsin.": {
    "en": "Drag the page to the right or left with your finger. You can turn the page animation off in Settings.",
    "nl": "Sleep de pagina met je vinger naar rechts of links. Je kunt de omsla-animatie uitschakelen in Instellingen."
  },
  "İki parmakla yakınlaştır. Ortaya dokunduğunda dış çerçeve ve kenar yazıları gizlenir; ayetler büyür. Sayfanın en üstündeyken aşağı çekerek tam ekrandan çıkabilirsin.": {
    "en": "Pinch with two fingers to zoom. Tap the center to hide the outer frame and margin labels and enlarge the verses. Pull down at the top of the page to leave full screen.",
    "nl": "Zoom met twee vingers. Tik in het midden om het buitenkader en de randteksten te verbergen en de verzen groter te maken. Trek bovenaan de pagina omlaag om het volledige scherm te verlaten."
  },
  "Telefonu yatay çevir, yukarı kaydırarak oku. Sayfanın sonunda yukarı kaydırmaya devam ettiğinde sonraki sayfa en üstten açılır.": {
    "en": "Rotate your phone to landscape and swipe up to read. At the bottom, keep swiping up to turn to the next page and start at the top.",
    "nl": "Draai je telefoon horizontaal en veeg omhoog om te lezen. Veeg onderaan verder omhoog om de volgende pagina vanaf de bovenkant te openen."
  },
  "Son okunan sayfa otomatik kaydedilir. Okuyucudaki ayraç simgesiyle birden fazla sayfayı saklayabilirsin.": {
    "en": "Your last-read page is saved automatically. Use the bookmark icon in the reader to save multiple pages.",
    "nl": "De laatst gelezen pagina wordt automatisch opgeslagen. Gebruik het bladwijzerpictogram om meerdere pagina’s te bewaren."
  },
  "Ana ekrandan veya okuyucu menüsünden sure seç, ayraçlarını aç ya da sayfa numarası yaz. Mevcut baskılarda Fatiha 0, diğer sayfalar 1–604 olarak gösterilir. Her hattın ayraçları ve son okunan sayfası ayrı saklanır.": {
    "en": "Choose a surah, open bookmarks or enter a page number from the home screen or reader menu. In the current editions Al-Fatihah is page 0, followed by pages 1–604. Each script keeps its own bookmarks and reading position.",
    "nl": "Kies een soera, open bladwijzers of voer een paginanummer in via het startscherm of het leesmenu. In de huidige edities is Al-Fatihah pagina 0, gevolgd door pagina’s 1–604. Elk schrift bewaart eigen bladwijzers en leespositie."
  },
  "Tam mushafı ilk kullanımda indir. PDF boyutu seçilen hatta göre değişir; sayfa hazırlama ek alan kullanır. Duraklatıp devam edebilirsin. İndirme sırasında uygulamayı açık tut.": {
    "en": "Download the full Quran once. PDF size depends on the selected script, and preparing pages uses extra storage. You can pause and resume. Keep the app open during the download.",
    "nl": "Download de volledige Koran eenmaal. De PDF-grootte hangt af van het schrift; het voorbereiden gebruikt extra opslag. Je kunt pauzeren en hervatten. Houd de app tijdens het downloaden open."
  },
  "privacyBody": {
    "tr": "• İnternet: Seçtiğiniz hattın Kur’an PDF’sini yalnızca indirmeyi başlattığınızda raw.githubusercontent.com üzerinden HTTPS ile indirir. Dosyanın SHA-256 özeti doğrulanır, ardından sayfalar cihazınızda görüntüye dönüştürülür. İndirme tamamlanınca çevrimdışı okuyabilirsiniz. Sunucu, bağlantı sırasında IP adresinizi görebilir. Mobil veri ücretleri uygulanabilir; Wi-Fi önerilir.\n\n• Uygulamaya özel depolama: İndirilen sayfalar, ayraçlar ve son okunan sayfa cihazınızda saklanır. Galerinize veya diğer dosyalarınıza erişilmez. Uygulamayı kaldırmak bu kayıtları siler. Android bulut yedeklemesi bu sürümde kapalıdır.\n\n• Ekran: Uygulama ön plandayken ekran otomatik kapanmaz. Bu, pil tüketimini artırabilir. Başka uygulamaya geçtiğinizde normal ekran zaman aşımı geri gelir.\n\nKamera, mikrofon, konum, rehber, bildirim veya genel dosya erişimi izni istenmez. Hesap, reklam ve analiz SDK’sı bulunmaz. Okuma geçmişiniz ve ayraçlarınız tarafımızca bir sunucuya gönderilmez.\n\nİsteğe bağlı geliştirici desteği etkinleştirildiğinde ödeme, seçiminizle dış tarayıcıdaki sağlayıcı üzerinden yapılır. Ödeme bilgileri uygulamada işlenmez; sağlayıcının gizlilik koşulları geçerlidir.\n\nBu ekran bir Android izin talebi değildir; uygulamanın davranışlarını açıklayan bilgilendirmedir.\n\nKaynaklar: Kullanıcının sağladığı bilgisayar hatlı Diyanet PDF’si, Bilgisayar Hattı 2 ve Hüsrev hattı PDF’leri. Her hattın sayfa düzeni, sure dizini ve okuma kayıtları ayrıdır. Bilgisayar hattı: Süleyman Feyzullahoğlu. Yayıncıların onayladığı resmî bir uygulama değildir.",
    "en": "• Internet: The PDF for your selected Quran script is downloaded over HTTPS from raw.githubusercontent.com only when you start the download. Its SHA-256 is verified before the pages are rendered on your device. After preparation you can read offline. The download server may see your IP address. Mobile data charges may apply; Wi-Fi is recommended.\n\n• Private app storage: Pages, bookmarks and the last-read page stay on your device. The app does not access your gallery or other files. Uninstalling deletes these records. Android cloud backup is disabled in this version.\n\n• Screen: The screen stays awake while the app is in the foreground. This can increase battery use. Normal screen timeout resumes when you switch to another app.\n\nNo camera, microphone, location, contacts, notification or broad file-access permissions are requested. There are no accounts, ads or analytics SDKs. We do not send your reading history or bookmarks to a server.\n\nIf optional developer support is enabled, you choose whether to open an external payment provider in your browser. This app does not process payment details; the provider’s privacy terms apply.\n\nThis is an information screen, not an Android permission request.\n\nSources: The computer-script Diyanet PDF, Computer Script 2 PDF and Hüsrev PDF supplied by the user. Each edition has its own layout, surah index and reading records. Computer-script calligrapher: Süleyman Feyzullahoğlu. This is not an official app endorsed by the publishers.",
    "nl": "• Internet: De PDF van het gekozen Koranschrift wordt alleen op jouw verzoek via HTTPS van raw.githubusercontent.com gedownload. De SHA-256 wordt gecontroleerd voordat de pagina’s op je apparaat worden weergegeven. Daarna kun je offline lezen. De downloadserver kan je IP-adres zien. Mobiele datakosten kunnen gelden; wifi wordt aanbevolen.\n\n• Privéopslag van de app: Pagina’s, bladwijzers en de laatst gelezen pagina blijven op je apparaat. De app heeft geen toegang tot je galerij of andere bestanden. Verwijderen van de app wist deze gegevens. Android-cloudback-ups zijn in deze versie uitgeschakeld.\n\n• Scherm: Het scherm blijft aan zolang de app op de voorgrond staat. Dit kan meer batterij verbruiken. De normale schermtime-out keert terug als je naar een andere app gaat.\n\nEr worden geen rechten gevraagd voor camera, microfoon, locatie, contacten, meldingen of algemene bestandstoegang. Er zijn geen accounts, advertenties of analyse-SDK’s. Je leesgeschiedenis en bladwijzers worden niet naar onze server gestuurd.\n\nAls vrijwillige ontwikkelaarssteun beschikbaar is, kies je zelf of je een externe betaalwebsite opent. De app verwerkt geen betaalgegevens; de privacyvoorwaarden van de aanbieder gelden.\n\nDit is een informatiescherm, geen Android-toestemmingsverzoek.\n\nBronnen: De door de gebruiker verstrekte Diyanet-PDF in computerschrift, Computerschrift 2 en Hüsrev-PDF. Elke editie heeft een eigen indeling, soera-index en leesgegevens. Kalligraaf van het computerschrift: Süleyman Feyzullahoğlu. Dit is geen officiële app die door de uitgevers is goedgekeurd."
  }
};

String translate(String key, String language, [Map<String, Object> values = const {}]) {
  final entry = translations[key];
  var text = language == 'tr' ? (entry?['tr'] ?? key) : (entry?[language] ?? key);
  if (entry == null && language != 'tr') {
    final http = RegExp(r'HTTP\s+\d+').firstMatch(key)?.group(0);
    if (http != null) text = language == 'nl' ? 'Downloadfout ($http)' : 'Download error ($http)';
  }
  values.forEach((name, value) { text = text.replaceAll('{$name}', value.toString()); });
  return text;
}

extension QuranTranslations on BuildContext {
  String get language {
    // Register a dependency so MaterialApp locale changes rebuild the UI.
    Localizations.localeOf(this);
    return AppLanguage.instance.value?.languageCode ?? 'tr';
  }
  String t(String key, [Map<String, Object> values = const {}]) => translate(key, language, values);
}
