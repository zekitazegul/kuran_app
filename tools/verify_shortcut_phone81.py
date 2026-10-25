import re,runpy,sys,time
from pathlib import Path
serial=sys.argv[1];sys.argv=['phone74.py',serial,'noop'];d=runpy.run_path('tools/phone74.py')
adb,nodes,label=d['adb'],d['nodes'],d['label']
out=Path('build/verification81');out.mkdir(exist_ok=True)
def rect(n):return tuple(map(int,re.findall(r'\d+',n.get('bounds'))))
def center(text):
 found=[n for n in nodes() if label(n)==text];assert found,ascii(text)
 l,t,r,b=rect(found[-1]);return (l+r)//2,(t+b)//2
def tap(text):
 x,y=center(text);adb('shell','input','tap',str(x),str(y));time.sleep(.5)
def drag(source,target):
 x,y=source;xx,yy=target
 adb('shell','input','motionevent','DOWN',str(x),str(y));time.sleep(.7)
 try:
  for step in range(1,9):
   px=round(x+(xx-x)*step/8);py=round(y+(yy-y)*step/8)
   adb('shell','input','motionevent','MOVE',str(px),str(py))
  time.sleep(.7);adb('shell','input','motionevent','MOVE',str(xx+1),str(yy));time.sleep(.2)
 finally:adb('shell','input','motionevent','UP',str(xx+1),str(yy))
 time.sleep(.6)
tap('Ana sayfa');menu=center('Men\u00fc');bottom=center('K\u0131sayol ekle veya kald\u0131r')
tap('Men\u00fc');drag(center('Hatim'),bottom)
density=int(re.findall(r'\d+',adb('shell','wm','density').decode())[-1])/160
width,height=map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
assert any(label(n)=='Hatim' and rect(n)[1]>=height-80*density for n in nodes()),'Hatim missing from bottom bar'
print('Menu Hatim copied into bottom navigation.',flush=True)
width,height=map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
adb('shell','input','tap',str(round(width*.99)),str(round(height*.4)));time.sleep(.5)
drag(center('Hatim'),menu)
assert any(label(n)=='Bu k\u0131sayol burada zaten var.' for n in nodes()),'Duplicate warning missing'
(out/'duplicate-shortcut.png').write_bytes(adb('exec-out','screencap','-p'))
print('Hover opened menu and duplicate warning was displayed.',flush=True)
adb('shell','input','tap',str(round(width*.99)),str(round(height*.4)));time.sleep(.4)

drag(center('Hatim'),(width//2,round(height-116*density)))
assert not any(label(n)=='Hatim' and rect(n)[1]>=height-80*density for n in nodes())
print('Long-press deletion verified; original navigation restored.',flush=True)
