# Meal extraction audit — 16 October 2026

## Updated audit - 20 October 2026, build 53

All 1,490 pages were regenerated; 516 pages changed. Translation and note
font layers now establish separate vertical reading bands before column
ordering. Both verse columns are read before either note column. Paragraph
continuation cannot cross the boundary between those bands.

Verified source examples: PDF page 452 (Tevbe 6, `isteğiyle` followed by the
complete verse, then note 1), page 453 (verse 8, `müşriklerin`, and note 2,
`âdeta`), page 451 (`O’nun`) and page 454 (`mü’min`). Words split after an
apostrophe or parenthesis are now rejoined. The same repair changed 116
of the 6,236 verse translations in translation.json, preserving the complete
letter sequence of every verse. All verse identifiers remain complete and
ordered. A decorative initial on page 20 stays attached to its paragraph.

The independent audit now checks whether output ranges for translation and
notes overlap when the PDF places notes below the translation. This catches
cross-block note insertion that the original inventory/block checks missed.
Quoted verse text in notes is matched to its later occurrence. All current
audit checks pass; no internal `- lowercase` word splits remain in page text.
Flutter regressions cover the Tevbe examples and the existing cases below.

The checks validate extraction, not the author's translation or the semantic
accuracy of the source PDF. Source page boundaries remain intact; a word
split across two PDF pages is still continued on the next source page.

## Original audit - 16 October 2026

All 1,490 PDF pages were compared against turkish-pages.json by
`python tools/audit_meal.py`. Machine-readable result: meal-audit.json.

Checks: per-page Latin character inventory (after Unicode normalization),
source text-block character sequence, Arabic exclusion, isolated initials,
and unexpectedly empty pages. Latest result: zero warnings in those checks.
These checks do not prove semantic accuracy or independently validate every
paragraph boundary, number, punctuation mark, or cross-block reading order.

Fixed during the audit:
- Body lines near the top were incorrectly excluded as running headers.
- Latin letters such as isolated Â were excluded by an incomplete alphabet filter.
- Right-column lines near the gutter were assigned to the left column.
- A heading and drop cap sharing a PDF block introduced false layout boundaries.
- Full-width text and multi-column fragments sharing a block were confused;
  full-width layout now requires horizontal continuity through the gutter.
- Separate superscript note markers are attached to their neighboring text.
- PDF clipping could truncate text outside the nominal page rectangle;
  extraction reads the complete text layer instead.

Regression checks cover Fatiha introduction and notes 1–2, Bakara introduction,
Hadid heading position, and verse 25/26 order on source page 1336, as well as
large-font wrapping and persistence.

Remaining limitation: the reader retains source page boundaries. 101 source
pages end with a hyphenated word that continues on the next page. Internal
line-break hyphenation was joined; cross-page words remain split across pages.
The scan also emits a MuPDF stitching-function warning from the source PDF;
text extraction completes for all pages. No OCR or invented text was used.
