"""Extract the supplied Ali Unal PDF's Turkish verse layer, excluding notes.

The source distinguishes translation (10pt), basmala (11pt), notes (9pt),
and surah headings (13pt). Reading order is geometric, within heading bands.
"""
import json
import re
import unicodedata
from pathlib import Path
import pymupdf

ROOT = Path(__file__).resolve().parents[1]
source = pymupdf.open(ROOT / 'assets/meal/ali_unal.pdf')
counts = [int(x) for x in re.findall(r'\d+', (ROOT / 'lib/data/verse_counts.dart').read_text().split('[')[1])]
events = []
for index in range(41, 1378):
    page = source[index]
    middle = page.rect.width / 2
    rows = []
    boundaries = [0]
    for block in page.get_text('dict')['blocks']:
        for line in block.get('lines', []):
            heading = next((s for s in line['spans'] if 12.9 < s['size'] < 13.1 and re.match(r'^\s*\d+[.]', s['text'])), None)
            spans = [s for s in line['spans'] if 9.5 < s['size'] < 11.2]
            if heading:
                text = heading['text']
                if line['bbox'][0] < middle < line['bbox'][2]: boundaries.append(line['bbox'][1])
            elif spans:
                text = ''
                previous = None
                for span in spans:
                    if previous and span['bbox'][0] - previous['bbox'][2] > 1.5 and text and not text.endswith(' '): text += ' '
                    text += span['text']
                    previous = span
            else:
                continue
            text = unicodedata.normalize('NFKC', text).strip()
            if text and not re.fullmatch(r'\d+', text): rows.append((line['bbox'], text, bool(heading), index + 1))
    boundaries = sorted(set(boundaries)) + [float('inf')]
    for low, high in zip(boundaries, boundaries[1:]):
        band = [r for r in rows if low <= r[0][1] < high]
        wide = any(r[0][0] < middle - 60 and r[0][2] > middle + 60 and not r[2] for r in band)
        # Footnote superscripts shift fragments of the same baseline by a few
        # points. Sort those fragments horizontally, without merging columns.
        groups = [band] if wide else [[r for r in band if r[0][0] < middle], [r for r in band if r[0][0] >= middle]]
        for group in groups:
            remaining = sorted(group, key=lambda r: r[0][1])
            while remaining:
                anchor = remaining[0][0][1]
                same = [r for r in remaining if r[0][1] <= anchor + 4]
                remaining = [r for r in remaining if r[0][1] > anchor + 4]
                events.extend(sorted(same, key=lambda r: r[0][0]))

records = []
surah = 0
verse = 0
text = []
problems = []
def finish():
    if verse and text:
        body = '\n'.join(text)
        body = re.sub(r'(\S)-\n([a-zçğıöşüâîû])', r'\1\2', body)
        body = re.sub(r'\s+', ' ', body).strip()
        body = re.sub(r'\s+([,;:.!?])', r'\1', body)
        records.append({'surah': surah, 'verse': verse, 'text': body})

for box, value, heading, pdf_page in events:
    if heading:
        number = int(re.match(r'^\s*(\d+)', value)[1])
        if number == surah + 1:
            finish()
            surah, verse, text = number, 0, []
        continue
    if not surah: continue
    # These eleven verse-number glyphs are missing or reversed in the PDF's
    # text layer. Restore only the labels; translation words are unchanged.
    if surah == 2 and verse == 93 and pdf_page == 99 and value.startswith('De ki:'):
        value = '94. ' + value
    if surah == 2 and pdf_page == 117 and re.match(r'^(42|43)[.]', value):
        value = '1' + value
    if surah == 26 and pdf_page == 869 and re.match(r'^(0[789]|1[0123])[.]', value):
        value = '2' + value
    if surah == 92 and pdf_page == 1343:
        if value.endswith('.13'):
            value = '13. ' + value[:-3].strip()
        elif value.startswith('.') and value.endswith('aittir'):
            value = value[1:] + '.'
    match = re.match(r'^(\d{1,3})[.]\s*(.*)', value)
    if match:
        number = int(match[1])
        if verse < number <= counts[surah - 1]:
            finish()
            verse, text = number, [match[2]]
        else:
            problems.append((surah, verse, number, pdf_page, value[:60]))
            if verse: text.append(value)
    elif verse:
        text.append(value)
    elif surah == 1 and value.startswith('Rahm'):
        verse, text = 1, [value]
finish()
actual = [(r['surah'], r['verse']) for r in records]
expected = [(s, v) for s, count in enumerate(counts, 1) for v in range(1, count + 1)]
print('Extracted:', len(records), 'Expected:', len(expected), 'Issues:', len(problems))
print('Issues:', ascii(problems[:30]))
(ROOT / 'assets/meal/translation-draft.json').write_text(json.dumps({'verses': records}, ensure_ascii=False, indent=2), encoding='utf-8')
if actual != expected:
    missing = sorted(set(expected) - set(actual))
    print('Missing:', missing[:100], 'Total:', len(missing))
    raise SystemExit(1)
assert not problems, 'Unexpected verse ordering must be reviewed'
assert all(r['text'] and not re.search(r'[\u0600-\u06ff]', r['text']) for r in records)
(ROOT / 'assets/meal/translation.json').write_text(json.dumps({'verses': records}, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
