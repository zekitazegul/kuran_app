import re,runpy,sys,time
from pathlib import Path
serial=sys.argv[1];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label'];out=Path('build/verification86');out.mkdir(exist_ok=True)
w,h=map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
density=int(re.findall(r'\d+',adb('shell','wm','density').decode())[-1])/160
def rect(n):return tuple(map(int,re.findall(r'\d+',n.get('bounds'))))
def center(text):
 ns=[n for n in nodes() if label(n)==text];assert ns,ascii(text)
 l,t,r,b=rect(ns[-1]);return (l+r)//2,(t+b)//2
def tap(text):
 x,y=center(text);adb('shell','input','tap',str(x),str(y));time.sleep(.4)
def bar_top():
 ns=[n for n in nodes() if label(n)=='Ana sayfa'];return rect(ns[-1])[1]
def drag(source,target=None,menuTarget=False,trash=False):
 x,y=center(source)
 adb('shell','input','motionevent','DOWN',str(x),str(y));time.sleep(1.2)
 adb('shell','input','motionevent','MOVE',str(x+1),str(y+1));time.sleep(.3)
 try:
  if trash:xx,yy=w//2,round(bar_top()-60*density)
  elif menuTarget:
   top=bar_top();ns=[n for n in nodes() if label(n)==target and rect(n)[3]<top]
   l,t,r,b=rect(ns[-1]);xx,yy=(l+r)//2,(t+b)//2
  else:xx,yy=center(target)
  for i in range(1,9):adb('shell','input','motionevent','MOVE',str(round(x+(xx-x)*i/8)),str(round(y+(yy-y)*i/8)))
  time.sleep(.25)
 finally:adb('shell','input','motionevent','UP',str(xx),str(yy))
 time.sleep(.5)
adb('shell','am','start','-n','com.zekitazegul.kuranapp/.MainActivity');time.sleep(.5)
state=nodes()
if any(label(n)=='Kapat' for n in state):tap('Kapat')
state=nodes()
if any(label(n)=='Bitir' for n in state):tap('Bitir');tap('Kapat')
assert any(label(n)=='Okumaya devam et' for n in nodes())
assert not any(label(n)=='K\u0131sayol ekle veya kald\u0131r' for n in nodes())
(out/'solid-home.png').write_bytes(adb('exec-out','screencap','-p'))
tap('Men\u00fc')
top=bar_top();home=next(n for n in nodes() if label(n)=='Ana sayfa' and rect(n)[3]<top)
if center('Sureler')[1]>rect(home)[1]:drag('Sureler','Ana sayfa',menuTarget=True)
assert not any(label(n).startswith('Alt gezinme \u00e7ubu\u011funa') for n in nodes())
drag('Sureler','Sayfaya git')
assert center('Sayfaya git')[1]<center('Sureler')[1]
(out/'long-press-reordered.png').write_bytes(adb('exec-out','screencap','-p'))
print('Long press immediately reordered the icon-free menu.',flush=True)
drag('Sureler','Ana sayfa',menuTarget=True)
assert center('Sureler')[1]<center('Sayfaya git')[1]
drag('Sureler','Ana sayfa')
top=bar_top()
assert any(label(n)=='Sureler' and rect(n)[1]>=top for n in nodes())
print('Menu-to-bottom drag created a shortcut without a pin button.',flush=True)
adb('shell','input','tap',str(round(w*.99)),str(round(h*.4)));time.sleep(.4)
drag('Sureler',trash=True)
top=bar_top()
assert not any(label(n)=='Sureler' and rect(n)[1]>=top for n in nodes())
assert not any(label(n)=='K\u0131sayol ekle veya kald\u0131r' for n in nodes())
(out/'final-home.png').write_bytes(adb('exec-out','screencap','-p'))
print('Original menu order and bottom shortcuts restored; plus remains hidden.',flush=True)
