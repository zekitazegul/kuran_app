import re,runpy,sys,time
from pathlib import Path
serial,mode=sys.argv[1:];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label']
out=Path('build/verification82');out.mkdir(exist_ok=True)
def tap(text,prefix=False):
 ns=[n for n in nodes() if (label(n).startswith(text) if prefix else label(n)==text)];assert ns,ascii(text)
 l,t,r,b=map(int,re.findall(r'\d+',ns[0].get('bounds')))
 adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.4)
if mode=='restore':
 tap('Men\u00fc');tap('Ayarlar');tap('G\u00f6r\u00fcn\u00fcm ve okuma',True)
tap('G\u00f6r\u00fcn\u00fcm ve k\u0131sayollar',True)
w,h=map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
for i in range(10):
 state=nodes()
 if any(label(n)=='Kemerler' for n in state): break
 adb('shell','input','swipe',str(w//2),str(round(h*.8)),str(w//2),str(round(h*.3)),'400');time.sleep(.3)
else: raise AssertionError('motif controls not found')
print('Motif choices visible.',flush=True)
tap('Kemerler' if mode=='change' else 'Geometrik')
tap('Ana sayfa')
(out/('arches-home.png' if mode=='change' else 'restored-home.png')).write_bytes(adb('exec-out','screencap','-p'))
print('Background motif changed independently; menu motif untouched.',flush=True)
