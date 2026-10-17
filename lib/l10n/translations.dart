import 'package:flutter/material.dart';
import '../services/app_language.dart';

const translations = <String, Map<String, String>>{
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
  "aboutMealSummary": {"tr": "T\u00fcrk\u00e7e meal ve a\u00e7\u0131klamalar\u0131 ekrana s\u0131\u011fan sayfalar halinde oku. Sa\u011fa veya sola kayd\u0131rarak ya da y\u00f6n d\u00fc\u011fmeleriyle metnin devam\u0131na ge\u00e7. Yaz\u0131 boyutunu ayarla, \u00e7ift dokunarak tam ekrana ge\u00e7 ve kaydedilen metin konumundan okumaya devam et. Meal i\u00e7eri\u011fi T\u00fcrk\u00e7edir; uygulama aray\u00fcz\u00fc \u00fc\u00e7 dilde kullan\u0131labilir.", "en": "Read the Turkish translation and explanations in pages that fit the screen. Swipe left or right or use the arrow buttons to continue the text. Adjust font size, double-tap for full screen and resume at your saved text position. Translation content is Turkish; the app interface is available in three languages.", "nl": "Lees de Turkse vertaling en toelichting in pagina\u2019s die op het scherm passen. Veeg naar links of rechts of gebruik de pijltjes om verder te lezen. Pas de lettergrootte aan, dubbeltik voor volledig scherm en hervat bij je opgeslagen tekstpositie. De vertaling is Turks; de app-interface is beschikbaar in drie talen."},
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
    "tr": "• İnternet: Seçtiğiniz hattın Kur’an PDF’sini yalnızca indirmeyi başlattığınızda raw.githubusercontent.com üzerinden HTTPS ile indirir. Dosyanın SHA-256 özeti doğrulanır, ardından sayfalar cihazınızda görüntüye dönüştürülür. İndirme tamamlanınca çevrimdışı okuyabilirsiniz. Sunucu, bağlantı sırasında IP adresinizi görebilir. Mobil veri ücretleri uygulanabilir; Wi-Fi önerilir.\n\n• Uygulamaya özel depolama: İndirilen sayfalar, ayraçlar ve son okunan sayfa cihazınızda saklanır. Galerinize veya diğer dosyalarınıza erişilmez. Uygulamayı kaldırmak bu kayıtları siler. Android bulut yedeklemesi bu sürümde kapalıdır.\n\n• Ekran: Uygulama ön plandayken ekran otomatik kapanmaz. Bu, pil tüketimini artırabilir. Başka uygulamaya geçtiğinizde normal ekran zaman aşımı geri gelir.\n\nKamera, mikrofon, konum, rehber, bildirim veya genel dosya erişimi izni istenmez. Hesap, reklam ve analiz SDK’sı bulunmaz. Okuma geçmişiniz ve ayraçlarınız tarafımızca bir sunucuya gönderilmez.\n\nİsteğe bağlı geliştirici desteği etkinleştirildiğinde ödeme, seçiminizle dış tarayıcıdaki sağlayıcı üzerinden yapılır. Ödeme bilgileri uygulamada işlenmez; sağlayıcının gizlilik koşulları geçerlidir.\n\nBu ekran bir Android izin talebi değildir; uygulamanın davranışlarını açıklayan bilgilendirmedir.\n\nKaynaklar: Kullanıcının sağladığı bilgisayar hatlı Diyanet PDF’si, Bilgisayar Hattı 2 ve Hüsrev hattı PDF’leri. Her hattın sayfa düzeni, sure dizini ve okuma kayıtları ayrıdır. Baskı ve hak bilgileri için Kaynaklar ve telif bilgileri bölümüne bakınız. Yayıncıların onayladığı resmî bir uygulama değildir.",
    "en": "• Internet: The PDF for your selected Quran script is downloaded over HTTPS from raw.githubusercontent.com only when you start the download. Its SHA-256 is verified before the pages are rendered on your device. After preparation you can read offline. The download server may see your IP address. Mobile data charges may apply; Wi-Fi is recommended.\n\n• Private app storage: Pages, bookmarks and the last-read page stay on your device. The app does not access your gallery or other files. Uninstalling deletes these records. Android cloud backup is disabled in this version.\n\n• Screen: The screen stays awake while the app is in the foreground. This can increase battery use. Normal screen timeout resumes when you switch to another app.\n\nNo camera, microphone, location, contacts, notification or broad file-access permissions are requested. There are no accounts, ads or analytics SDKs. We do not send your reading history or bookmarks to a server.\n\nIf optional developer support is enabled, you choose whether to open an external payment provider in your browser. This app does not process payment details; the provider’s privacy terms apply.\n\nThis is an information screen, not an Android permission request.\n\nSources: The computer-script Diyanet PDF, Computer Script 2 PDF and Hüsrev PDF supplied by the user. Each edition has its own layout, surah index and reading records. See Sources and copyright for edition and rights information. This is not an official app endorsed by the publishers.",
    "nl": "• Internet: De PDF van het gekozen Koranschrift wordt alleen op jouw verzoek via HTTPS van raw.githubusercontent.com gedownload. De SHA-256 wordt gecontroleerd voordat de pagina’s op je apparaat worden weergegeven. Daarna kun je offline lezen. De downloadserver kan je IP-adres zien. Mobiele datakosten kunnen gelden; wifi wordt aanbevolen.\n\n• Privéopslag van de app: Pagina’s, bladwijzers en de laatst gelezen pagina blijven op je apparaat. De app heeft geen toegang tot je galerij of andere bestanden. Verwijderen van de app wist deze gegevens. Android-cloudback-ups zijn in deze versie uitgeschakeld.\n\n• Scherm: Het scherm blijft aan zolang de app op de voorgrond staat. Dit kan meer batterij verbruiken. De normale schermtime-out keert terug als je naar een andere app gaat.\n\nEr worden geen rechten gevraagd voor camera, microfoon, locatie, contacten, meldingen of algemene bestandstoegang. Er zijn geen accounts, advertenties of analyse-SDK’s. Je leesgeschiedenis en bladwijzers worden niet naar onze server gestuurd.\n\nAls vrijwillige ontwikkelaarssteun beschikbaar is, kies je zelf of je een externe betaalwebsite opent. De app verwerkt geen betaalgegevens; de privacyvoorwaarden van de aanbieder gelden.\n\nDit is een informatiescherm, geen Android-toestemmingsverzoek.\n\nBronnen: De door de gebruiker verstrekte Diyanet-PDF in computerschrift, Computerschrift 2 en Hüsrev-PDF. Elke editie heeft een eigen indeling, soera-index en leesgegevens. Zie Bronnen en auteursrechten voor uitgave- en rechteninformatie. Dit is geen officiële app die door de uitgevers is goedgekeurd."
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
