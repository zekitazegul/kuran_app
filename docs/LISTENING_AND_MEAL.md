# Dinleme ve meal

## Dinleme

- Dashboard card: Kur'an dinle. Choose the surah, then the reciter, download if needed, then listen. Downloaded recordings appear in a separate section.
- The listening screen has no translation button; translation remains accessible through its dedicated card and the surah list.

- Varsayılan okuyucu: Abu Bakr Ash-Shatri. Diğer seçenek: Mishary Rashid Alafasy.
- Okuyucu tercihi cihazda `quran-audio-v1` tercihlerine kaydedilir.
- `assets/audio.json`, EveryAyah dizinlerinden alınan 12.472 ayetin URL, dosya boyutu ve yayımlanmış MD5 özetlerini içerir. Ses dosyaları APK içinde bulunmaz.
- Bir sure, aynı okuyucunun ayet dosyalarının sıralı oynatılmasıdır. Seçilen sure/ayet indirilir; mevcut ayet dosyaları yeniden indirilmez.
- Kullanıcı durdurduğunda `requestStop` yalnızca bekleme işareti koyar. Sonraki ayete geçilip geçilmeyeceğine `MediaPlayer.onCompletion` karar verir.
- Çalma sırasında başka kaydı başlatma, okuyucu değiştirme, dosya indirme ve silme engellenir. Ekrandan çıkış da mevcut ayetin sonunda durma isteği oluşturur.
- Ağ/oynatıcı hataları ve işletim sisteminin süreci sonlandırması normal tamamlanma dışında sesin kesilmesine neden olabilir.
- `VersePlaybackQueueTest` ayet sonu davranışını JVM üzerinde sınar.

Kaynaklar:

- https://everyayah.com/data/Abu_Bakr_Ash-Shaatree_128kbps/
- https://everyayah.com/data/Alafasy_128kbps/

## Meal

- The user-provided `Aciklamali_Kuran-i_Kerim_Meali_Ali_Unal.pdf` is bundled as `assets/meal/ali_unal.pdf` (1,490 pages). It replaces the online translation website in the reader.
- `assets/meal/index.json` maps all 114 surahs to the PDF's own bookmarks. Empty divider pages before Fatiha are skipped. Surahs sharing a physical page share a destination.
- Android PdfRenderer renders one page at a time on a background executor. Original text, columns and explanatory notes are preserved. No OCR or generated paraphrase is used.
- The reader supports surah selection, reading from the beginning, previous/next PDF pages, pinch zoom and zoom buttons. PDF layout is fixed; zoom magnifies the original text.
- Current PDF page and zoom are saved separately in `meal-pdf-v1`; reopening without an explicit surah resumes the saved page. Old web-reader preferences are not applied to PDF page numbers.
- Internet is not needed. Verse-specific web links are no longer used; existing callers open the selected surah in the PDF.

## Additional reciters and reader shortcuts

- Minshawi (Minshawy_Murattal_128kbps) and Abdul Basit (Abdul_Basit_Murattal_192kbps) each provide all 6,236 verses with published MD5 checksums.
- Mustafa Ismail (Mustafa_Ismail_48kbps) has only 2,017 verse recordings at EveryAyah. His catalog is explicitly marked partial. Incomplete surahs and pages are not offered as complete recordings.
- Mustafa's directory publishes no MD5 list; downloads require the catalog's HTTPS EveryAyah URL, exact declared byte size and a readable audio duration. No checksum is fabricated.
- All 605 page-to-verse lists were extracted from the computer-script PDF and verified against all 6,236 expected verse numbers; the second computer-script PDF independently matches every page. Husrev uses the same printed pagination.
- Reader listening controls use the default reciter, download only the current page's missing recordings and keep the Quran page visible. Stop requests and page changes stop only after the current verse completes.
- Reader meal controls open the PDF at the current page's first verse. The PDF has 6,047 directly indexed verse starts; for unindexed starts the preceding indexed verse in that surah is used. Original explanatory notes remain available by turning PDF pages.

## Turkish text reader

Meal Oku displays Turkish text extracted from all 1,490 source PDF pages,
including introductions, explanations and footnotes, in geometric column order.
Arabic characters are removed; Turkish quotations and transliterations remain.
Superscript note references are retained. Extraction uses the PDF text layer,
not OCR or paraphrasing. Unusual source glyphs and page-boundary hyphenation
still need manual comparison with the original PDF.

A-/A+ controls adjust font size from 16 to 40. Lines wrap to the available
width without horizontal scrolling. The font preference is stored separately
from PDF zoom. Surah selection and reader verse links use the existing PDF
page index. Previous/next advances a source page; reopening resumes the saved
source page. Explanations continuing on the next page remain available there.
