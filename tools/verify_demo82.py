import re,runpy,sys,time
from pathlib import Path
serial=sys.argv[1];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label']
out=Path('build/verification82');out.mkdir(exist_ok=True)
def tap(text):
 ns=[n for n in nodes() if label(n)==text];assert ns,ascii(text)
 l,t,r,b=map(int,re.findall(r'\d+',ns[-1].get('bounds')))
 adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.4)
if any(label(n)=='Kapat' for n in nodes()): tap('Kapat')
assert any('1 / 5' in label(n) for n in nodes())
(out/'demo-voice.png').write_bytes(adb('exec-out','screencap','-p'))
for i in range(4):
 tap('Devam');print('demo step',i+2,flush=True)
tap('Bitir')
assert any(label(n)=='Demo tamamland\u0131' for n in nodes())
(out/'demo-finished.png').write_bytes(adb('exec-out','screencap','-p'))
tap('Tekrar izle')
assert any('1 / 5' in label(n) for n in nodes())
for i in range(4): tap('Devam')
tap('Bitir');tap('Kapat')
assert any(label(n)=='Okumaya devam et' for n in nodes())
print('Demo completed, replayed and closed to Home.',flush=True)
