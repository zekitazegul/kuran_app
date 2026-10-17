"""Extract PDF text in geometric reading order, retaining Turkish notes."""
import json
import re
import unicodedata
from pathlib import Path
import pymupdf

root = Path(__file__).resolve().parents[1]
document = pymupdf.open(root / 'assets/meal/ali_unal.pdf')
arabic = re.compile(r'[\u0600-\u06ff\u0750-\u077f\u08a0-\u08ff\ufb50-\ufdff\ufe70-\ufeff]')
pages = []
for page in document:
    middle = page.rect.width / 2
    lines = []
    boundaries = [0]
    wide_ranges = []
    note_markers = []
    for block in page.get_text('dict', clip=pymupdf.INFINITE_RECT())['blocks']:
        # Mixed pages have full-width introductions/verses above two-column
        # notes. Limit full-width layout to that block's vertical interval.
        body_lines = [l for l in block.get('lines', []) if l['bbox'][1] >= 10
                      and any(s['size'] < 12.9 and s['text'].strip() for s in l['spans'])]
        box = (min((l['bbox'][0] for l in body_lines), default=middle),
               min((l['bbox'][1] for l in body_lines), default=0),
               max((l['bbox'][2] for l in body_lines), default=middle),
               max((l['bbox'][3] for l in body_lines), default=0))
        crosses_gutter = False
        for anchor in body_lines:
            row = sorted([l['bbox'] for l in body_lines if abs(l['bbox'][1] - anchor['bbox'][1]) <= 4])
            if not row:
                continue
            left, right = row[0][0], row[0][2]
            for segment in row[1:]:
                if segment[0] <= right + 3:
                    right = max(right, segment[2])
                else:
                    crosses_gutter |= left < middle - 60 and right > middle + 60
                    left, right = segment[0], segment[2]
            crosses_gutter |= left < middle - 60 and right > middle + 60
        if crosses_gutter:
            boundaries.extend([box[1] - 0.1, box[3] + 0.1])
            wide_ranges.append((box[1] - 0.1, box[3] + 0.1))
        for line in block.get('lines', []):
            # Exclude running page headers and page numbers, retain all body sizes.
            if line['bbox'][1] < 10:
                continue
            spans = line['spans']
            fragments = []
            for span in spans:
                value = unicodedata.normalize('NFKC', arabic.sub('', span['text']))
                if span['size'] < 8.5 and value.strip().isdigit():
                    value = value.translate(str.maketrans('0123456789', '⁰¹²³⁴⁵⁶⁷⁸⁹'))
                fragments.append(value)
            text = ''.join(fragments).strip()
            if text and text.isdigit() and all(s['size'] < 8.5 for s in spans):
                note_markers.append((line['bbox'], text))
                continue
            if not text or not any('LATIN' in unicodedata.name(c, '') for c in text):
                continue
            # A decorative initial is body text, not a heading.
            heading = len(text) > 1 and any(s['size'] >= 12.9 for s in spans)
            if heading and line['bbox'][0] < middle < line['bbox'][2]:
                boundaries.extend([line['bbox'][1], line['bbox'][3] + 0.1])
            lines.append((line['bbox'], text, heading, block['number']))
    for box, text in note_markers:
        candidates = [r for r in lines if abs(r[0][1] - box[1]) <= 8
                      and -1 <= box[0] - r[0][2] <= 4]
        if candidates:
            target = min(candidates, key=lambda r: abs(box[0] - r[0][2]))
            lines[lines.index(target)] = (target[0], target[1] + text, target[2], target[3])
    # PDF drop caps are separate blocks. Attach them to the first body line
    # geometrically before sorting or deciding paragraph boundaries.
    for initial in list(lines):
        box, text, heading, number = initial
        if len(text) != 1 or not text.isupper() or box[3] - box[1] < 20:
            continue
        candidates = [r for r in lines if r is not initial and not r[2]
                      and box[1] - 2 <= r[0][1] <= box[1] + 8
                      and -1 <= r[0][0] - box[2] <= 8]
        if candidates:
            target = min(candidates, key=lambda r: abs(r[0][1] - box[1]))
            lines[lines.index(target)] = (target[0], text + target[1], target[2], target[3])
            lines.remove(initial)
    boundaries = sorted(set(boundaries)) + [float('inf')]
    paragraphs = []
    for low, high in zip(boundaries, boundaries[1:]):
        band = [r for r in lines if low <= r[0][1] < high]
        wide = any(start <= low < end for start, end in wide_ranges)
        groups = [band] if wide else [[r for r in band if (r[0][0] + r[0][2]) / 2 < middle], [r for r in band if (r[0][0] + r[0][2]) / 2 >= middle]]
        for group in groups:
            paragraph_start = len(paragraphs)
            remaining = sorted(group, key=lambda r: r[0][1])
            ordered = []
            while remaining:
                anchor = remaining[0][0][1]
                same = [r for r in remaining if r[0][1] <= anchor + 4]
                remaining = [r for r in remaining if r[0][1] > anchor + 4]
                ordered.extend(sorted(same, key=lambda r: r[0][0]))
            current = []
            block_id = None
            def finish():
                if current:
                    body = '\n'.join(current)
                    body = re.sub(r'(\w)-\n([a-zçğıöşü])', r'\1\2', body)
                    body = re.sub(r'\s+', ' ', body).strip()
                    paragraphs.append(body)
            for box, text, heading, number in ordered:
                if number != block_id or heading:
                    finish()
                    current = []
                current.append(text)
                block_id = number
                if heading:
                    finish()
                    current = []
                    block_id = None
            finish()
            # A paragraph can continue from the foot of the left column at
            # the top of the right. Keep that continuation in one paragraph.
            if paragraph_start > 0 and len(paragraphs) > paragraph_start:
                previous, following = paragraphs[paragraph_start - 1:paragraph_start + 1]
                if following[0].islower() and not re.search(r'[.!?:;][”\"’)]?$', previous):
                    separator = '' if previous.endswith('-') else ' '
                    paragraphs[paragraph_start - 1:paragraph_start + 1] = [previous.removesuffix('-') + separator + following]
    pages.append(paragraphs)
assert len(pages) == 1490
assert not any(arabic.search(t) for p in pages for t in p)
(root / 'assets/meal/turkish-pages.json').write_text(json.dumps(pages, ensure_ascii=False), encoding='utf-8')
print('Pages:', len(pages), 'Paragraphs:', sum(map(len, pages)))
