import 'package:flutter/material.dart';
import '../services/app_language.dart';

const translations = <String, Map<String, String>>{
  "prayerListenHint": {"tr": "Bir kez indir, çevrimdışı dinle", "en": "Download once and listen offline", "nl": "Eenmaal downloaden en offline luisteren"},
  "prayerListen": {"tr": "Hatim duasını dinle", "en": "Listen to the khatm prayer", "nl": "Naar het khatmgebed luisteren"},
  "updateBadgeFeature": {"tr": "Yeni sürümler Güncellemeler başlığında işaretlenir; yenilikleri okuyabilirsin.", "en": "New versions are marked under Updates; tap to read what’s new.", "nl": "Nieuwe versies worden gemarkeerd bij Updates; tik om te lezen wat er nieuw is."},
  "updateCheckError": {"tr": "Sürüm bilgisi alınamadı. Bağlantını kontrol edip yeniden dene.", "en": "Could not check for updates. Check your connection and try again.", "nl": "Updates konden niet worden gecontroleerd. Controleer je verbinding en probeer opnieuw."},
  "updateRefresh": {"tr": "Yeniden kontrol et", "en": "Check again", "nl": "Opnieuw controleren"},
  "updateNotesFallback": {"tr": "Yeni sürüm hazır.", "en": "A new version is available.", "nl": "Er is een nieuwe versie beschikbaar."},
  "updateAvailableVersion": {"tr": "Yeni sürüm: {version}", "en": "New version: {version}", "nl": "Nieuwe versie: {version}"},
  "updateNewBadge": {"tr": "Yeni", "en": "New", "nl": "Nieuw"},
  "prayerDownloadUpdate": {"tr": "Dua kaydını istediğinde indirip çevrimdışı dinleyebilirsin.", "en": "Download the prayer recording when you want and listen offline.", "nl": "Download de gebedsopname wanneer je wilt en luister offline."},
  "screenAwakeUpdate": {"tr": "Ekranı açık tutmayı ayarlardan açıp kapatabilirsin.", "en": "Turn Keep screen on on or off in Settings.", "nl": "Schakel Scherm aanhouden in of uit via Instellingen."},
  "installerUpdate": {"tr": "Uygulamayı küçük Kuran Installer dosyasıyla paylaşabilirsin.", "en": "Share the app using the small Kuran Installer file.", "nl": "Deel de app met het kleine Kuran Installer-bestand."},
  "prayerRetry": {"tr": "Yeniden dene", "en": "Try again", "nl": "Opnieuw proberen"},
  "prayerDownloadError": {"tr": "İndirme tamamlanamadı. İnternet bağlantını ve boş alanı kontrol edip yeniden dene.", "en": "Download failed. Check your internet connection and free space, then try again.", "nl": "Downloaden is mislukt. Controleer je internetverbinding en vrije ruimte en probeer opnieuw."},
  "prayerDownloadHint": {"tr": "Dua kaydı bir kez indirilir ({size} MB). Ardından çevrimdışı dinleyebilirsin. Wi-Fi bağlantısı önerilir.", "en": "Download the prayer recording once ({size} MB), then listen offline. Wi-Fi is recommended.", "nl": "Download de gebedsopname eenmalig ({size} MB) en luister daarna offline. Wifi wordt aanbevolen."},
  "prayerDownloadTitle": {"tr": "Dua kaydını indir", "en": "Download prayer recording", "nl": "Gebedsopname downloaden"},
  "screenAwakeHint": {"tr": "Ekran otomatik kapanmaz.", "en": "The screen does not turn off automatically.", "nl": "Het scherm gaat niet automatisch uit."},
  "screenAwakeEnabled": {"tr": "Uygulama açıkken", "en": "While the app is open", "nl": "Terwijl de app geopend is"},
  "screenAwakeTitle": {"tr": "Ekranı açık tut", "en": "Keep screen on", "nl": "Scherm aanhouden"},
  "distributionCheck": {"tr": "Güncellemeler", "en": "Updates", "nl": "Updates"},
  "distributionInstaller": {"tr": "Kuran Installer’ı paylaş", "en": "Share Kuran Installer", "nl": "Kuran Installer delen"},
  "prayerRecordingDetails": {"tr": "Abdurrahman es-Sudeys · Arapça hatim duası. Bir kez indirip çevrimdışı dinleyebilirsin.", "en": "Abdurrahman As-Sudais · Arabic khatm prayer. Download once to listen offline.", "nl": "Abdurrahman As-Sudais · Arabisch khatmgebed. Download eenmaal om offline te luisteren."},
  "prayerTurkishExample": {"tr": "Kısa Türkçe dua örneği", "en": "A short prayer example in Turkish", "nl": "Een kort voorbeeldgebed in het Turks"},
  "prayerAudioError": {"tr": "Dua kaydı açılamadı. Tekrar deneyin.", "en": "Could not play the prayer recording. Please try again.", "nl": "De gebedsopname kon niet worden afgespeeld. Probeer opnieuw."},
  "hatimRecordingUpdate": {"tr": "Hatim duasını Abdurrahman es-Sudeys’in sesinden çevrimdışı dinleyebilirsin.", "en": "Listen offline to the khatm prayer recited by Abdurrahman As-Sudais.", "nl": "Luister offline naar het khatmgebed door Abdurrahman As-Sudais."},
  "prayerRecordingSource": {"tr": "Hatim duası · Abdurrahman es-Sudeys", "en": "Khatm prayer · Abdurrahman As-Sudais", "nl": "Khatmgebed · Abdurrahman As-Sudais"},
  "prayerSourceDetails": {"tr": "Arapça hatim duası kaydı: Abdurrahman es-Sudeys. Kaynak: Islamweb ses kütüphanesi. Kayıt isteğe bağlı indirilir ve ardından çevrimdışı oynatılır. Kısa Türkçe dua ayrı bir örnektir; kaydın birebir metni veya çevirisi değildir.", "en": "Arabic khatm prayer: Abdurrahman As-Sudais. Source: Islamweb audio library. Download the recording on request, then play it offline. The short Turkish prayer is a separate example, not a transcript or translation of the recording.", "nl": "Arabisch khatmgebed: Abdurrahman As-Sudais. Bron: de audiobibliotheek van Islamweb. Download de opname op verzoek en speel deze daarna offline af. Het korte Turkse gebed is een apart voorbeeld, geen transcriptie of vertaling van de opname."},
  "Hatminiz tamamlandı": {"tr": "Hatminiz tamamlandı", "en": "Your khatm is complete", "nl": "Je khatm is voltooid"},
  "Tekrar dinle": {"tr": "Tekrar dinle", "en": "Listen again", "nl": "Opnieuw luisteren"},

  "shareAppFeature": {"tr": "Uygulamayı WhatsApp veya e-postayla paylaşabilirsin.", "en": "Share the app via WhatsApp or email.", "nl": "Deel de app via WhatsApp of e-mail."},
  "updateAppFeature": {"tr": "Yeni sürümleri Ayarlar’dan kontrol edip yükleyebilirsin.", "en": "Check for and install updates from Settings.", "nl": "Controleer en installeer updates via Instellingen."},
  "downloadTitle": {"tr": "Güncellemeyi indir", "en": "Download update", "nl": "Update downloaden"},
  "downloadWifi": {"tr": "Dosya boyutu: {size} MB. İndirme başlatılsın mı?", "en": "File size: {size} MB. Start downloading?", "nl": "Bestandsgrootte: {size} MB. Download starten?"},
  "downloadSmallMobile": {"tr": "Dosya boyutu: {size} MB (2 MB veya daha az). Mobil veriyle indirmeyi onaylıyor musun?", "en": "File size: {size} MB (2 MB or less). Allow downloading with mobile data?", "nl": "Bestandsgrootte: {size} MB (2 MB of minder). Downloaden via mobiele data toestaan?"},
  "downloadLargeMobile": {"tr": "Dosya boyutu: {size} MB. Wi-Fi bağlantısı önerilir. Mobil veriyle devam edilsin mi?", "en": "File size: {size} MB. Wi-Fi is recommended. Continue using mobile data?", "nl": "Bestandsgrootte: {size} MB. Wifi wordt aanbevolen. Doorgaan via mobiele data?"},
  "downloadAccept": {"tr": "İndir", "en": "Download", "nl": "Downloaden"},
  "downloadCancel": {"tr": "Vazgeç", "en": "Cancel", "nl": "Annuleren"},
  "downloadCancelled": {"tr": "İndirme iptal edildi.", "en": "Download cancelled.", "nl": "Download geannuleerd."},
  "downloadSizeRelease": {"tr": "İndirmeden önce dosya boyutu gösterilir. Mobil veride indirme onayı alınır; büyük dosyalarda Wi-Fi önerilir.", "en": "File size is shown before downloading. Mobile data requires confirmation; Wi-Fi is recommended for larger files.", "nl": "De bestandsgrootte wordt vooraf getoond. Mobiele data vereist toestemming; wifi wordt aanbevolen voor grotere bestanden."},
  "distributionShare": {"tr": "Uygulamayı paylaş", "en": "Share app", "nl": "App delen"},
  "distributionShareHint": {"tr": "Küçük Kuran Installer dosyasını gönder. KuranApp alıcının telefonuna internetten indirilir; sesler isteğe bağlıdır.", "en": "Send the small Kuran Installer file. KuranApp is downloaded on the recipient’s phone; audio is optional.", "nl": "Verstuur het kleine Kuran Installer-bestand. KuranApp wordt op de telefoon van de ontvanger gedownload; audio is optioneel."},
  "distributionPreparing": {"tr": "Kurulum dosyası hazırlanıyor…", "en": "Preparing installer…", "nl": "Installatiebestand voorbereiden…"},
  "shareError": {"tr": "Kurulum dosyası paylaşılamadı. Boş alanı kontrol edip yeniden dene.", "en": "Could not share the installer. Check free space and try again.", "nl": "Het installatiebestand kon niet worden gedeeld. Controleer de vrije ruimte en probeer opnieuw."},
  "distributionUpdate": {"tr": "Güncelle", "en": "Update", "nl": "Bijwerken"},
  "updateIdle": {"tr": "Yeni sürümü kontrol et", "en": "Check for a new version", "nl": "Controleren op een nieuwe versie"},
  "updateChecking": {"tr": "Son güncellemeler kontrol ediliyor…", "en": "Checking for updates…", "nl": "Controleren op updates…"},
  "updateDownloading": {"tr": "Güncelleme indiriliyor…", "en": "Downloading update…", "nl": "Update downloaden…"},
  "updatePermission": {"tr": "Kurulum için KuranApp’e izin ver; ardından geri dön.", "en": "Allow KuranApp to install apps, then return.", "nl": "Geef KuranApp toestemming om apps te installeren en ga terug."},
  "updateInstalling": {"tr": "Güncelleme yükleniyor… Android kurulum onayını bekliyor.", "en": "Installing update… Waiting for Android installation confirmation.", "nl": "Update installeren… Wachten op bevestiging van Android."},
  "updatePermissionDenied": {"tr": "Kurulum izni verilmedi. Tekrar denemek için Güncelle’ye bas.", "en": "Installation permission was not granted. Tap Update to retry.", "nl": "Geen toestemming voor installatie. Tik op Bijwerken om opnieuw te proberen."},
  "updateInstallerClosed": {"tr": "Kurulum ekranı kapatıldı. Sürümü kontrol etmek için Güncelle’ye bas.", "en": "Installer closed. Tap Update to check the version.", "nl": "Installatiescherm gesloten. Tik op Bijwerken om de versie te controleren."},
  "updateCurrent": {"tr": "Uygulamanız zaten en son sürüm olan {version} sürümünde.", "en": "Your app is already on the latest version, {version}.", "nl": "Je app heeft al de nieuwste versie, {version}."},
  "updateError": {"tr": "Güncelleme alınamadı veya doğrulanamadı. İnternet bağlantını ve boş alanı kontrol edip yeniden dene.", "en": "Could not download or verify the update. Check your connection and free space, then retry.", "nl": "De update kan niet worden gedownload of gecontroleerd. Controleer je verbinding en vrije ruimte en probeer opnieuw."},
  "distributionRelease": {"tr": "Ayarlar’dan uygulamayı APK olarak paylaşabilir, son sürümü GitHub sayfası açmadan indirip Android onayıyla kurabilirsin.", "en": "Share the app as an APK from Settings, and download the latest version without opening GitHub. Android asks for installation confirmation.", "nl": "Deel de app als APK vanuit Instellingen en download de nieuwste versie zonder GitHub te openen. Android vraagt om bevestiging voor installatie."},
  "distributionPrivacy": {"tr": "Kuran Installer paylaşımında yalnızca küçük kurulum dosyası gönderilir. Ayarlar açıldığında sürüm bilgisi GitHub üzerinden kontrol edilir. Uygulama ve güncellemeleri GitHub üzerinden, isteğe bağlı dua kaydı Islamweb üzerinden indirilir. Bu hizmetler IP adresi gibi bağlantı bilgilerini görebilir. Konum ve cihaz istatistiği gönderilmez.", "en": "Sharing Kuran Installer sends only the small installer file. Opening Settings checks version information on GitHub. The app and its updates are downloaded from GitHub, and the optional prayer recording from Islamweb. These services can see network information such as your IP address. No location or device statistics are sent.", "nl": "Bij het delen van Kuran Installer wordt alleen het kleine installatiebestand verstuurd. Bij het openen van Instellingen wordt versie-informatie op GitHub gecontroleerd. De app en updates worden van GitHub gedownload en de optionele gebedsopname van Islamweb. Deze diensten kunnen netwerkgegevens zoals je IP-adres zien. Er worden geen locatie- of apparaatstatistieken verstuurd."},
  'mealTextOrderUpdate': {'tr': 'Meal Oku’da ayetlerle açıklamaların birbirine karışmasına yol açan sütun sırası düzeltildi. Satır sonunda bölünen kelimelerin birleştirilmesi iyileştirildi; PDF’nin tüm sayfaları yeniden denetlendi.', 'en': 'Fixed the column order that mixed verses with notes in Translation. Improved joining words split at line endings and audited every PDF page again.', 'nl': 'De kolomvolgorde waardoor verzen en toelichtingen in Vertaling door elkaar raakten is hersteld. Woorden die aan het regeleinde waren afgebroken worden beter samengevoegd; alle PDF-pagina’s zijn opnieuw gecontroleerd.'},
  'mealShortcutToggleUpdate': {'tr': 'Alt navigasyon çubuğundaki Meal Oku kısayoluna ikinci kez dokunduğunda açık meal kapanır ve ana sayfaya dönülür. Açık kısayol çubukta vurgulanır.', 'en': 'Tapping the Translation shortcut in the bottom navigation bar a second time closes it and returns to Home. The active shortcut is highlighted in the bar.', 'nl': 'Tik een tweede keer op de vertaalsnelkoppeling in de onderste navigatiebalk om deze te sluiten en terug te keren naar het startscherm. De actieve snelkoppeling wordt gemarkeerd in de balk.'},
  'stabilityUpdate': {'tr': 'Okuma sayfalarında görsel belleği yönetimi düzeltildi. Ayet konum verileri arayüzü meşgul etmeden işlenir. Kullanılmayan ikon bağımlılığı ve taslak meal verisinin kurulum paketine eklenmesi kaldırıldı.', 'en': 'Fixed image memory management in reading pages. Verse position data is processed off the UI thread. Removed an unused icon dependency and excluded draft translation data from the installation package.', 'nl': 'Het beheer van afbeeldingsgeheugen op leespagina’s is hersteld. Verspositiegegevens worden buiten de UI-thread verwerkt. Een ongebruikte pictogramafhankelijkheid is verwijderd en conceptvertaalgegevens worden niet meer in het installatiepakket opgenomen.'},
  'selectedMemorizationUpdate': {'tr': 'Ezber seçeneği çoklu ayet seçiminde geri eklendi. Ezber aralığı seçtiğin ayetlerle doldurulur; tekrar sayısı varsayılan 3’tür ve değiştirilebilir. Ayetler katımlı tekrar edilir. Aynı sayfada sure sınırını geçen seçimler de desteklenir.', 'en': 'Memorize is available for multiple selected verses again. The range starts with your selection; repetitions default to 3 and can be changed. Verses repeat cumulatively, including selections across surahs on the same page.', 'nl': 'Memoriseren is weer beschikbaar bij meerdere geselecteerde verzen. Het bereik begint met je selectie; het aantal herhalingen is standaard 3 en kan worden aangepast. De verzen worden cumulatief herhaald, ook over soeragrenzen op dezelfde pagina.'},
  'verseDragSelectionUpdate': {'tr': 'Bir ayete uzun basıp parmağını kaldırmadan yukarı veya aşağı sürükleyerek ayet aralığı seç. Parmağını kaldırınca seçilen ayetleri seslendirebilir veya meallerini okuyabilirsin. Ana sayfadaki Sureler kartı büyüteç simgesiyle, Meal Oku kartı açık kitap simgesiyle gösterilir.', 'en': 'Long press a verse and drag up or down without lifting your finger to select a range. Release to listen to the selected verses or read their translations. The home Surahs card uses a search icon and the Translation card uses an open book.', 'nl': 'Houd een vers ingedrukt en sleep omhoog of omlaag zonder je vinger op te tillen om een bereik te selecteren. Laat los om de verzen te beluisteren of hun vertalingen te lezen. De soerakaart heeft een zoekpictogram en de vertaalkaart een open boek.'},
  'readerOnlyListeningUpdate': {'tr': 'Kur’an Dinle kartı, Ayarlar’daki Dinle bağlantısı ve eklenebilir dinleme kısayolları kaldırıldı. Sure seçtikten sonra Kur’an okuyucusunun üstündeki Dinle düğmesini kullan.', 'en': 'Removed the Quran listening card, the Listen link in Settings and standalone listening shortcuts. Choose a surah, then use Listen at the top of the Quran reader.', 'nl': 'De luisterkaart, de luisterlink in Instellingen en losse luistersnelkoppelingen zijn verwijderd. Kies een soera en gebruik daarna Luisteren bovenaan de Koranlezer.'},
  'centeredReaderActionsUpdate': {'tr': 'İnce Dinle–Meal çubuğu Kur’an sayfasının üstünde ortalandı.', 'en': 'The slim Listen–Translation bar is centered above the Quran page.', 'nl': 'De lage balk Luisteren–Vertaling is gecentreerd boven de Koranpagina.'},
  'mealCardCompactUpdate': {'tr': 'Ana sayfadaki Meal Oku kartının kaynak alt satırı kaldırıldı; kart diğer tek satırlı kartlarla aynı yükseklikte gösterilir.', 'en': 'Removed the source subtitle from the home Translation card; it now matches the height of the other single-line cards.', 'nl': 'De bronvermelding onder de vertaalkaart op het startscherm is verwijderd; de kaart is nu even hoog als de andere kaarten met één regel.'},
  'hatimProgressActions': {'tr': 'Sayfa / cüz işaretle', 'en': 'Mark pages / juz', 'nl': 'Pagina’s / djoez markeren'},
  'compactReaderBarsUpdate': {'tr': 'Üstteki Dinle ve Meal düğmeleri simge ve metin yan yana olacak şekilde inceltildi. Alttaki hatim sayacı ve Okundu satırının boşlukları azaltıldı; Kur’an sayfasına daha fazla alan bırakıldı.', 'en': 'The top Listen and Translation buttons are slimmer, with icons beside their labels. Reduced spacing in the bottom completion counter and Read row leaves more room for the Quran page.', 'nl': 'De bovenste knoppen Luisteren en Vertaling zijn smaller in hoogte, met pictogrammen naast de tekst. Minder ruimte in de onderste voortgangs- en Gelezen-rij geeft meer plaats aan de Koranpagina.'},
  'verseSurahLimit': {'tr': '{surah} suresinde {count} ayet var.', 'en': 'Surah {surah} has {count} verses.', 'nl': 'Soera {surah} heeft {count} verzen.'},
  'memorizeBoundsUpdate': {'tr': 'Ezber aralığı başlangıçta surenin tamamını kapsar: 1’den son ayete kadar. Aralığı daraltabilirsin. Surenin ayet sayısını aşan bir değer yazıldığında sure adı ve toplam ayet sayısı gösterilir.', 'en': 'Memorization starts with the full surah range, from verse 1 to the last verse. You can narrow it. Entering a verse beyond the surah shows its name and total verse count.', 'nl': 'Het memoriseerbereik begint met de hele soera, van vers 1 tot het laatste vers. Je kunt het verkleinen. Bij een versnummer boven het maximum verschijnen de soeranaam en het totale aantal verzen.'},
  'completeRecitersUpdate': {'tr': 'Eksik kayıtlı Mehmet Emin Ay ve Mustafa Ismail kaldırıldı. Yalnızca Kur’an’ın tamamının ayet kayıtları bulunan okuyucular sunulur. Kaldırılan bir okuyucu seçiliyse Şatri’ye geçilir. Okuyucu seçimi Ayarlar’dadır.', 'en': 'Removed Mehmet Emin Ay and Mustafa Ismail because their recordings are incomplete. Only reciters with every Quran verse are offered. A removed saved reciter switches to Ash-Shatri. Choose the reciter in Settings.', 'nl': 'Mehmet Emin Ay en Mustafa Ismail zijn verwijderd omdat hun opnamen onvolledig zijn. Alleen recitatoren met alle Koranverzen zijn beschikbaar. Een verwijderde opgeslagen keuze wordt Ash-Shatri. Kies de recitator in Instellingen.'},
  'readerActionsSettingsUpdate': {'tr': 'Okuma ekranındaki Dinle ve Meal düğmeleri simge ve görünür metinle gösterilir. Meal açık kitap simgesi kullanır. Okuyucu seçimi yalnızca Ayarlar’da yapılır; okuma ekranındaki okuyucu kısayolu kaldırıldı.', 'en': 'The reader shows Listen and Translation with icons and visible labels. Translation uses an open book. Reciter selection is available only in Settings; the reader’s reciter shortcut has been removed.', 'nl': 'De lezer toont Luisteren en Vertaling met pictogrammen en tekst. Vertaling gebruikt een open boek. De recitator kan alleen in Instellingen worden gekozen; de snelkoppeling in de lezer is verwijderd.'},
  'readerListenLabel': {'tr': 'Dinle', 'en': 'Listen', 'nl': 'Luisteren'},
  'readerMealLabel': {'tr': 'Meal', 'en': 'Translation', 'nl': 'Vertaling'},
  'readerStoppingLabel': {'tr': 'Duruyor…', 'en': 'Stopping…', 'nl': 'Stopt…'},
  'readerActionsUpdate': {'tr': 'Kur’an okuyucusunun üstündeki düğmeler artık simge ve metinle gösterilir: Dinle, Meal ve Okuyucu. Meal için açık kitap, okuyucu seçimi için mikrofon ve açılır ok kullanılır. Ses çalarken Dinle düğmesi Durdur olur.', 'en': 'The Quran reader’s top buttons now show icons and visible labels: Listen, Translation and Reciter. Translation uses an open book; reciter selection uses a microphone and dropdown arrow. Listen changes to Stop during playback.', 'nl': 'De bovenste knoppen van de Koranlezer tonen nu pictogrammen en tekst: Luisteren, Vertaling en Recitator. Vertaling gebruikt een open boek; de recitatorkeuze een microfoon en uitklappijl. Tijdens afspelen verandert Luisteren in Stoppen.'},
  'mehmetAudioSource': {'tr': 'Mehmet Emin Ay · Arapça Kur’an tilaveti. Internet Archive “Mehmet Emin Ay Sure Sure Hatim” koleksiyonundaki mevcut sure kayıtları kullanılır. Ayet bazında seslendirme ve ezber desteklenmez; eksik surelerde başka bir okuyucu seç.', 'en': 'Mehmet Emin Ay · Arabic Quran recitation. Uses available surah recordings from the Internet Archive “Mehmet Emin Ay Sure Sure Hatim” collection. Verse playback and memorization are unsupported; choose another reciter for missing surahs.', 'nl': 'Mehmet Emin Ay · Arabische Koranrecitatie. Gebruikt beschikbare soeraopnamen uit de Internet Archive-collectie “Mehmet Emin Ay Sure Sure Hatim”. Afspelen per vers en memoriseren worden niet ondersteund; kies een andere recitator voor ontbrekende soera’s.'},
  'singleHomeUpdate': {'tr': 'Tek ana ekran: kişisel sayfalar ve yatay ekran geçişleri kaldırıldı. Eski sayfalardaki kısayollar ana ekran kartlarına taşınır. Meal ve dinleme kartları ortak Kur’an okuyucusundan açılır; alt çubuğa da eklenebilir. Mahir al Muaiqly ve Mehmet Emin Ay okuyucuları eklendi. Mehmet Emin Ay mevcut sure kayıtlarını sunar; ayet bazında dinleme ve ezber desteklenmez.', 'en': 'One home screen: personal pages and horizontal screen switching are removed. Their shortcuts move to home cards. Translation and listening cards open through the shared Quran reader and can also be added to the bottom bar. Added Mahir al Muaiqly and Mehmet Emin Ay. Mehmet Emin Ay offers available whole-surah recordings; verse playback and memorization are unavailable.', 'nl': 'Eén startscherm: eigen pagina’s en horizontaal wisselen zijn verwijderd. Hun snelkoppelingen worden startschermkaarten. Vertaal- en luisterkaarten openen via de gedeelde Koranlezer en kunnen ook in de onderbalk. Mahir al Muaiqly en Mehmet Emin Ay zijn toegevoegd. Mehmet Emin Ay biedt beschikbare hele soera’s; afspelen per vers en memoriseren zijn niet beschikbaar.'},
  'chapterOnlyReciter': {'tr': 'Sure bazında · sınırlı kayıt', 'en': 'Whole surahs · limited catalog', 'nl': 'Hele soera’s · beperkte catalogus'},
  'chapterOnlyVerseUnavailable': {'tr': 'Bu okuyucu yalnızca sure bazında kayıt sunuyor. Ayet dinlemek veya ezber yapmak için başka bir okuyucu seç.', 'en': 'This reciter provides whole-surah recordings only. Choose another reciter for verse playback or memorization.', 'nl': 'Deze recitator biedt alleen hele soera’s. Kies een andere recitator voor afspelen per vers of memoriseren.'},
  'wholeSurahAudioHint': {'tr': '{surah} suresi baştan dinlenecek. Bu okuyucuda sayfa veya ayet bazında ses kaydı yok. Durdur düğmesi sesi hemen durdurur.', 'en': 'Surah {surah} will play from the beginning. This reciter has no page or verse recordings. Stop ends playback immediately.', 'nl': 'Soera {surah} wordt vanaf het begin afgespeeld. Deze recitator heeft geen opnamen per pagina of vers. Stop beëindigt het afspelen direct.'},
  'verseAdvance': {'tr': 'İlerle', 'en': 'Next', 'nl': 'Verder'},
  'verseInvalidRepeats': {'tr': '1–999 arasında bir tekrar sayısı yaz.', 'en': 'Enter a repeat count from 1–999.', 'nl': 'Voer een aantal herhalingen van 1–999 in.'},
  'verseRepeatCount': {'tr': 'Tekrar sayısı', 'en': 'Repeat count', 'nl': 'Aantal herhalingen'},
  'cumulativeMemorizationUpdate': {'tr': 'Ezber tekrar sayısını seçebilirsin (varsayılan 3). Seçilen aralık başlangıç ayetinden başlayarak her aşamada bir ayet eklenerek tekrarlanır. Alttaki İlerle düğmesiyle sonraki aşamaya erken geçebilirsin. Son aşamada İlerle ezberi bitirir.', 'en': 'Choose the memorization repeat count (default 3). Starting with the first selected verse, each stage adds one verse and repeats the cumulative range. Use Next at the bottom to advance early. At the final stage, Next ends the session.', 'nl': 'Kies het aantal herhalingen voor memoriseren (standaard 3). Vanaf het eerste gekozen vers voegt elke stap één vers toe en herhaalt het hele opgebouwde bereik. Ga onderaan met Verder eerder naar de volgende stap. Bij de laatste stap beëindigt Verder de sessie.'},
  'verseActionsUpdate': {'tr': 'Dinleme ve okuma ortak Kur’an ekranında birleştirildi; kısayollar mevcut ekranlara gider. Secde ayeti vurgulanır. Bir ayete basılı tutarak Türkçe mealini balonda okuyabilir, sesini indirebilir ve dinleyebilir veya seçtiğin ayet aralığını ezber için 10 kez tekrarlatabilirsin.', 'en': 'Listening and reading now share the Quran reader; shortcuts open existing screens. Prostration verses are highlighted. Hold a verse to read its Turkish translation in a bubble, download and play its audio, or repeat a selected verse range 10 times for memorization.', 'nl': 'Luisteren en lezen delen nu de Koranlezer; snelkoppelingen openen bestaande schermen. Knielverzen worden gemarkeerd. Houd een vers ingedrukt voor de Turkse vertaling in een tekstballon, om de audio te downloaden en af te spelen, of om een versbereik 10 keer te herhalen om te memoriseren.'},
  'verseAudio': {'tr': 'Seslendir', 'en': 'Play verse', 'nl': 'Vers afspelen'},
  'verseMemorize': {'tr': 'Ezber', 'en': 'Memorize', 'nl': 'Memoriseren'},
  'verseMealSource': {'tr': 'Ali Ünal · Türkçe meal', 'en': 'Ali Ünal · Turkish translation', 'nl': 'Ali Ünal · Turkse vertaling'},
  'verseStart': {'tr': 'Başlangıç ayeti', 'en': 'First verse', 'nl': 'Eerste vers'},
  'verseEnd': {'tr': 'Bitiş ayeti', 'en': 'Last verse', 'nl': 'Laatste vers'},
  'verseRepeatHint': {'tr': '{surah}. sure · 1–{max} arasındaki ayetleri seç (iki uç dahil). Her aşamada başlangıçtan itibaren bir ayet daha eklenir. İlerle ile erken geçebilirsin; son aşamada ezber biter.', 'en': 'Surah {surah} · Choose verses from 1–{max}, including both endpoints. Each stage adds a verse to the range from the start. Next advances early; at the final stage it ends the session.', 'nl': 'Soera {surah} · Kies verzen van 1–{max}, inclusief beide grenzen. Elke stap voegt één vers toe aan het bereik vanaf het begin. Verder gaat eerder door; bij de laatste stap eindigt de sessie.'},
  'verseRepeatStart': {'tr': 'Ezbere başla', 'en': 'Start memorizing', 'nl': 'Begin met memoriseren'},
  'verseInvalidRange': {'tr': 'Geçerli bir ayet aralığı yaz. Bitiş ayeti başlangıçtan küçük olamaz.', 'en': 'Enter a valid verse range. The last verse cannot precede the first.', 'nl': 'Voer een geldig versbereik in. Het laatste vers mag niet vóór het eerste liggen.'},
  'verseStopFirst': {'tr': 'Önce çalan sesi durdur; mevcut ayetin bitmesini bekle.', 'en': 'Stop playback first and wait for the current verse to finish.', 'nl': 'Stop eerst het afspelen en wacht tot het huidige vers is afgelopen.'},
  'verseAudioUnavailable': {'tr': 'Seçili okuyucuda bu ayetin ses kaydı yok. Başka bir okuyucu seç.', 'en': 'This verse is unavailable for the selected reciter. Choose another reciter.', 'nl': 'Dit vers is niet beschikbaar voor de gekozen recitator. Kies een andere recitator.'},
  'verseDownloadHint': {'tr': '{count} ayet · {size} MB. İndirme tamamlanınca seslendirme otomatik başlar.', 'en': '{count} verses · {size} MB. Playback starts automatically after downloading.', 'nl': '{count} verzen · {size} MB. Het afspelen start automatisch na het downloaden.'},
  'verseRegionsUnavailable': {'tr': 'Ayet seçimi yüklenemedi. Okuma ekranını yeniden aç.', 'en': 'Verse selection could not load. Reopen the reader.', 'nl': 'Versselectie kon niet laden. Open de lezer opnieuw.'},
  'uniquePersonalScreensUpdate': {"tr": "Kişisel sayfalardaki aynı ekran kopyaları temizlendi; ilk eklenen ekran korunur. Her ekran yalnızca bir kez bulunabilir. Aynı ekranı yeniden ekleme denemesinde uyarı gösterilir. Ayraçlar yalnızca ayraç listesini gösterir; tam ekran okumadan çıkarken başlıklar, logo ve sayfa noktaları geri gelir.", "en": "Duplicate personal screens are removed, keeping the first occurrence. Each screen can appear only once, and trying to add it again shows a warning. Bookmarks shows only saved bookmarks, and leaving full-screen reading restores titles, the logo and page dots.", "nl": "Dubbele eigen schermen worden verwijderd; de eerste blijft behouden. Elk scherm kan maar één keer voorkomen. Opnieuw toevoegen geeft een melding. Bladwijzers toont alleen opgeslagen bladwijzers en bij het verlaten van lezen op volledig scherm komen titels, logo en paginastippen terug."},
  'bookmarksScreenFixUpdate': {"tr": "Ayraçlar ekranı yalnızca kaydedilen ayraç listesini gösterir; başlığa sure adı eklenmez. Bir ayraca dokunduğunda ilgili Kur’an sayfası açılır.", "en": "The Bookmarks screen now shows only saved bookmarks, without a surah name in its title. Tap a bookmark to open its Quran page.", "nl": "Het scherm Bladwijzers toont nu alleen opgeslagen bladwijzers, zonder soeranaam in de titel. Tik op een bladwijzer om de Koranbladzijde te openen."},
  'screenAlreadyAdded': {"tr": "Bu ekran zaten eklenmiş. Aynı ekranı tekrar ekleyemezsin.", "en": "This screen has already been added. You cannot add the same screen again.", "nl": "Dit scherm is al toegevoegd. Je kunt hetzelfde scherm niet opnieuw toevoegen."},
  'navigationAndDuplicateUpdate': {"tr": "Soldaki tanıtım ekranına veya başka bir ekrana geçerken tam ekran okuma durumu temizlenir; logo, uygulama adı, başlıklar ve sayfa noktaları doğru şekilde geri gelir. Kişisel sayfalara aynı ekran ikinci kez eklenemez; bir uyarı gösterilir.", "en": "Full-screen reading now closes when switching to the leftmost information screen or another screen, restoring the logo, app name, titles and page dots correctly. Adding the same personal screen twice is prevented with a warning.", "nl": "Lezen op volledig scherm wordt afgesloten bij het wisselen naar het meest linkse informatiescherm of een ander scherm, zodat logo, appnaam, titels en paginastippen terugkomen. Hetzelfde eigen scherm twee keer toevoegen wordt voorkomen met een melding."},
  'fullscreenTitleFixUpdate': {"tr": "Tam ekran okumadan başka bir ekrana geçerken tam ekran durumu temizlenir. Kur’an Dinle başlığı ve üstteki sayfa noktalarının gizli kalması düzeltildi.", "en": "Full-screen reading mode now clears when switching to another screen. Fixed the Quran listening title and page dots remaining hidden.", "nl": "De leesmodus op volledig scherm wordt nu afgesloten bij het wisselen naar een ander scherm. De Koranluistertitel en paginastippen blijven niet meer verborgen."},
  'compactTitlesUpdate': {"tr": "Tüm ekran başlıkları büyük harf, kalın ve daha küçük boyutta gösterilir. Başlıklar soldaki altı noktalı simgeyle uyumlu hâle getirildi; okuma için daha fazla alan bırakıldı.", "en": "All screen titles now use bold uppercase text at a smaller size, matching the six-dot handle on the left and leaving more room for reading.", "nl": "Alle schermtitels staan nu in kleinere, vette hoofdletters, passend bij de greep met zes stippen links en met meer ruimte om te lezen."},
  'Hatim duası': {'tr': 'Hatim duası', 'en': 'Khatim prayer', 'nl': 'Khatmgebed'},
  'mealFooterUpdate': {"tr": "Meal ekranındaki metin sayfası ve toplam sayfa göstergeleri, önceki/sonraki oklarıyla birlikte tek alt satırda birleştirildi. Okuma metnine daha fazla alan ayrıldı.", "en": "The translation screen’s text-page and overall-page indicators now share one bottom row with the previous/next arrows, leaving more space for reading.", "nl": "De tekstpagina- en totaalpagina-aanduidingen van het vertaalscherm staan nu samen met de vorige-/volgende-pijlen op één onderste rij, zodat er meer leesruimte is."},
  'homeHeaderOnlyUpdate': {"tr": "Logo, KuranApp adı, ayarlar ve dil seçici yalnızca en soldaki Tanıtım ve destek ekranında gösterilir. Ana sayfa dâhil diğer ekranlarda üst çubuk kaldırılarak içeriğe daha fazla alan ayrıldı. Dil ve ayarları soldaki tanıtım ekranından değiştirebilirsin.", "en": "The logo, KuranApp name, settings and language selector appear only on the leftmost About and support screen. The top bar is removed from Home and all other screens to give content more space. Change language and settings on the leftmost information screen.", "nl": "Het logo, de naam KuranApp, instellingen en de taalkeuze staan alleen op het meest linkse scherm Over de app en steun. De bovenste balk is verwijderd van Home en alle andere schermen voor meer ruimte voor inhoud. Wijzig taal en instellingen op het meest linkse informatiescherm."},
  'allScreenSwipeUpdate': {"tr": "Kur’an Dinle ekranının tamamında yatay kaydırarak ekran değiştirebilirsin. Hatim ekranında başlık, dinle/meal kontrolleri, okundu satırı ve alt çubuk ekran geçişine ayrıldı. Yalnızca okuma alanındaki kaydırma Kur’an sayfasını çevirir.", "en": "Swipe horizontally anywhere on the Quran listening screen to switch screens. On khatim screens, the header, listening/translation controls, read-status row and bottom bar switch screens. Only swipes in the reading area turn Quran pages.", "nl": "Veeg horizontaal over het Koranluisterscherm om van scherm te wisselen. Op khatmschermen wisselen de kop, luister-/vertaalbediening, leesstatusrij en onderste balk van scherm. Alleen vegen in het leesgebied slaat Koranbladzijden om."},
  'routedReaderSwipeUpdate': {"tr": "Okumaya devam et ve kısayollardan açılan Kur’an ve meal ekranlarında alt alandan ekran geçişi düzeltildi. Tam ekranda görünen alt çubuktan da ekranlar arasında kaydırabilirsin. Okuma alanı yalnızca okuma sayfasını çevirir.", "en": "Fixed bottom-area screen switching in Quran and translation readers opened from Continue reading or shortcuts. You can also swipe the visible bottom bar in full screen to switch screens. The reading area only turns reading pages.", "nl": "Schermwisselen via het onderste gebied werkt nu ook in Koran- en vertaallezers die via Verder lezen of snelkoppelingen worden geopend. Veeg in volledig scherm over de zichtbare onderste balk om van scherm te wisselen. Het leesgebied slaat alleen leesbladzijden om."},
  'readerCompactUpdate': {"tr": "Meal yazı boyutu düğmeleri ekran başlığıyla aynı satıra taşındı. Okuma alanında kaydırma sayfayı, alt alanda kaydırma ekranı değiştirir. Kur’an ve hatim sayfalarını çevirmek için en az 1 cm sürükleme gerekir. Düzen farklı telefon ve tablet boyutlarında kontrol edildi.", "en": "Translation font controls now share the screen title row. Swipe the reading area to turn pages and the bottom area to switch screens. Quran and khatim page turns require a drag of at least 1 cm. Layouts were checked at different phone and tablet sizes.", "nl": "De lettergrootteknoppen voor de vertaling staan nu naast de schermtitel. Veeg over het leesgebied om bladzijden om te slaan en onderaan om van scherm te wisselen. Koran- en khatmbladzijden vereisen minstens 1 cm slepen. De indeling is gecontroleerd op verschillende telefoon- en tabletformaten."},
  'readerGestureUpdate': {"tr": "Okuma alanında kaydırma sayfayı çevirir; alt kontrol alanında kaydırma ekranlar arasında geçiş yapar. Kur’an ve hatim sayfalarını çevirmek için en az 1 cm sürükleme gerekir. Yinelenen ekran başlıkları kaldırıldı.", "en": "Swipe the reading area to turn pages; swipe the bottom controls to switch screens. Quran and khatim page turns require a drag of at least 1 cm. Duplicate screen titles have been removed.", "nl": "Veeg over het leesgebied om bladzijden om te slaan; veeg over de onderste bediening om van scherm te wisselen. Koran- en khatmbladzijden vereisen een sleepbeweging van minstens 1 cm. Dubbele schermtitels zijn verwijderd."},
  'readingPagesFix': {'tr': 'Kur’an, hatim ve meal sayfalarında yatay kaydırma yalnızca okuma sayfasını çevirir. Diğer kişisel sayfalara üstteki noktalarla geçebilirsin. Tam ekranda uygulama başlığı, noktalar ve kişisel sayfa başlığı gizlenir.', 'en': 'Horizontal swipes on Quran, khatim and translation pages now only turn reading pages. Use the dots above to switch personal pages. Full screen hides the app header, dots and personal page header.', 'nl': 'Horizontaal vegen op Koran-, khatm- en vertaalpagina’s slaat nu alleen leesbladzijden om. Gebruik de stippen bovenaan om eigen pagina’s te wisselen. Volledig scherm verbergt de appkop, stippen en eigen paginakop.'},
  'homePageDotsUpdate': {'tr': 'Üstteki sayfa adları kaldırıldı; sayfalar arasında geçiş için yalnızca noktalar gösterilir.', 'en': 'Page labels at the top have been replaced with dots for switching between pages.', 'nl': 'De paginanamen bovenaan zijn vervangen door stippen om tussen pagina’s te wisselen.'},
  'homeFeaturePagesUpdate': {'tr': 'Kişisel sayfalar artık seçilen özelliğin tamamını gösterir. Kur’an Dinle sayfasında sure, okuyucu, ayet seçimi ve dinleme kontrolleri doğrudan kullanılabilir. Önceki kısayollar ayrı özellik sayfalarına dönüştürülür.', 'en': 'Personal pages now show the complete selected feature. Quran listening pages include surah, reciter and verse selection and playback controls directly. Existing shortcuts become separate feature pages.', 'nl': 'Eigen pagina’s tonen nu de volledige gekozen functie. Koranluisterpagina’s bevatten direct soera-, recitator- en verskeuze en afspeelbediening. Bestaande snelkoppelingen worden afzonderlijke functiepagina’s.'},
  'personalPageNumber': {'tr': 'Kısayollarım {number}', 'en': 'My shortcuts {number}', 'nl': 'Mijn snelkoppelingen {number}'},
  'deletePersonalPage': {'tr': 'Sayfayı sil', 'en': 'Delete page', 'nl': 'Pagina verwijderen'},
  'homeInformation': {'tr': 'Tanıtım ve destek', 'en': 'About and support', 'nl': 'Over de app en steun'},
  'personalPage': {'tr': 'Kısayollarım', 'en': 'My shortcuts', 'nl': 'Mijn snelkoppelingen'},
  'personalPageHint': {'tr': '+ ile bir özellik seç; bu sayfada doğrudan açılır ve yeni boş sayfa oluşur. Sayfayı silmek için üst kısmına uzun basıp çöp simgesine sürükle.', 'en': 'Choose a feature with +; it opens directly on this page and a new empty page appears. To delete a page, hold its header and drag it to the trash.', 'nl': 'Kies een functie met +; deze opent direct op deze pagina en er verschijnt een nieuwe lege pagina. Houd de paginakop ingedrukt en sleep deze naar de prullenbak om de pagina te verwijderen.'},
  'homePagesUpdate': {'tr': 'Ana ekranın solunda tanıtım ve destek, sağında ihtiyaca göre çoğalan kişisel kısayol sayfaları bulunur. + ile kısayol ekle; sayfanın üst kısmına uzun basıp çöp simgesine sürükleyerek sayfayı sil. Sayfalar ve kısayollar kaydedilir.', 'en': 'About and support are on the left of Home; personal shortcut pages grow as needed on the right. Add shortcuts with +; hold a page header and drag it to the trash to delete the page. Pages and shortcuts are saved.', 'nl': 'Links van Home staan informatie en steun; rechts groeien eigen snelkoppelingspagina’s naar behoefte. Voeg snelkoppelingen toe met +; houd een paginakop ingedrukt en sleep deze naar de prullenbak om de pagina te verwijderen. Pagina’s en snelkoppelingen worden opgeslagen.'},
  'audioSourceDetails': {
    'tr': 'Okuyucu: {reciter}. Arapça Kur’an tilaveti kayıtlarının kaynağı EveryAyah arşividir. Ayet kayıtları kullanıcının isteğiyle indirilir ve cihazda çevrimdışı dinlenir.',
    'en': 'Reciter: {reciter}. The Arabic Quran recitation recordings come from the EveryAyah archive. Verse recordings are downloaded at the user’s request for offline listening on the device.',
    'nl': 'Recitator: {reciter}. De Arabische Koranrecitaties komen uit het EveryAyah-archief. Versopnamen worden op verzoek van de gebruiker gedownload om offline op het apparaat te beluisteren.',
  },
  'audioSourceRights': {
    'tr': 'KuranApp bu kayıtlar üzerinde hak sahipliği iddia etmez. Hak sahiplerinin kimliği ve uygulamada kullanım/yeniden dağıtım izni henüz yazılı olarak doğrulanmamıştır. İzin koşullarını öğrenmek için başvuru gönderildi; yanıt bekleniyor. Kaynak bağlantısının erişilebilir olması kullanım izni anlamına gelmez.',
    'en': 'KuranApp does not claim ownership of these recordings. The rights holders and permission for use or redistribution in the app have not yet been confirmed in writing. An inquiry has been sent and a response is pending. An accessible source link does not constitute permission to use the recordings.',
    'nl': 'KuranApp claimt geen eigendom van deze opnamen. De rechthebbenden en toestemming voor gebruik of herdistributie in de app zijn nog niet schriftelijk bevestigd. Er is een aanvraag verstuurd; we wachten op antwoord. Een toegankelijke bronlink betekent geen toestemming voor gebruik.',
  },
  'Mishary ve Shatri ses kaynaklarına okuyucu ve telif/izin açıklamaları eklendi.': {
    'en': 'Reciter information and copyright/permission details were added to the Mishary and Shatri audio sources.',
    'nl': 'Informatie over de recitatoren en auteursrechten/toestemming is toegevoegd aan de audiobronnen van Mishary en Shatri.',
  },
  'Kaynaklar hakkında': {'en': 'About the sources', 'nl': 'Over de bronnen'},
  'Telif ve kullanım koşulları': {'en': 'Copyright and usage terms', 'nl': 'Auteursrecht en gebruiksvoorwaarden'},
  'Kaynaklar ve telif bilgileri sayfasındaki açıklamalar, dokunarak açılıp kapanan başlıklar altında toplandı.': {
    'en': 'Information on the sources and copyright page is now grouped under headings that expand and collapse when tapped.',
    'nl': 'De informatie over bronnen en auteursrecht staat nu onder koppen die je met een tik kunt openen en sluiten.',
  },
  'Kur’an hatlarının adları kaynak künyelerine göre Süleyman Feyzullahoğlu Hattı ve Yakupzâde İzzet Efendi Hattı olarak güncellendi. İndirilen sayfalar, ayraçlar ve okuma kayıtları korunur.': {
    'en': 'The Quran script editions are now named Süleyman Feyzullahoğlu Script and Yakupzâde İzzet Efendi Script, following their source credits. Downloaded pages, bookmarks and reading records are preserved.',
    'nl': 'De Koranschriftuitgaven heten nu Süleyman Feyzullahoğlu-schrift en Yakupzâde İzzet Efendi-schrift, volgens de bronvermelding. Gedownloade pagina’s, bladwijzers en leesgegevens blijven behouden.',
  },
  "Gizlilik a\u00e7\u0131klamalar\u0131 ses indirmeleri, yerel kay\u0131tlar, veri silme ve d\u0131\u015f ba\u011flant\u0131lar\u0131 kapsayacak \u015fekilde g\u00fcncellendi.": {"en": "Privacy information now covers audio downloads, local records, data deletion and external links.", "nl": "De privacyinformatie beschrijft nu audiodownloads, lokale gegevens, gegevens verwijderen en externe links."},
  "Ayra\u00e7 listesindeki her kayd\u0131n sa\u011f\u0131ndaki silme simgesiyle ayrac\u0131 kald\u0131rabilirsin.": {"en": "You can remove a bookmark using the delete icon on the right of each entry.", "nl": "Je kunt een bladwijzer verwijderen met het verwijderpictogram rechts van elke vermelding."},
  "Ayra\u00e7 silmeden \u00f6nce onay istenir. Vazge\u00e7ersen ayra\u00e7 ve tarih bilgisi korunur.": {"en": "Deleting a bookmark requires confirmation. Cancelling keeps the bookmark and its date.", "nl": "Je moet het verwijderen van een bladwijzer bevestigen. Bij annuleren blijven de bladwijzer en de datum behouden."},
  "Ayrac\u0131 sil": {"en": "Delete bookmark", "nl": "Bladwijzer verwijderen"},
  "Sil": {"en": "Delete", "nl": "Verwijderen"},
  "Sayfa {page} i\u00e7in ekledi\u011fin ayra\u00e7 silinsin mi?": {"en": "Delete the bookmark for page {page}?", "nl": "De bladwijzer voor pagina {page} verwijderen?"},
  "Ayra\u00e7 silinemedi. Tekrar dene.": {"en": "Could not delete the bookmark. Try again.", "nl": "De bladwijzer kon niet worden verwijderd. Probeer opnieuw."},
  "Ayra\u00e7lar kart\u0131n\u0131 a\u015fa\u011f\u0131 s\u00fcr\u00fckleyerek kapatabilirsin. Kart parma\u011f\u0131n\u0131 takip eder.": {"en": "Drag the bookmarks panel down to close it. The panel follows your finger.", "nl": "Sleep het bladwijzerpaneel omlaag om het te sluiten. Het paneel volgt je vinger."},
  "Yeni ayra\u00e7lar\u0131n eklenme tarihi ve saati art\u0131k kaydedilir ve listede g\u00f6sterilir.": {"en": "The date and time when new bookmarks are added are now saved and shown in the list.", "nl": "De datum en tijd waarop nieuwe bladwijzers worden toegevoegd worden nu opgeslagen en in de lijst getoond."},
  "Eski ayra\u00e7lar\u0131n tarihi bilinmiyorsa bu durum ayr\u0131ca belirtilir.": {"en": "Older bookmarks with an unknown creation date are labelled accordingly.", "nl": "Oudere bladwijzers met een onbekende aanmaakdatum krijgen een passende vermelding."},
  "Eklenme tarihi bilinmiyor": {"en": "Date added unknown", "nl": "Datum van toevoegen onbekend"},
  "Eklenme: {date}": {"en": "Added: {date}", "nl": "Toegevoegd: {date}"},
  "Okuma \u00f6zellikleri": {"en": "Reading features", "nl": "Leesfuncties"},
  "Meal okuma": {"en": "Translation reading", "nl": "Vertaling lezen"},
  "Ki\u015fiselle\u015ftirme ve kullan\u0131m": {"en": "Personalization and ease of use", "nl": "Personalisatie en gebruik"},
  "Son yenilikler": {"en": "Latest improvements", "nl": "Nieuwste verbeteringen"},
  "continuousMealUpdate": {"tr": "Meal okurken aşağı kaydırarak kesintisiz devam edebilirsin. Yatay kaydırma da kullanılabilir.", "en": "Scroll down to read the translation continuously. Horizontal swiping is also available.", "nl": "Scroll omlaag om de vertaling doorlopend te lezen. Horizontaal vegen blijft ook beschikbaar."},
  "aboutMealSummary": {"tr": "Türkçe meal ve açıklamaları aşağı kaydırarak kesintisiz oku. Sağa veya sola kaydırarak ya da yön düğmeleriyle bir ekranlık ilerle. Yazı boyutunu ayarla, çift dokunarak tam ekrana geç ve kaydedilen konumundan devam et. Meal içeriği Türkçedir; arayüz üç dilde kullanılabilir.", "en": "Scroll down to read the Turkish translation and explanations continuously. Swipe left or right or use the arrows to move one screenful. Adjust font size, double-tap for full screen and resume at your saved position. Translation content is Turkish; the interface is available in three languages.", "nl": "Scroll omlaag om de Turkse vertaling en toelichting doorlopend te lezen. Veeg naar links of rechts of gebruik de pijltjes om een scherm verder te gaan. Pas de lettergrootte aan, dubbeltik voor volledig scherm en hervat bij je opgeslagen positie. De vertaling is Turks; de interface is beschikbaar in drie talen."},
  "aboutSettingsSummary": {"tr": "Tema, renk, ana ekran kartlar\u0131, ki\u015fisel k\u0131sayollar ve alt \u00e7ubuk s\u0131ras\u0131n\u0131 d\u00fczenle. Ayarlar a\u00e7\u0131l\u0131p kapanan ba\u015fl\u0131klar alt\u0131nda toplan\u0131r. K\u00fc\u00e7\u00fck onay pencereleri ekran\u0131n alt\u0131na yak\u0131nd\u0131r. Yeni s\u00fcr\u00fcmlerin bilgileri son kulland\u0131\u011f\u0131n dilde g\u00f6sterilir.", "en": "Customize the theme, colors, home cards, personal shortcuts and bottom bar order. Settings are grouped into expandable sections. Compact confirmation dialogs appear near the bottom. New release notes appear in the language you last used.", "nl": "Pas het thema, de kleuren, startschermkaarten, eigen snelkoppelingen en de volgorde van de onderste balk aan. Instellingen staan in uitklapbare onderdelen. Compacte bevestigingsvensters verschijnen onderaan. Informatie over nieuwe versies verschijnt in de laatst gebruikte taal."},
  "Meal metni art\u0131k ekrana s\u0131\u011fan sayfalara b\u00f6l\u00fcn\u00fcr. Kayd\u0131r\u0131nca veya y\u00f6n d\u00fc\u011fmesine bas\u0131nca metnin devam\u0131 gelir.": {"en": "Translation text is now split into pages that fit the screen. Swipe or use the arrow buttons to continue reading without skipping text.", "nl": "De vertaling wordt nu verdeeld in pagina\u2019s die op het scherm passen. Veeg of gebruik de pijltjes om verder te lezen zonder tekst over te slaan."},
  "Yaz\u0131 boyutu, ekran y\u00f6n\u00fc ve tam ekran de\u011fi\u015fti\u011finde okudu\u011fun konum korunur.": {"en": "Your reading position is preserved when changing font size, screen orientation or full-screen mode.", "nl": "Je leespositie blijft behouden wanneer je de lettergrootte, schermstand of volledig scherm wijzigt."},
  "Meal okumas\u0131nda kald\u0131\u011f\u0131n metin konumu kaydedilir; yeniden a\u00e7\u0131nca ayn\u0131 yerden devam edebilirsin.": {"en": "Your translation reading position is saved so you can resume at the same text when reopening the app.", "nl": "Je leespositie in de vertaling wordt opgeslagen, zodat je na het opnieuw openen bij dezelfde tekst verder kunt lezen."},
  'Kapat': {'en': 'Close', 'nl': 'Sluiten'},
  "Meal sayfalar\u0131n\u0131 art\u0131k sa\u011fa ve sola kayd\u0131rarak \u00e7evirebilirsin. Tam ekranda da \u00e7al\u0131\u015f\u0131r.": {"en": "You can now swipe left and right to turn translation pages, including in full screen.", "nl": "Je kunt nu naar links en rechts vegen om vertaalpagina\u2019s om te slaan, ook op volledig scherm."},
  "Ayarlar, a\u00e7\u0131l\u0131p kapanan ana ba\u015fl\u0131klar alt\u0131nda topland\u0131.": {"en": "Settings are grouped into expandable sections.", "nl": "Instellingen zijn gegroepeerd in uitklapbare onderdelen."},
  "Alt \u00e7ubu\u011fu s\u0131f\u0131rlad\u0131\u011f\u0131nda geri solda, sureler ortada, ana sayfa sa\u011fda g\u00f6r\u00fcn\u00fcr.": {"en": "Resetting the bottom bar places Back on the left, Surahs in the middle, and Home on the right.", "nl": "Na het herstellen van de onderste balk staat Terug links, Soera\u2019s in het midden en Home rechts."},
  "Onay pencereleri k\u00fc\u00e7\u00fclt\u00fcld\u00fc ve ekran\u0131n alt\u0131na yakla\u015ft\u0131r\u0131ld\u0131. Destek se\u00e7enekleri sadele\u015ftirildi.": {"en": "Confirmation dialogs are smaller and closer to the bottom. Support options have been simplified.", "nl": "Bevestigingsvensters zijn kleiner en staan dichter bij de onderkant. De steunopties zijn vereenvoudigd."},
  "G\u00fcncelleme yenilikleri art\u0131k son kulland\u0131\u011f\u0131n dilde g\u00f6sterilir.": {"en": "Update notes now appear in the language you last used.", "nl": "Informatie over updates verschijnt nu in de taal die je het laatst hebt gebruikt."},
  "Yenilikler \u00b7 {version}": {"en": "What\u2019s new \u00b7 {version}", "nl": "Nieuw \u00b7 {version}"},
  'Görünüm ve okuma': {'en': 'Appearance and reading', 'nl': 'Weergave en lezen'},
  'Ses ve dinleme': {'en': 'Audio and listening', 'nl': 'Audio en luisteren'},
  'Kur’an hattı': {'en': 'Quran script', 'nl': 'Koranschrift'},
  'Yardım ve bilgi': {'en': 'Help and information', 'nl': 'Hulp en informatie'},
  'Destek ve geri bildirim': {'en': 'Support and feedback', 'nl': 'Steun en feedback'},
  'Seçilen sesleri sil': {'en': 'Delete selected recordings', 'nl': 'Geselecteerde opnamen verwijderen'},
  'Seçimi iptal et': {'en': 'Cancel selection', 'nl': 'Selectie annuleren'},
  '{count} seçildi': {'en': '{count} selected', 'nl': '{count} geselecteerd'},
  '{count} ses kaydı silinecek. Kur’an sayfaların ve ayraçların korunacak.': {
    'en': '{count} recordings will be deleted. Your Quran pages and bookmarks will be kept.',
    'nl': '{count} opnamen worden verwijderd. Je Koranpagina’s en bladwijzers blijven behouden.',
  },
  'Bu okuyucunun baz\u0131 sure ve ayet kay\u0131tlar\u0131 eksik.': {'en': 'Some surah and verse recordings are missing for this reciter.', 'nl': 'Bij deze recitator ontbreken enkele soera- en versopnamen.'},
  "Alt \u00e7ubu\u011fa eklemek i\u00e7in buraya b\u0131rak": {"en": "Drop here to add to the bottom bar", "nl": "Laat hier los om aan de onderste balk toe te voegen"},
  "Alt \u00e7ubu\u011fa en fazla 6 k\u0131sayol ekleyebilirsin.": {"en": "You can add up to 6 shortcuts to the bottom bar.", "nl": "Je kunt maximaal 6 snelkoppelingen aan de onderste balk toevoegen."},
  "Ana ekran k\u0131sayollar\u0131 bas\u0131l\u0131 tutup alt \u00e7ubu\u011fun \u00fcst\u00fcne s\u00fcr\u00fckleyerek eklenebilir.": {"en": "Hold a home shortcut and drag it above the bottom bar to add it.", "nl": "Houd een snelkoppeling op het startscherm ingedrukt en sleep deze boven de onderste balk om deze toe te voegen."},
  'bottomShortcutAnimatedDrop': {"tr": "Alt \u00e7ubu\u011fa s\u00fcr\u00fcklenen k\u0131sayol parma\u011f\u0131n solunda ikona d\u00f6n\u00fc\u015f\u00fcr ve b\u0131rak\u0131ld\u0131\u011f\u0131 konuma animasyonla yerle\u015fir.", "en": "Shortcuts dragged onto the bottom bar turn into an icon to the left of your finger and animate into their dropped position.", "nl": "Snelkoppelingen die je naar de onderste balk sleept, veranderen in een pictogram links van je vinger en schuiven met een animatie naar de plek waar je ze loslaat."},
  'bottomShortcutDirectDrop': {"tr": "Ana ekran k\u0131sayollar\u0131n\u0131 do\u011frudan alt \u00e7ubu\u011fa b\u0131rakarak b\u0131rakt\u0131\u011f\u0131n konuma ekleyebilirsin.", "en": "Drop home shortcuts directly onto the bottom bar to add them at that position.", "nl": "Laat snelkoppelingen van het startscherm direct op de onderste balk los om ze op die plek toe te voegen."},
  'bottomShortcutSaveFix': {"tr": "Ana ekran k\u0131sayollar\u0131 alt \u00e7ubu\u011fa eklenirken olu\u015fan tercih kaydetme hatas\u0131 d\u00fczeltildi.", "en": "Fixed the preference saving error when adding home shortcuts to the bottom bar.", "nl": "De fout bij het opslaan van voorkeuren bij het toevoegen van snelkoppelingen aan de onderste balk is verholpen."},
  'emptyDashboardAddHint': {"tr": "Ana ekran bo\u015fken ilk k\u0131sayol eklenene kadar art\u0131 d\u00fc\u011fmesinin yan\u0131nda K\u0131sayol ekle yaz\u0131s\u0131 g\u00f6sterilir.", "en": "When the home screen is empty, Add shortcut appears beside the plus button until the first shortcut is added.", "nl": "Als het startscherm leeg is, staat Snelkoppeling toevoegen naast de plusknop totdat de eerste snelkoppeling is toegevoegd."},
  'T\u00fcm k\u0131sayollar eklendi.': {'en': 'All shortcuts have been added.', 'nl': 'Alle snelkoppelingen zijn toegevoegd.'},
  'Yak\u0131nla\u015ft\u0131r': {'en': 'Zoom in', 'nl': 'Inzoomen'},
  'Uzakla\u015ft\u0131r': {'en': 'Zoom out', 'nl': 'Uitzoomen'},
  'Meal a\u00e7\u0131lamad\u0131. Tekrar dene.': {'en': 'Could not open the translation. Try again.', 'nl': 'De vertaling kon niet worden geopend. Probeer opnieuw.'},
  "Kur'an dinle": {'en': 'Listen to the Quran', 'nl': 'Koran beluisteren'},
  'Ana ekran kartları': {'en': 'Dashboard cards', 'nl': 'Kaarten op het startscherm'},
  'Kartları ana ekranda uzun basıp sürükleyerek sırala veya çöp sepetine bırak. Kaldırılan kartları buradan geri ekleyebilirsin.': {
    'en': 'Long-press and drag cards on the dashboard to reorder them or drop them in the trash. Restore removed cards here.',
    'nl': 'Houd kaarten op het startscherm ingedrukt en versleep ze om ze te rangschikken of in de prullenbak te plaatsen. Voeg verwijderde kaarten hier opnieuw toe.',
  },
  'Geri / Çıkış': {'en': 'Back / Exit', 'nl': 'Terug / Afsluiten'},
  'Meal Oku': {'en': 'Read translation', 'nl': 'Vertaling lezen'},
  'Yazıyı küçült': {'en': 'Decrease text size', 'nl': 'Tekst verkleinen'},
  'Yazıyı büyüt': {'en': 'Increase text size', 'nl': 'Tekst vergroten'},
  'İnternet bağlantısı gerekir.': {'en': 'Internet connection required.', 'nl': 'Internetverbinding vereist.'},
  'Meal açılamadı. İnternet bağlantını kontrol edip tekrar dene.': {'en': 'Could not open the translation. Check your internet connection and try again.', 'nl': 'De vertaling kon niet worden geopend. Controleer je internetverbinding en probeer het opnieuw.'},
  'Önceki': {'en': 'Previous', 'nl': 'Vorige'},
  'Sonraki': {'en': 'Next', 'nl': 'Volgende'},
  'Kur’an dinleme': {'en': 'Quran listening', 'nl': 'Koran beluisteren'},
  'listeningSummary': {
    'tr': 'Şatırî veya el-Afasi’den bir sureyi ya da seçilen ayeti dinleyebilirsin. Varsayılan okuyucuyu Ayarlar’dan seç. Kayıtları bir kez indirip çevrimdışı dinle. Durdurma isteği mevcut ayetin sonunda uygulanır.',
    'en': 'Listen to a surah or a selected verse by Ash-Shatri or Alafasy. Choose your default reciter in Settings. Download once and listen offline. Stop requests take effect at the end of the current verse.',
    'nl': 'Luister naar een soera of een gekozen vers van Ash-Shatri of Alafasy. Kies je standaardrecitator in Instellingen. Download eenmaal en luister offline. Stopverzoeken worden aan het einde van het huidige vers uitgevoerd.',
  },
  'Varsayılan Kur’an okuyucusu': {'en': 'Default Quran reciter', 'nl': 'Standaard Koranrecitator'},
  'Okuyucu': {'en': 'Reciter', 'nl': 'Recitator'},
  'Durdurma isteği ayet sonunda uygulanır.': {'en': 'Playback stops at the end of the current verse.', 'nl': 'Het afspelen stopt aan het einde van het huidige vers.'},
  'Ayet sonunda duracak': {'en': 'Stopping after this verse', 'nl': 'Stopt na dit vers'},
  'Okunan ayet: {number}': {'en': 'Current verse: {number}', 'nl': 'Huidig vers: {number}'},
  'Sure, cüz, sayfa': {'en': 'Surah, juz, page', 'nl': 'Soera, djoez, pagina'},
  'Çıkış': {'en': 'Exit', 'nl': 'Afsluiten'},
  'Yeni hatme başla': {'en': 'Start a new Quran reading', 'nl': 'Begin een nieuwe Koranlezing'},
  'Kısayolları seçebilir, sıralayabilir ve kaldırabilirsin.': {'en': 'Choose, reorder and remove shortcuts.', 'nl': 'Kies, rangschik en verwijder snelkoppelingen.'},
  'Okumaya dön': {'en': 'Return to reading', 'nl': 'Terug naar lezen'},
  'Geçmişi temizle': {'en': 'Clear history', 'nl': 'Geschiedenis wissen'},
  'Geçmiş temizlenemedi. Tekrar dene.': {'en': 'Could not clear history. Try again.', 'nl': 'De geschiedenis kon niet worden gewist. Probeer het opnieuw.'},
  'İlk çift dokunuş büyütür, ikincisi daha fazla büyütür, üçüncüsü başlangıç görünümüne döner. Kontrolleri alt kenardan yukarı kaydırarak da geri getirebilirsin.': {'en': 'The first double-tap enlarges the page, the second zooms in further, and the third restores the initial view. You can also restore the controls by swiping up from the bottom edge.', 'nl': 'De eerste dubbeltik vergroot de pagina, de tweede vergroot verder en de derde herstelt de beginweergave. Je kunt de bediening ook terugbrengen door vanaf de onderrand omhoog te vegen.'},
  'İki parmakla yakınlaştır. Kontrolleri geri getirmek için ekranın alt kenarından yukarı sürükle.': {'en': 'Pinch to zoom. Swipe up from the bottom edge to restore the controls.', 'nl': 'Knijp om te zoomen. Veeg vanaf de onderrand omhoog om de bediening terug te brengen.'},
  'Çift dokunarak tam ekrana geç. Kontrolleri geri getirmek için ekranın alt kenarından yukarı sürükle.': {'en': 'Double-tap for fullscreen. Swipe up from the bottom edge to restore the controls.', 'nl': 'Dubbeltik voor volledig scherm. Veeg vanaf de onderrand omhoog om de bediening terug te brengen.'},
  'Telefonu yatay çevir, yukarı ve aşağı kaydırarak oku. Sayfa sonunda kaydırma durur. Sayfa çevirmek için sağa veya sola sürükle.': {'en': 'Rotate your phone to landscape and scroll up and down to read. Scrolling stops at the end of the page. Swipe right or left to turn pages.', 'nl': 'Draai je telefoon horizontaal en scrol omhoog en omlaag om te lezen. Scrollen stopt aan het einde van de pagina. Veeg naar rechts of links om van pagina te wisselen.'},
  'Okundu': {'en': 'Read', 'nl': 'Gelezen'},
  'Sayfa geçiş efekti': {'en': 'Page transition effect', 'nl': 'Paginaovergang'},
  'Parmağı takip eden kaydırma': {'en': 'Slide with your finger', 'nl': 'Schuiven met je vinger'},
  'Kâğıt kıvrımı': {'en': 'Page curl', 'nl': 'Omkrullende pagina'},
  'Ana sayfa': {'en': 'Home', 'nl': 'Start'},
  'Okuma geçmişi': {'en': 'Reading history', 'nl': 'Leesgeschiedenis'},
  'Henüz okuma geçmişin yok. Okuduğun sayfalar burada görünecek.': {'en': 'No reading history yet. Pages you read will appear here.', 'nl': 'Nog geen leesgeschiedenis. Gelezen pagina’s verschijnen hier.'},
  'Bu hattı okumak için önce indir.': {'en': 'Download this edition first to read it.', 'nl': 'Download deze uitgave eerst om te lezen.'},
  'Okuma kaydı açılamadı.': {'en': 'Could not open this reading entry.', 'nl': 'Dit leesmoment kon niet worden geopend.'},
  'Okuma geçmişi kaydedilemedi.': {'en': 'Could not save reading history.', 'nl': 'De leesgeschiedenis kon niet worden opgeslagen.'},
  'Alt çubuk kısayolları': {'en': 'Bottom bar shortcuts', 'nl': 'Snelkoppelingen onderaan'},
  'Ana sayfa her zaman bulunur. Diğer kısayolları seçebilir ve sıralayabilirsin.': {'en': 'Home is always available. Choose and reorder the other shortcuts.', 'nl': 'Start blijft altijd beschikbaar. Kies en rangschik de andere snelkoppelingen.'},
  'Alt çubuğu sıfırla': {'en': 'Reset bottom bar', 'nl': 'Onderste balk herstellen'},
  "v1 · Mevcut sürüm": {"en": "v1 · Current version", "nl": "v1 · Huidige versie"},
  "v2 · Planlanan geliştirme": {"en": "v2 · Planned update", "nl": "v2 · Geplande uitbreiding"},
  "versionOneSummary": {"tr": "Üç farklı Kur’an hattı, çevrimdışı okuma, sure/cüz/sayfa araması, ayraçlar, kaldığın yerden devam etme, kişisel kısayollar, tema ve renk seçimi, sayfa çevirme ve tam ekran okuma özellikleri içerir. Türkçe, İngilizce ve Hollandaca desteklenir.", "en": "Includes three Quran script editions, offline reading, surah/juz/page search, bookmarks, reading progress, custom shortcuts, theme and color choices, page turns and fullscreen reading. Available in Turkish, English and Dutch.", "nl": "Bevat drie Koranschriftuitgaven, offline lezen, zoeken op soera/djoez/pagina, bladwijzers, leesvoortgang, eigen snelkoppelingen, thema- en kleurkeuze, pagina-animaties en schermvullend lezen. Beschikbaar in het Turks, Engels en Nederlands."},
  "versionTwoPlan": {"tr": "Sure ve seçilen ayetleri dinleme v2 için planlanıyor. Dinleme ekranı ve ses dosyalarını indirme/silme altyapısı v1’de bulunur; ses kayıtları henüz eklenmediği için şu anda dinleme yapılamaz. Kayıtlar eklendiğinde bir kez indirip çevrimdışı dinleyebilecek ve istediğinde cihazından silebileceksin.", "en": "Listening to surahs and selected verses is planned for v2. v1 includes the listening screen and audio download/removal groundwork, but recordings have not yet been added, so playback is not currently available. Once added, download recordings once, listen offline and delete them from your device whenever you wish.", "nl": "Het beluisteren van soera’s en gekozen verzen is gepland voor v2. v1 bevat het luisterscherm en de basis voor het downloaden en verwijderen van audio, maar nog geen opnamen; afspelen is daarom nog niet beschikbaar. Zodra opnamen zijn toegevoegd, kun je ze eenmaal downloaden, offline beluisteren en van je apparaat verwijderen wanneer je wilt."},
  "freeVersionPolicy": {"tr": "KuranApp tamamen ücretsiz ve reklamsızdır. Üyelik veya abonelik gerekmez. Dinleme özelliği de ücretsizdir; kahve ikramı yalnızca isteğe bağlı bir destektir.", "en": "KuranApp is entirely free and has no ads. No account or subscription is required. Listening is also free; buying a coffee is optional support only.", "nl": "KuranApp is volledig gratis en zonder advertenties. Een account of abonnement is niet nodig. Ook luisteren is gratis; een kopje koffie aanbieden is uitsluitend vrijwillige steun."},
  'Sürüm {version}': {'en': 'Version {version}', 'nl': 'Versie {version}'},
  '{edition} · Cihazdan kaldır': {'en': '{edition} · Remove from device', 'nl': '{edition} · Van apparaat verwijderen'},
  'Çıkış?': {'en': 'Exit?', 'nl': 'Afsluiten?'},
  'Tamam': {'en': 'OK', 'nl': 'OK'},
  "Sol kenardaki yaklaşık 1 cm şeride dokun: sonraki sayfa. Sağ kenardaki şeride dokun: önceki sayfa. Ortaya tek dokunmak görünümü değiştirmez.": {"en": "Tap the left 1 cm strip for the next page and the right strip for the previous page. A single tap in the center does not change the view.", "nl": "Tik op de linker strook van ongeveer 1 cm voor de volgende pagina en rechts voor de vorige. Een enkele tik in het midden verandert de weergave niet."},
  "İki parmakla yakınlaştır. Tam ekrandan çıkmak için sayfanın en üstündeyken aşağı çek veya ekranın alt kenarından yukarı sürükle.": {"en": "Pinch to zoom. To exit fullscreen, pull down at the top of the page or swipe up from the bottom edge of the screen.", "nl": "Knijp om te zoomen. Verlaat het volledige scherm door bovenaan de pagina omlaag te trekken of vanaf de onderrand van het scherm omhoog te vegen."},
  "İlk çift dokunuş çerçevenin dış sınırına, ikinci çift dokunuş iç sınırına kadar büyütür. Sonraki çift dokunuşlar bu iki görünüm arasında geçer. Çıkmak için yukarı veya aşağı çekme hareketlerini kullan.": {"en": "The first double-tap fits the outer frame; the second fits the inner frame. Further double-taps alternate these views. Use the upward or downward exit gesture to leave fullscreen.", "nl": "De eerste dubbeltik vergroot tot de buitenrand en de tweede tot de binnenrand. Daarna wisselt een dubbeltik tussen deze weergaven. Verlaat het volledige scherm met de veegbeweging omhoog of omlaag."},
  'Çift dokunarak büyüt': {'en': 'Double-tap to enlarge', 'nl': 'Dubbeltik om te vergroten'},
  'İlk çift dokunuş çerçevenin dış sınırına, ikinci çift dokunuş iç sınırına kadar büyütür. Sonraki çift dokunuşlar bu iki görünüm arasında geçer. Ortaya tek dokunarak tam ekrandan çıkabilirsin.': {'en': 'The first double-tap fits the outer frame; the second fits the inner frame. Further double-taps alternate these two views. Single-tap the center to exit fullscreen.', 'nl': 'De eerste dubbeltik vergroot tot de buitenrand, de tweede tot de binnenrand van het kader. Daarna wisselt een dubbeltik tussen deze twee weergaven. Tik eenmaal in het midden om het volledige scherm te verlaten.'},
  "Arama / sure, cüz, sayfa": {"en": "Search / surah, juz, page", "nl": "Zoeken / soera, djoez, pagina"},
  "Destek": {"en": "Support", "nl": "Steun"},
  "Uygulamanın tüm özellikleri ücretsizdir. Dilersen bir fikir, teşekkür veya kahve ikramıyla katkıda bulunabilirsin.": {"en": "All app features are free. You can optionally contribute an idea, a thank-you or a coffee.", "nl": "Alle functies zijn gratis. Je kunt vrijwillig bijdragen met een idee, een bedankje of een kopje koffie."},
  "Görünüm ve kısayollar": {"en": "Appearance and shortcuts", "nl": "Weergave en snelkoppelingen"},
  "Tema, renk ve ana ekran kısayolları": {"en": "Theme, color and home shortcuts", "nl": "Thema, kleur en snelkoppelingen op het startscherm"},
  "Tema": {"en": "Theme", "nl": "Thema"},
  "Sistem": {"en": "System", "nl": "Systeem"},
  "Açık": {"en": "Light", "nl": "Licht"},
  "Koyu": {"en": "Dark", "nl": "Donker"},
  "Renk": {"en": "Color", "nl": "Kleur"},
  "Yeşil": {"en": "Green", "nl": "Groen"},
  "Mavi": {"en": "Blue", "nl": "Blauw"},
  "Mor": {"en": "Purple", "nl": "Paars"},
  "Altın": {"en": "Gold", "nl": "Goud"},
  "Tema ve renk yalnızca arayüzü değiştirir; Kur’an sayfalarının görünümü korunur.": {"en": "Theme and color affect the interface only; Quran pages retain their original appearance.", "nl": "Thema en kleur wijzigen alleen de interface; Koranpagina’s behouden hun oorspronkelijke weergave."},
  "Ana ekran kısayolları": {"en": "Home shortcuts", "nl": "Snelkoppelingen op het startscherm"},
  "İstediğin sure veya cüzü ekle. Oklarla sıralamayı değiştirebilir, çöp kutusuyla kaldırabilirsin.": {"en": "Add any surah or juz. Use the arrows to reorder and the trash icon to remove shortcuts.", "nl": "Voeg een soera of djoez toe. Wijzig de volgorde met de pijlen en verwijder snelkoppelingen met de prullenbak."},
  "Yukarı taşı": {"en": "Move up", "nl": "Omhoog verplaatsen"},
  "Aşağı taşı": {"en": "Move down", "nl": "Omlaag verplaatsen"},
  "Kısayolu kaldır": {"en": "Remove shortcut", "nl": "Snelkoppeling verwijderen"},
  "Kısayol ekle": {"en": "Add shortcut", "nl": "Snelkoppeling toevoegen"},
  "Varsayılan kısayolları geri getir": {"en": "Restore default shortcuts", "nl": "Standaardsnelkoppelingen herstellen"},
  "Bu kısayol zaten ekli.": {"en": "This shortcut is already added.", "nl": "Deze snelkoppeling is al toegevoegd."},
  "En fazla 24 kısayol ekleyebilirsin.": {"en": "You can add up to 24 shortcuts.", "nl": "Je kunt maximaal 24 snelkoppelingen toevoegen."},
  "Cüz numarası": {"en": "Juz number", "nl": "Djoeznummer"},
  "Sonuç bulunamadı.": {"en": "No results found.", "nl": "Geen resultaten gevonden."},
  "Dinle": {"en": "Listen", "nl": "Luisteren"},
  "Sure ve ayet seçimi · İndirilen sesler": {"en": "Surah and verse selection · Downloaded audio", "nl": "Soera en vers kiezen · Gedownloade audio"},
  "Ses dosyasını indir": {"en": "Download audio", "nl": "Audio downloaden"},
  "Bir kez indir, çevrimdışı dinle. Boyut: {size} MB": {"en": "Download once, listen offline. Size: {size} MB", "nl": "Eenmaal downloaden, offline luisteren. Grootte: {size} MB"},
  "Ses dosyasını cihazımdan sil": {"en": "Delete audio from my device", "nl": "Audio van mijn apparaat verwijderen"},
  "Bu ses kaydı silinecek. Kur’an sayfaların ve ayraçların korunacak.": {"en": "This recording will be deleted. Your Quran pages and bookmarks will be kept.", "nl": "Deze opname wordt verwijderd. Je Koranpagina’s en bladwijzers blijven bewaard."},
  "Surenin tamamı": {"en": "Entire surah", "nl": "Hele soera"},
  "Seçilen ayet": {"en": "Selected verse", "nl": "Gekozen vers"},
  "Ayet numarası": {"en": "Verse number", "nl": "Versnummer"},
  "Geçerli bir ayet numarası yaz.": {"en": "Enter a valid verse number.", "nl": "Voer een geldig versnummer in."},
  "Bu seçim için ses kaydı henüz eklenmedi. Kayıtlar eklendiğinde bir kez indirip ücretsiz ve çevrimdışı dinleyebilirsin.": {"en": "Audio is not available for this selection yet. When recordings are added, download once and listen offline for free.", "nl": "Voor deze selectie is nog geen opname beschikbaar. Zodra opnamen zijn toegevoegd, kun je ze eenmaal downloaden en gratis offline beluisteren."},
  "Durdur": {"en": "Stop", "nl": "Stoppen"},
  "İndirilen sesler": {"en": "Downloaded audio", "nl": "Gedownloade audio"},
  "Henüz indirilmiş ses dosyası yok.": {"en": "No audio has been downloaded yet.", "nl": "Er is nog geen audio gedownload."},
  "Ayet {number}": {"en": "Verse {number}", "nl": "Vers {number}"},
  "Ses işlemi tamamlanamadı. Tekrar dene.": {"en": "Could not complete the audio action. Try again.", "nl": "De audiobewerking kon niet worden voltooid. Probeer het opnieuw."},
  "Bu sayfada secde ayeti var.\n{surah} · {chapter}:{verse}": {"en": "This page contains a verse of prostration.\n{surah} · {chapter}:{verse}", "nl": "Deze pagina bevat een neerwerpingsvers.\n{surah} · {chapter}:{verse}"},
  'Beğen': {'en': 'Like', 'nl': 'Vind ik leuk'},
  'Ana sayfaya dön': {'en': 'Back to home', 'nl': 'Terug naar start'},
  'Henüz tamamen indirilmiş bir hat yok.': {'en': 'No edition has been fully downloaded yet.', 'nl': 'Er is nog geen uitgave volledig gedownload.'},
  'İndirilen hatta dönülemedi. Tekrar dene.': {'en': 'Could not return to the downloaded edition. Try again.', 'nl': 'Terugkeren naar de gedownloade uitgave is mislukt. Probeer het opnieuw.'},
  "Kaynaklar ve telif bilgileri": {"tr": "Kaynaklar ve telif bilgileri", "en": "Sources and copyright", "nl": "Bronnen en auteursrechten"},
  "Reklamsız ve ücretsiz": {"tr": "Reklamsız ve ücretsiz", "en": "Free and without ads", "nl": "Gratis en zonder advertenties"},
  "sourcesIntroduction": {"tr": "KuranApp, aşağıdaki PDF baskılarından alınan sayfa görsellerini ve ön izleme kesitlerini kullanır. Bu baskıların hat, tezhip, tasarım ve yayın hakları üzerinde sahiplik iddia etmiyoruz.", "en": "KuranApp uses page images and preview excerpts from the PDF editions listed below. We do not claim ownership of their calligraphy, ornamentation, design or publication rights.", "nl": "KuranApp gebruikt pagina-afbeeldingen en voorbeelden uit de onderstaande PDF-uitgaven. Wij claimen geen eigendom van de kalligrafie, versiering, vormgeving of publicatierechten."},
  "computerRights": {"tr": "Kaynak PDF’nin 616. sayfasında “© T.C. Diyanet İşleri Başkanlığı” kaydı bulunur. Diyanet İşleri Başkanlığı Yayınları, Kur’an-ı Kerim (Rahle Boy), yayın no. 949, 5. baskı, 2018. ISBN: 978-975-19-5752-8.", "en": "Page 616 of the source PDF bears “© T.C. Diyanet İşleri Başkanlığı”. Diyanet İşleri Başkanlığı Yayınları, Kur’an-ı Kerim (Rahle Boy), publication no. 949, 5th edition, 2018. ISBN: 978-975-19-5752-8.", "nl": "Op pagina 616 van de bron-PDF staat “© T.C. Diyanet İşleri Başkanlığı”. Diyanet İşleri Başkanlığı Yayınları, Kur’an-ı Kerim (Rahle Boy), publicatienr. 949, 5e druk, 2018. ISBN: 978-975-19-5752-8."},
  "computer2Rights": {"tr": "Kaynak PDF’nin 616. sayfasında yayınlayan ve hazırlayan olarak Ahıska Yayınevi belirtilir. Aynı sayfada “© Bu eserin bütün hakları Ahıska Yayınevine aittir.” açıklaması bulunur. Mushaf hattı: Yakupzâde İzzet Efendi; tezhip: Yasemin Kama; grafik: Üveys Yücel.", "en": "Page 616 of the source PDF identifies Ahıska Yayınevi as publisher and preparer and states that all rights belong to Ahıska Yayınevi. Calligraphy: Yakupzâde İzzet Efendi; ornamentation: Yasemin Kama; graphics: Üveys Yücel.", "nl": "Op pagina 616 van de bron-PDF staat Ahıska Yayınevi vermeld als uitgever en samensteller, met de verklaring dat alle rechten bij Ahıska Yayınevi berusten. Kalligrafie: Yakupzâde İzzet Efendi; versiering: Yasemin Kama; grafische vormgeving: Üveys Yücel."},
  "husrevRights": {"tr": "Kullanıcının kaynak bilgisine göre bu hat Hüsrev Altınbaşak ve Hayrat Neşriyat ile ilişkilidir. Kullanılan 605 sayfalık taranmış PDF’de yayıncı künyesi veya açık kullanım lisansı doğrulanamamıştır. Bu atıf, bu özel PDF baskısının hak sahibinin kesin olarak doğrulandığı anlamına gelmez.", "en": "According to source information supplied by the user, this script is associated with Hüsrev Altınbaşak and Hayrat Neşriyat. Publisher details and an explicit usage licence could not be verified in the 605-page scanned PDF used here. This attribution does not establish the rights holder of this particular PDF edition.", "nl": "Volgens door de gebruiker verstrekte broninformatie is dit schrift verbonden met Hüsrev Altınbaşak en Hayrat Neşriyat. In de gebruikte gescande PDF van 605 pagina’s konden uitgeversgegevens en een expliciete gebruikslicentie niet worden bevestigd. Deze vermelding bevestigt niet wie de rechthebbende van deze specifieke PDF-uitgave is."},
  "sourcesNotice": {"tr": "Kaynak belirtmek kullanım izni yerine geçmez. Bu dosyalar için yeniden dağıtım izni veya açık lisans doğrulanmış değildir. KuranApp, adı geçen kişiler veya yayıncılar tarafından onaylanmış resmî bir uygulama değildir.", "en": "Attribution does not replace permission. Redistribution permission or an open licence has not been verified for these files. KuranApp is not an official app endorsed by the named individuals or publishers.", "nl": "Bronvermelding vervangt geen toestemming. Voor deze bestanden is geen toestemming voor herdistributie of open licentie bevestigd. KuranApp is geen officiële app die door de genoemde personen of uitgevers wordt onderschreven."},
  "noAdsPolicy": {"tr": "KuranApp ücretsizdir ve reklam içermez. İsteğe bağlı kahve desteği yalnızca uygulamanın geliştirilmesine yöneliktir; hiçbir okuma özelliği, hat veya sayfa için ödeme gerekmez.", "en": "KuranApp is free and contains no advertising. Optional coffee support is solely for app development; no payment is required for any reading feature, script edition or page.", "nl": "KuranApp is gratis en bevat geen advertenties. Vrijwillige koffiesteun is uitsluitend bedoeld voor de ontwikkeling van de app; voor geen enkele leesfunctie, schriftuitgave of pagina is betaling nodig."},
  'Hat ön izleme': {'en': 'Script preview', 'nl': 'Schriftvoorbeeld'},
  '{edition} · Hat ön izleme': {'en': '{edition} · Script preview', 'nl': '{edition} · Schriftvoorbeeld'},
  'Hüsrev hattını indir': {'en': 'Download Hüsrev edition', 'nl': 'Hüsrev-uitgave downloaden'},
  'Süleyman Feyzullahoğlu hattını indir': {'en': 'Download Süleyman Feyzullahoğlu Script', 'nl': 'Süleyman Feyzullahoğlu-schrift downloaden'},
  'Yakupzâde İzzet Efendi hattını indir': {'en': 'Download Yakupzâde İzzet Efendi Script', 'nl': 'Yakupzâde İzzet Efendi-schrift downloaden'},
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
  "Süleyman Feyzullahoğlu Hattı": {
    "en": "Süleyman Feyzullahoğlu Script",
    "nl": "Süleyman Feyzullahoğlu-schrift"
  },
  "Yakupzâde İzzet Efendi Hattı": {
    "en": "Yakupzâde İzzet Efendi Script",
    "nl": "Yakupzâde İzzet Efendi-schrift"
  },
  "Hüsrev hattı": {
    "en": "Hüsrev Script",
    "nl": "Hüsrev-schrift"
  },
  "Ahıska Yayınevi": {
    "en": "Ahıska Yayınevi",
    "nl": "Ahıska Yayınevi"
  },
  "Hüsrev Altınbaşak hattı, Hayrat Vakfı": {
    "en": "Hüsrev Altınbaşak script, Hayrat Foundation",
    "nl": "Hüsrev Altınbaşak-schrift, Hayrat Stichting"
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
    "tr": "KuranApp gizlilik politikası\nSon güncelleme: 20 Ekim 2026\n\nCihazda saklanan bilgiler\nOkuma geçmişi, son okunan sayfalar, hatim ilerlemesi, ayraçlar ve eklenme tarihleri, meal konumu, dil ve görünüm tercihleri cihazdaki uygulamaya özel depolamada saklanır. Bunlar geliştiricinin sunucusuna gönderilmez. Hesap, reklam veya analiz SDK’sı yoktur. Android bulut yedeklemesi kapalıdır.\n\nİnternet ve indirmeler\nKur’an PDF’leri kullanıcı indirmeyi başlattığında raw.githubusercontent.com üzerinden, ses kayıtları everyayah.com üzerinden HTTPS ile indirilir. İndirme sunucuları IP adresi ve istenen dosya gibi ağ bilgilerini görebilir; bu hizmetlerin kendi gizlilik uygulamaları geçerlidir. Geliştirici bu hizmetlerin günlük kayıtlarını kontrol etmez. Mobil veri ücreti oluşabilir. Hazırlanan Kur’an sayfaları, indirilen sesler ve uygulamaya dahil Türkçe meal çevrimdışı kullanılabilir.\n\nİsteğe bağlı dış bağlantılar\nDestek ve geri bildirim bağlantısını açmayı seçersen dış tarayıcı kullanılır. Destek sitesi ve varsa ödeme sağlayıcısı, senin ilettiğin mesajları veya ödeme bilgilerini kendi koşullarına göre işler. Uygulama ödeme bilgilerini işlemez.\n\nErişimler\nUygulama internet bağlantısını kullanır ve okuma sırasında ekranı açık tutabilir. Kamera, mikrofon, konum, rehber, bildirim veya genel dosya erişimi izni istemez. Dosyalar uygulamanın özel alanında tutulur.\n\nSaklama ve silme\nKayıtlar uygulama verilerini temizleyene veya uygulamayı kaldırana kadar cihazda tutulur. Ayraçları, okuma geçmişini ve indirmeleri ilgili ekranlardan silebilirsin. Tüm yerel kayıtları silmek için Android ayarlarından uygulama verilerini temizle veya uygulamayı kaldır. Uygulamada hesap bulunmadığından hesap silme işlemi yoktur. Dış hizmetlere kendin gönderdiğin bilgiler için ilgili sağlayıcıyla iletişime geç.\n\nİletişim\nGizlilik soruların için uygulamadaki Destek ve geri bildirim bölümünü kullanabilirsin.\n\nBu açıklama bir Android izin isteği değildir. Kaynaklar ve telif bilgileri uygulamada ayrıca belirtilir; uygulama yayıncıların resmî uygulaması değildir.",
    "en": "KuranApp Privacy Policy\nLast updated: 20 October 2026\n\nInformation stored on your device\nReading history, last-read pages, hatim progress, bookmarks and their creation dates, translation position, language and appearance preferences are stored in the app’s private storage on your device. They are not sent to the developer’s server. There are no accounts, ads or analytics SDKs. Android cloud backup is disabled.\n\nInternet and downloads\nQuran PDFs are downloaded from raw.githubusercontent.com when you start a download, and audio recordings from everyayah.com, over HTTPS. Download servers can see network information such as your IP address and the file requested; their own privacy practices apply. The developer does not control their logs. Mobile data charges may apply. Prepared Quran pages, downloaded audio and the bundled Turkish translation can be used offline.\n\nOptional external links\nIf you choose to open support and feedback, an external browser is used. The support website and any payment provider process messages or payment details you submit under their own terms. The app does not process payment details.\n\nAccess\nThe app uses internet access and may keep the screen awake during reading. It does not request camera, microphone, location, contacts, notification or broad file-access permissions. Files remain in the app’s private storage.\n\nRetention and deletion\nLocal records remain until you clear app data or uninstall the app. Bookmarks, reading history and downloads can be deleted in their respective screens. To erase all local records, clear app data in Android settings or uninstall the app. There are no accounts to delete. For information you submit to external services, contact the relevant provider.\n\nContact\nFor privacy questions, use Support and feedback in the app.\n\nThis information is not an Android permission request. Sources and copyright are described separately in the app; it is not an official publisher app.",
    "nl": "Privacybeleid van KuranApp\nLaatst bijgewerkt: 20 oktober 2026\n\nGegevens op je apparaat\nLeesgeschiedenis, laatst gelezen pagina’s, hatimvoortgang, bladwijzers en hun aanmaakdatums, je positie in de vertaling, taal- en weergavevoorkeuren worden opgeslagen in de privéopslag van de app op je apparaat. Deze gegevens worden niet naar de server van de ontwikkelaar gestuurd. Er zijn geen accounts, advertenties of analyse-SDK’s. Android-cloudback-ups zijn uitgeschakeld.\n\nInternet en downloads\nKoran-PDF’s worden op jouw verzoek via HTTPS gedownload van raw.githubusercontent.com en audio-opnamen van everyayah.com. Downloadservers kunnen netwerkgegevens zien, zoals je IP-adres en het opgevraagde bestand; hun eigen privacybeleid is van toepassing. De ontwikkelaar beheert hun logboeken niet. Mobiele datakosten kunnen gelden. Voorbereide Koranpagina’s, gedownloade audio en de meegeleverde Turkse vertaling zijn offline beschikbaar.\n\nVrijwillige externe links\nAls je steun en feedback opent, wordt een externe browser gebruikt. De steunwebsite en eventuele betaalprovider verwerken berichten of betaalgegevens die je zelf verstrekt volgens hun eigen voorwaarden. De app verwerkt geen betaalgegevens.\n\nToegang\nDe app gebruikt internettoegang en kan het scherm tijdens het lezen aanhouden. Er worden geen rechten gevraagd voor camera, microfoon, locatie, contacten, meldingen of algemene bestandstoegang. Bestanden blijven in de privéopslag van de app.\n\nBewaren en verwijderen\nLokale gegevens blijven bewaard totdat je de appgegevens wist of de app verwijdert. Bladwijzers, leesgeschiedenis en downloads kun je in de bijbehorende schermen verwijderen. Wis alle lokale gegevens via de Android-instellingen of verwijder de app. Er zijn geen accounts om te verwijderen. Neem voor gegevens die je zelf naar externe diensten stuurt contact op met de betreffende aanbieder.\n\nContact\nGebruik Steun en feedback in de app voor privacyvragen.\n\nDeze informatie is geen Android-toestemmingsverzoek. Bronnen en auteursrechten worden apart in de app beschreven; dit is geen officiële app van de uitgevers."
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
