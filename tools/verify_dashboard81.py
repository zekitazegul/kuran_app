"""Verify Turkish dashboard UI and boundary handle drags on an explicit device.

Precondition: installed computer edition; preserves the current reading page.
Gesture coordinates are derived from device density and the displayed page area.
"""
import json, re, runpy, sys, time
from pathlib import Path

serial = sys.argv[1]
sys.argv = ['phone74.py', serial, 'noop']
driver = runpy.run_path('tools/phone74.py')
adb, nodes, label = driver['adb'], driver['nodes'], driver['label']
out = Path('build/verification81'); out.mkdir(exist_ok=True)

def bounds(node): return tuple(map(int, re.findall(r'-?\d+', node.get('bounds'))))
def tap(text):
    found = [n for n in nodes() if label(n) == text]
    assert found, text
    l,t,r,b = bounds(found[-1])
    adb('shell','input','tap',str((l+r)//2),str((t+b)//2)); time.sleep(.5)
def drag(x,y,xx,yy,duration=700):
    adb('shell','input','swipe',str(round(x)),str(round(y)),str(round(xx)),str(round(yy)),str(duration))
    time.sleep(.4)

tap('Ana sayfa'); tap('Menü')
state = nodes()
settings = next(n for n in state if label(n) == 'Ayarlar')
support = next(n for n in state if label(n) == 'Destek ve geri bildirim')
assert bounds(settings)[1] < bounds(support)[1]
assert all(any(label(n) == text for n in state) for text in ['Sureler','Meal Oku','Hatim','Okuma geçmişi'])
(out/'menu.png').write_bytes(adb('exec-out','screencap','-p'))
print('Menu verified; Settings before Support.', flush=True)
width,screenHeight = map(int,re.findall(r'(\d+)x(\d+)',adb('shell','wm','size').decode())[-1])
density = int(re.findall(r'\d+',adb('shell','wm','density').decode())[-1])/160
adb('shell','input','tap',str(round(width*.98)),str(round(screenHeight*.4)));time.sleep(.4)
tap('Okumaya devam et')
state = nodes()
page = next(label(n) for n in state if re.fullmatch(r'\d+ / 604',label(n)))
page_number = int(page.split()[0])
bottom = bounds(next(n for n in state if label(n) == page))[1]
top = bounds(next(n for n in state if label(n) == 'Dinle'))[3] + 2*density
height = min(bottom-top, width*779.528/538.583); top += (bottom-top-height)/2
imageWidth = height*538.583/779.528; left=(width-imageWidth)/2
regions = json.loads(Path('assets/verse_regions.json').read_text())['computer'][page_number]
region = regions[1]
verse_id = f'{region[0]}:{region[1]}'
box = region[2][0]
x=left+imageWidth*(box[0]+box[2])/2; y=top+height*(box[1]+box[3])/2
drag(x,y,x,y,800)
state=nodes(); handle=next(n for n in state if label(n)=='Bitiş ayeti');l,t,r,b=bounds(handle);hx,hy=(l+r)/2,(t+b)/2
targetY=top+height*(region[2][-1][3]+.12)
print('geometry',page,top,height,x,y,hx,hy,targetY,flush=True)
drag(hx,hy,hx,targetY)
tap('Seçilen ayetler')
selection=next(label(n) for n in nodes() if label(n).startswith(verse_id))
assert selection != verse_id, selection
print('Vertical drag at verse boundary expanded selection: '+ascii(selection),flush=True)
(out/'expanded-range.txt').write_text(selection,encoding='utf-8')
(out/'expanded-range.png').write_bytes(adb('exec-out','screencap','-p'))
adb('shell','input','keyevent','4');time.sleep(.4)
drag(x,y,x,y,800)
state=nodes(); handle=next(n for n in state if label(n)=='Bitiş ayeti');l,t,r,b=bounds(handle);hx,hy=(l+r)/2,(t+b)/2
drag(hx,hy,hx,targetY)
state=nodes(); handle=next(n for n in state if label(n)=='Bitiş ayeti');l,t,r,b=bounds(handle)
drag((l+r)/2,(t+b)/2,x,y)
tap('Seçilen ayetler')
assert any(label(n)==verse_id for n in nodes())
print('Shrinking the handle back to one verse verified.',flush=True)
adb('shell','input','keyevent','4')

time.sleep(.3)
tap('Ana sayfa')
state=nodes()
assert any(label(n)=='Okumaya devam et' for n in state)
(out/'dashboard.png').write_bytes(adb('exec-out','screencap','-p'))
print('Dashboard restored after reader test.',flush=True)
