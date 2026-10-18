import sys
from pathlib import Path
serial=sys.argv[1];sys.argv=['verify_phone43.py',serial,'inspect']
exec(Path('tools/verify_phone43.py').read_text(encoding='utf-8'))
OUT=Path('build/verification47');OUT.mkdir(exist_ok=True)
def click(node):
    l,t,r,b=map(int,re.findall(r'\d+',node.get('bounds')))
    adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.6)
def choose(text,partial=False):
    ns=nodes();n=next(n for n in ns if (text in label(n) if partial else text==label(n)))
    click(n)
ns=nodes()
if any(label(n).startswith('Yenilikler') for n in ns):
    close=next((n for n in ns if label(n)=='Kapat'),None)
    if close is not None:click(close)
choose('Ana sayfa');ns=nodes()
assert not any('Ali Ünal' in label(n) for n in ns)
meal=next(n for n in ns if label(n)=='Meal Oku')
other=next(n for n in ns if label(n)=='Sure, cüz, sayfa')
def height(n):
    l,t,r,b=map(int,re.findall(r'\d+',n.get('bounds')));return b-t
assert abs(height(meal)-height(other))<=2
shot('equal-home-cards');choose('Okumaya devam et');ns=nodes()
listen=next(n for n in ns if label(n)=='Dinle');meal=next(n for n in ns if label(n)=='Meal')
left=list(map(int,re.findall(r'\d+',listen.get('bounds'))))[0]
right=list(map(int,re.findall(r'\d+',meal.get('bounds'))))[2]
assert abs((left+right)/2-540)<=2
assert not any(label(n)=='Okuyucu' for n in ns)
shot('centered-reader-actions')
choose('Ana sayfa');choose('Ayarlar');ns=nodes()
section=next(n for n in ns if 'Ses ve dinleme' in label(n))
if 'Genişletildi' not in label(section):click(section)
for _ in range(5):
    ns=nodes();fieldnode=next((n for n in ns if 'Varsayılan Kur’an okuyucusu' in label(n)),None)
    if fieldnode is not None:break
    adb('shell','input','swipe','540','1800','540','900','400')
assert fieldnode is not None;click(fieldnode);ns=nodes()
names=['Abu Bakr Ash-Shatri','Mahir al Muaiqly','Mishary Rashid Alafasy','Muhammad Siddiq Al-Minshawi','Abdul Basit Abdus Samad']
assert all(any(name in label(n) for n in ns) for name in names)
assert not any('Mehmet Emin Ay' in label(n) or 'Mustafa Ismail' in label(n) for n in ns)
shot('five-complete-reciters');choose('Ana sayfa')
print('Equal home cards, centered slim reader actions and complete reciter settings verified',flush=True)
