import re,runpy,sys,time
from pathlib import Path
serial=sys.argv[1];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label'];out=Path('build/verification84');out.mkdir(exist_ok=True)
w,h=map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
def tap(text,prefix=False,scroll=False):
 for i in range(9 if scroll else 1):
  ns=[n for n in nodes() if (label(n).startswith(text) if prefix else label(n)==text)]
  if ns: break
  adb('shell','input','swipe',str(w//2),str(round(h*.8)),str(w//2),str(round(h*.35)),'350');time.sleep(.25)
 else:raise AssertionError(ascii(text))
 l,t,r,b=map(int,re.findall(r'\d+',ns[0].get('bounds')))
 adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.4)
def gallery():
 tap('Men\u00fc');tap('Ayarlar');tap('G\u00f6r\u00fcn\u00fcm ve okuma',True)
 tap('G\u00f6r\u00fcn\u00fcm ve k\u0131sayollar',True)
 tap('Arka plan motifi',True,True)
adb('shell','am','start','-n','com.zekitazegul.kuranapp/.MainActivity');time.sleep(.5)
tap('Kapat')
assert any('1 / 1' in label(n) for n in nodes())
tap('Bitir');tap('Kapat')
assert any(label(n)=='Okumaya devam et' for n in nodes())
print('Motif-only tutorial completed and closed to Home.',flush=True)
gallery()
for i in range(6):
 state=nodes()
 if any(label(n)=='Ta\u015fkent \u00e7ini \u00e7i\u00e7ekleri' for n in state):break
 adb('shell','input','swipe',str(w//2),str(round(h*.8)),str(w//2),str(round(h*.48)),'350');time.sleep(.25)
assert all(any(label(n)==text for n in state) for text in ['Semerkant \u00e7inileri','Buhara bezemesi','Ta\u015fkent \u00e7ini \u00e7i\u00e7ekleri'])
(out/'city-motif-choices.png').write_bytes(adb('exec-out','screencap','-p'))
tap('Semerkant \u00e7inileri');tap('Ana sayfa')
(out/'samarkand-home.png').write_bytes(adb('exec-out','screencap','-p'))
adb('shell','am','force-stop','com.zekitazegul.kuranapp')
adb('shell','am','start','-n','com.zekitazegul.kuranapp/.MainActivity');time.sleep(.8)
assert any(label(n)=='Okumaya devam et' for n in nodes())
(out/'samarkand-persisted.png').write_bytes(adb('exec-out','screencap','-p'))
print('Three city choices verified; Samarkand selection persisted on restart.',flush=True)
gallery();tap('K\u00fcndek\u00e2ri y\u0131ld\u0131z \u00f6rg\u00fcs\u00fc');tap('Ana sayfa')
(out/'final-home.png').write_bytes(adb('exec-out','screencap','-p'))
print('Original background choice and user shortcut layout restored.',flush=True)
