# Meal extraction audit — 16 October 2026

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
