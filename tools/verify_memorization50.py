import sys
from pathlib import Path
serial=sys.argv[1];sys.argv=['verify_selection49.py',serial,'inspect']
exec(Path('tools/verify_selection49.py').read_text(encoding='utf-8'))
OUT=Path('build/verification50');OUT.mkdir(exist_ok=True)
ns=nodes()
if any(label(n).startswith('Yenilikler') for n in ns):tap('Kapat')
tap('Ana sayfa');tap('Okumaya devam et');ns=nodes()
page=next(label(n) for n in ns if re.fullmatch(r'\d+ / 604',label(n)))
restore=page.split(' / ')[0];(OUT/'restore-page.txt').write_text(restore)
tap(page);field(0,'604');tap('Sayfaya git',last=True)
metrics=adb('shell','wm','size').decode();w,h=map(int,re.findall(r'(\d+)x(\d+)',metrics)[-1])
y=round(h*1650/2340);xs=[round(w*x/1080) for x in [740,470,270]]
adb('shell',f'input touchscreen motionevent DOWN {xs[0]} {y}; sleep 0.8; '
    f'input touchscreen motionevent MOVE {xs[1]} {y}; sleep 0.2; '
    f'input touchscreen motionevent MOVE {xs[2]} {y}; sleep 0.2; '
    f'input touchscreen motionevent UP {xs[2]} {y}')
ns=nodes();assert any(label(n)=='114:1 – 114:3' for n in ns)
assert any(label(n)=='Ezber' for n in ns);shot('selected-memorization-menu');tap('Ezber')
ns=nodes();fields=[n for n in ns if n.get('class')=='android.widget.EditText']
assert [n.get('text') for n in fields[:2]]==['1','3']
if len(fields)<3:
    adb('shell','input','swipe',str(w//2),str(round(h*.64)),str(w//2),str(round(h*.42)),'400')
    ns=nodes();fields=[n for n in ns if n.get('class')=='android.widget.EditText']
assert fields[-1].get('text')=='3';shot('selected-defaults-1-3-repeat3')
field(len(fields)-1,'1');tap('Ezbere başla')
events=[];sessions=set();start=time.monotonic();idle=0
while time.monotonic()-start<100:
    with contextlib.redirect_stdout(io.StringIO()):result=media('selected-cumulative-audio')
    if result['session'] and result['session'][0] not in sessions:
        sessions.add(result['session'][0]);events.append(result['files'][0]);print(events[-1],flush=True)
    idle=idle+1 if result['session'] is None and not result['files'] else 0
    if len(events)>1 and idle>=3:break
    time.sleep(.15)
assert events==['shatri_114001','shatri_114001','shatri_114002','shatri_114001','shatri_114002','shatri_114003'],events
(OUT/'cumulative-order.json').write_text(json.dumps(events))
tap('604 / 604');field(0,restore);tap('Sayfaya git',last=True);tap('Ana sayfa')
print('Selected Nas 1–3 defaults 1/3/3 and cumulative 1;1,2;1,2,3 verified; page restored',flush=True)
