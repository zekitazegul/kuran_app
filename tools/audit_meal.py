"""Independently audit every PDF page against the generated Turkish text."""
import collections
import json
import re
import unicodedata
from pathlib import Path
import pymupdf

root = Path(__file__).resolve().parents[1]
pages = json.loads((root / 'assets/meal/turkish-pages.json').read_text(encoding='utf-8'))
doc = pymupdf.open(root / 'assets/meal/ali_unal.pdf')
def letters(text):
    return ''.join(c for c in unicodedata.normalize('NFKC', text) if 'LATIN' in unicodedata.name(c, ''))
report = {'pages': len(doc), 'coverage_errors': [], 'block_order_warnings': [], 'layer_order_errors': [], 'arabic_pages': [], 'isolated_letters': [], 'empty_text_pages': []}
for i, page in enumerate(doc):
    source = []
    blocks = []
    layers = {'verse': [], 'note': []}
    for block in page.get_text('dict', clip=pymupdf.INFINITE_RECT())['blocks']:
        lines = []
        for line in block.get('lines', []):
            if line['bbox'][1] < 10: continue
            text = ''.join(s['text'] for s in line['spans'])
            if letters(text): lines.append(text)
            sizes = [s['size'] for s in line['spans'] if letters(s['text'])]
            if sizes and max(sizes) < 12.9 and len(letters(text)) > 15:
                layers['verse' if max(sizes) >= 9.5 else 'note'].append((line['bbox'], letters(text)))
        source.extend(lines)
        if lines: blocks.append((block['number'], letters(''.join(lines))))
    output = ' '.join(pages[i])
    expected, actual = collections.Counter(letters(''.join(source))), collections.Counter(letters(output))
    if expected != actual:
        report['coverage_errors'].append({'page': i+1, 'missing': dict(expected-actual), 'extra': dict(actual-expected)})
    normalized = letters(output)
    # Independent cross-block check: where all notes sit below translation,
    # their output ranges must not overlap. The former character/block audit
    # passed even with a complete note inserted inside a hyphenated verse.
    if layers['verse'] and layers['note']:
        verse_bottom = max(box[3] for box, _ in layers['verse'])
        note_top = min(box[1] for box, _ in layers['note'])
        if verse_bottom <= note_top:
            positions = {}
            for layer, lines in layers.items():
                # Notes can quote an entire verse line. Use the later copy
                # for notes and the earlier copy for translation.
                locate = normalized.find if layer == 'verse' else normalized.rfind
                positions[layer] = [(locate(value), len(value)) for _, value in lines]
            missing = any(start < 0 for found in positions.values() for start, _ in found)
            if missing or max(start + size for start, size in positions['verse']) > min(start for start, _ in positions['note']):
                report['layer_order_errors'].append(i + 1)
    for block, value in blocks:
        if len(value)>20 and value not in normalized:
            report['block_order_warnings'].append({'page': i+1, 'block': block, 'start': value[:100]})
    if re.search(r'[\u0600-\u06ff\ufb50-\ufdff\ufe70-\ufeff]',output): report['arabic_pages'].append(i+1)
    if any(len(p)==1 for p in pages[i]): report['isolated_letters'].append(i+1)
    if source and not pages[i]: report['empty_text_pages'].append(i+1)
(root / 'docs/meal-audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print({k:len(v) if isinstance(v,list) else v for k,v in report.items()})
print('First order warnings:',ascii(report['block_order_warnings'][:8]))
if any(report[key] for key in ('coverage_errors', 'block_order_warnings', 'layer_order_errors', 'arabic_pages', 'isolated_letters', 'empty_text_pages')):
    raise SystemExit(1)
