import sys
from pathlib import Path
serial=sys.argv[1];sys.argv=['verify_phone43.py',serial,'inspect']
exec(Path('tools/verify_phone43.py').read_text(encoding='utf-8'))
OUT=Path('build/verification48');OUT.mkdir(exist_ok=True)
ns=nodes()
if any(label(n)=='Durdur' for n in ns):
    tap('Durdur');time.sleep(4)
tap('Ana sayfa');tap('Okumaya devam et')
ns=nodes();page=next(label(n) for n in ns if re.fullmatch(r'\d+ / 604',label(n)))
restore='25' if page=='604 / 604' else page.split(' / ')[0]
tap(page);field(0,'604');tap('Sayfaya git',last=True)
adb('shell','input','swipe','740','1650','740','1650','800')
assert any(label(n)=='114:1' for n in nodes())
tap('Ezber');tap('Ezbere başla');ns=nodes();shot('nas-reader-listening')
ns=nodes()
if any(label(n)=='İndirmeyi başlat' for n in ns):tap('İndirmeyi başlat')
for _ in range(15):
    time.sleep(1);r=media('nas-reader-audio')
    if r['session']:break
assert r['session'] and any('_114' in x for x in r['files']),r
ns=nodes();assert any(label(n)=='Durdur' for n in ns)
tap('Durdur')
for _ in range(8):
    if any(label(n)=='Dinle' for n in nodes()):break
    time.sleep(.5)
assert any(label(n)=='Dinle' for n in nodes())
tap('604 / 604');field(0,restore);tap('Sayfaya git',last=True);tap('Ana sayfa')
print('Nas reader playback and verse-end stop verified; previous page restored',flush=True)
