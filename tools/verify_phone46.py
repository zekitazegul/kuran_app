"""Final reader controls, full-catalog settings and Nâs bounds smoke check."""
import sys
from pathlib import Path
serial = sys.argv[1]
sys.argv = ['verify_phone43.py', serial, 'inspect']
exec(Path('tools/verify_phone43.py').read_text(encoding='utf-8'))
OUT = Path('build/verification46'); OUT.mkdir(exist_ok=True)
ns = nodes()
if any(label(n).startswith('Yenilikler') for n in ns):
    try: tap('Kapat')
    except AssertionError: pass
if any(label(n)=='Okumaya devam et' for n in nodes()):
    try: tap('Okumaya devam et')
    except AssertionError: pass
ns = nodes()
assert all(x in [label(n) for n in ns] for x in ['Dinle','Meal'])
assert not any(label(n)=='Okuyucu' for n in ns)
shot('two-reader-actions')
page = next((label(n) for n in ns if re.fullmatch(r'\d+ / 604',label(n))), None)
if page is None:
    adb('shell','input','swipe','540','2100','540','1800','300')
    page = next(label(n) for n in nodes() if re.fullmatch(r'\d+ / 604',label(n)))
prior = Path('build/verification45/restore-page.txt')
restore = prior.read_text().strip() if page == '604 / 604' and prior.exists() else page.split(' / ')[0]
(OUT/'restore-page.txt').write_text(restore)
if page != '604 / 604': tap(page);field(0,'604');tap('Sayfaya git',last=True)
adb('shell','input','swipe','740','1650','740','1650','800')
assert any(label(n)=='114:1' for n in nodes());tap('Ezber')
fields=[n for n in nodes() if n.get('class')=='android.widget.EditText']
assert [n.get('text') for n in fields]==['1','6','3']
shot('nas-full-range');field(1,'7');tap('Ezbere başla')
assert any(label(n)=='Nâs suresinde 6 ayet var.' for n in nodes())
shot('nas-range-limit');field(1,'1');tap('Ezbere başla')
if any(label(n)=='İndirmeyi başlat' for n in nodes()):tap('İndirmeyi başlat')
assert any(label(n)=='Durdur' for n in nodes());shot('nas-stop-button');tap('Durdur')
for _ in range(6):
    if any(label(n)=='Dinle' for n in nodes()):break
    time.sleep(1)
assert any(label(n)=='Dinle' for n in nodes())
try:
    adb('shell','wm','size','2340x1080');time.sleep(1)
    assert all(x in [label(n) for n in nodes()] for x in ['Dinle','Meal'])
    assert not any(label(n)=='Okuyucu' for n in nodes());shot('reader-landscape')
finally:adb('shell','wm','size','reset')
time.sleep(1);tap('Ana sayfa')
tap('Ayarlar');tap('Görünüm ve okuma')
names=['Abu Bakr Ash-Shatri','Mahir al Muaiqly','Mishary Rashid Alafasy','Muhammad Siddiq Al-Minshawi','Abdul Basit Abdus Samad']
for _ in range(5):
    ns=nodes();selected=next((n for n in ns if label(n) in names),None)
    if selected is not None:break
    adb('shell','input','swipe','540','1800','540','900','400')
assert selected is not None
tap(label(selected));ns=nodes()
assert not any('Mehmet Emin Ay' in label(n) or 'Mustafa Ismail' in label(n) for n in ns)
assert all(any(label(n)==name for n in ns) for name in ['Abu Bakr Ash-Shatri','Mahir al Muaiqly','Mishary Rashid Alafasy','Muhammad Siddiq Al-Minshawi','Abdul Basit Abdus Samad'])
shot('complete-reciters-settings');adb('shell','input','keyevent','4');tap('Ana sayfa')
print('Two reader buttons, settings-only complete reciters, Nas defaults/limit/stop and landscape passed',flush=True)
