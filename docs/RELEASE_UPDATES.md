# Release update notes

## 1.0.12+27 - 17 October 2026

- TR: Alt çubuğa sürüklenen kısayol parmağın solunda ikona dönüşür ve bırakıldığı konuma animasyonla yerleşir.
- EN: Shortcuts dragged onto the bottom bar turn into an icon to the left of your finger and animate into their dropped position.
- NL: Snelkoppelingen die je naar de onderste balk sleept, veranderen in een pictogram links van je vinger en schuiven met een animatie naar de plek waar je ze loslaat.

## 1.0.11+26 - 17 October 2026

- TR: Ana ekran kısayollarını doğrudan alt çubuğa bırakarak bıraktığın konuma ekleyebilirsin.
- EN: Drop home shortcuts directly onto the bottom bar to add them at that position.
- NL: Laat snelkoppelingen van het startscherm direct op de onderste balk los om ze op die plek toe te voegen.

- TR: Ana ekran kısayolları alt çubuğa eklenirken oluşan tercih kaydetme hatası düzeltildi.
- EN: Fixed the preference saving error when adding home shortcuts to the bottom bar.
- NL: De fout bij het opslaan van voorkeuren bij het toevoegen van snelkoppelingen aan de onderste balk is verholpen.

## 1.0.10+25 - 17 October 2026

- TR: Ana ekran boşken artı düğmesinin solunda Kısayol ekle yazısı gösterilir; ilk kısayol eklenince gizlenir.
- EN: An empty home screen shows Add shortcut to the left of the plus button; the text disappears after the first shortcut is added.
- NL: Een leeg startscherm toont Snelkoppeling toevoegen links van de plusknop; de tekst verdwijnt zodra de eerste snelkoppeling is toegevoegd.

- TR: Ana ekran kısayolları basılı tutup alt çubuğun üstüne sürükleyerek eklenebilir.
- EN: Hold a home shortcut and drag it above the bottom bar to add it.
- NL: Houd een snelkoppeling op het startscherm ingedrukt en sleep deze boven de onderste balk om deze toe te voegen.

## 1.0.9+24 — 17 October 2026

- TR: Mishary ve Shatri ses kaynaklarına okuyucu, kaynak ve telif/izin açıklamaları eklendi.
- EN: Reciter, source and copyright/permission details were added for Mishary and Shatri recordings.
- NL: Informatie over recitatoren, bronnen en auteursrechten/toestemming is toegevoegd voor Mishary en Shatri.

## 1.0.8+23 — 17 October 2026

- TR: Kaynaklar ve telif bilgileri, dokunarak açılıp kapanan başlıklar altında toplandı.
- EN: Sources and copyright information is grouped under expandable headings.
- NL: Bronnen en auteursrechtinformatie staan onder uitklapbare koppen.

## 1.0.7+22 — 17 October 2026

- TR: Hat adları, kaynak künyelerine göre Süleyman Feyzullahoğlu Hattı ve Yakupzâde İzzet Efendi Hattı olarak güncellendi. İndirilen sayfalar, ayraçlar ve okuma kayıtları korunur.
- EN: Script editions were renamed Süleyman Feyzullahoğlu Script and Yakupzâde İzzet Efendi Script according to their source credits. Downloads, bookmarks and reading records are preserved.
- NL: De schriftuitgaven heten nu Süleyman Feyzullahoğlu-schrift en Yakupzâde İzzet Efendi-schrift, volgens de bronvermelding. Downloads, bladwijzers en leesgegevens blijven behouden.

For each update installed on a phone:

1. Increment the build number in `pubspec.yaml` (and the version name when appropriate).
2. Replace `latestUpdateNotes` in `lib/widgets/update_dialog.dart` with the changes in that release.
3. Add English and Dutch translations for every note in `lib/l10n/translations.dart`.
4. Run `flutter test test/update_dialog_test.dart` and the tests relevant to the changes.

Android supplies the installed version name and build number. After restoring the saved language and completing onboarding, the home screen compares that version with the last acknowledged update. The close button saves the acknowledgement. The same installed version does not show the dialog again; a different version does.
