import sys
from pathlib import Path
serial=sys.argv[1];sys.argv=['verify_phone43.py',serial,'inspect']
exec(Path('tools/verify_phone43.py').read_text(encoding='utf-8'))
OUT=Path('build/verification46');OUT.mkdir(exist_ok=True)
if any(label(n).startswith('Yenilikler') for n in nodes()):
    try:tap('Kapat')
    except AssertionError:pass
tap('Ana sayfa');tap('Hatim',last=True)
ns=nodes();labels=[label(n) for n in ns]
assert all(x in labels for x in ['Dinle','Meal','Okundu'])
assert 'Okuyucu' not in labels
assert any(re.fullmatch(r'\d+/605',x) for x in labels)
shot('hatim-compact')
for text in ['Dinle','Meal','Okundu']:
    n=next(n for n in ns if label(n)==text)
    print(text, n.get('bounds'),flush=True)
try:
    adb('shell','wm','size','2340x1080');time.sleep(1)
    assert all(x in [label(n) for n in nodes()] for x in ['Dinle','Meal','Okundu'])
    shot('hatim-landscape')
finally:adb('shell','wm','size','reset')
time.sleep(1);tap('Ana sayfa');tap('Ayarlar');tap('Görünüm ve okuma')
names=['Abu Bakr Ash-Shatri','Mahir al Muaiqly','Mishary Rashid Alafasy','Muhammad Siddiq Al-Minshawi','Abdul Basit Abdus Samad']
for _ in range(6):
    ns=nodes();selected=next((n for n in ns if label(n) in names),None)
    if selected is not None:break
    adb('shell','input','swipe','540','1800','540','900','400')
assert selected is not None;tap(label(selected));ns=nodes()
assert not any('Mehmet Emin Ay' in label(n) or 'Mustafa Ismail' in label(n) for n in ns)
assert all(any(label(n)==name for n in ns) for name in names)
shot('complete-reciters-settings');tap('Ana sayfa')
print('Compact portrait/landscape bars and settings-only complete reciters passed',flush=True)
