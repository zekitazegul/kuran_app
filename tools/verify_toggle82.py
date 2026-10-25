import re,runpy,sys,time
from pathlib import Path
serial=sys.argv[1];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label']
out=Path('build/verification82');out.mkdir(exist_ok=True)
def tap(text):
 ns=[n for n in nodes() if label(n)==text];assert ns,ascii(text)
 l,t,r,b=map(int,re.findall(r'\d+',ns[-1].get('bounds')))
 adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.4)
tap('K\u0131sayol ekle veya kald\u0131r')
assert any(label(n)=='Alt gezinme k\u0131sayollar\u0131' for n in nodes())
(out/'rounded-navigation-sheet.png').write_bytes(adb('exec-out','screencap','-p'))
tap('K\u0131sayol ekle veya kald\u0131r')
assert not any(label(n)=='Alt gezinme k\u0131sayollar\u0131' for n in nodes())
print('Second plus tap closes the bottom sheet.',flush=True)
