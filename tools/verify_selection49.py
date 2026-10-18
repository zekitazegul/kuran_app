"""Wi-Fi phone verification using display-relative gesture points."""
import sys
import contextlib, io
from pathlib import Path
serial,requested=sys.argv[1:3];sys.argv=['verify_phone43.py',serial,'inspect']
exec(Path('tools/verify_phone43.py').read_text(encoding='utf-8'))
action=requested
OUT=Path('build/verification49');OUT.mkdir(exist_ok=True)
def drag(reverse=False):
    metrics=adb('shell','wm','size').decode()
    w,h=map(int,re.findall(r'(\d+)x(\d+)',metrics)[-1])
    x=round(w*740/1080);ys=[round(h*y/2340) for y in [1650,1750,1850]]
    if reverse:ys.reverse()
    adb('shell',f'input touchscreen motionevent DOWN {x} {ys[0]}; sleep 0.8; '
      f'input touchscreen motionevent MOVE {x} {ys[1]}; sleep 0.2; '
      f'input touchscreen motionevent MOVE {x} {ys[2]}; sleep 0.2; '
      f'input touchscreen motionevent UP {x} {ys[2]}')
    ns=nodes();ranges=[label(n) for n in ns if re.fullmatch(r'114:\d+ – 114:\d+',label(n))]
    assert len(ranges)==1,[ascii(label(n)) for n in ns if label(n)]
    (OUT/('reverse-range.txt' if reverse else 'forward-range.txt')).write_text(ranges[0],encoding='utf-8')
    shot('reverse-selection' if reverse else 'forward-selection')
    return ranges[0]
if action=='setup':
    ns=nodes()
    if any(label(n).startswith('Yenilikler') for n in ns):tap('Kapat')
    tap('Ana sayfa');ns=nodes()
    assert any(label(n)=='Sureler' for n in ns)
    assert not any(label(n)=='Sure, cüz, sayfa' for n in ns)
    shot('home-new-icons');tap('Sureler');shot('surah-juz-page-unchanged');tap('Ana sayfa')
    tap('Okumaya devam et');ns=nodes()
    page=next(label(n) for n in ns if re.fullmatch(r'\d+ / 604',label(n)))
    (OUT/'restore-page.txt').write_text(page.split(' / ')[0])
    tap(page);field(0,'604');tap('Sayfaya git',last=True);shot('nas-before-selection')
elif action=='meal':
    selection=drag();tap('Meal Oku');ns=nodes();shot('selected-meal')
    assert any(selection in label(n) for n in ns)
    assert any('114:1' in label(n) and '114:2' in label(n) for n in ns)
    tap('Kapat')
    print('Forward range and multiple translations verified',flush=True)
elif action=='audio':
    selection=drag(True);tap('Seslendir')
    events=[];seen=set();start=time.monotonic();idle=0
    while time.monotonic()-start<90:
        with contextlib.redirect_stdout(io.StringIO()):result=media('selected-audio')
        for name in result['files']:
            if name not in seen:seen.add(name);events.append(name);print(name,flush=True)
        idle=idle+1 if result['session'] is None and not result['files'] else 0
        if len(events)>1 and idle>=3:break
        time.sleep(.15)
    (OUT/'selected-audio-order.json').write_text(json.dumps(events))
    first,last=map(int,re.findall(r'114:(\d+)',selection))
    assert events==[f'shatri_114{v:03}' for v in range(first,last+1)],events
    assert result['session'] is None
    tap('604 / 604');field(0,(OUT/'restore-page.txt').read_text());tap('Sayfaya git',last=True);tap('Ana sayfa')
    print('Reverse range, sequential Nas audio and natural completion verified; page restored',flush=True)
