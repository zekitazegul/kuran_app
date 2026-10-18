"""Explicit-device smoke checks. UI actions preserve app data and downloads."""
import json, re, subprocess, sys, time
from pathlib import Path
import xml.etree.ElementTree as ET

ADB = 'C:/Users/Zek/AppData/Local/Android/sdk/platform-tools/adb.exe'
SERIAL, action = sys.argv[1:3]
OUT = Path('build/verification43'); OUT.mkdir(exist_ok=True)
def adb(*args): return subprocess.check_output([ADB,'-s',SERIAL,*args],timeout=45)
def nodes():
    adb('shell','uiautomator','dump','/sdcard/kuran43.xml')
    data = adb('shell','cat','/sdcard/kuran43.xml')
    (OUT/'phone.xml').write_bytes(data)
    return list(ET.fromstring(data).iter('node'))
def label(n): return n.get('text') or n.get('content-desc') or ''
def tap(text, partial=False, last=False):
    found=[n for n in nodes() if (text in label(n) if partial else text==label(n))]
    assert found, ascii(text)
    n=found[-1 if last else 0]
    l,t,r,b=map(int,re.findall(r'\d+',n.get('bounds')))
    adb('shell','input','tap',str((l+r)//2),str((t+b)//2));time.sleep(.8)
def media(name):
    data=adb('shell','dumpsys','media.player').decode(errors='replace')
    match=re.search(r'packageName: com\.zekitazegul\.kuranapp.*?connId\((\d+)\).*?state\((\d+)\).*?renderer\(paused\((\d+)\)',data,re.S)
    result={'session':match.groups() if match else None,'files':sorted(set(re.findall(r'files/audio-v1/([a-z0-9_]+)\.audio',data)))}
    (OUT/(name+'.json')).write_text(json.dumps(result,indent=2))
    print(json.dumps(result),flush=True);return result
def shot(name): (OUT/(name+'.png')).write_bytes(adb('exec-out','screencap','-p'))
def field(index, value):
    fields=[n for n in nodes() if n.get('class')=='android.widget.EditText']
    n=fields[index];l,t,r,b=map(int,re.findall(r'\d+',n.get('bounds')))
    adb('shell','input','tap',str((l+r)//2),str((t+b)//2))
    adb('shell','input','keyevent','123');adb('shell','input','keyevent','67')
    adb('shell','input','text',value);adb('shell','input','keyevent','4');time.sleep(.5)
if action=='maher':
    result=media('maher-playing');assert any('maher_' in s for s in result['files']) and result['session'][2]=='0'
    shot('maher-playing')
elif action=='mehmet':
    labels=[label(n) for n in nodes()]
    if 'Durdur' in labels: tap('Durdur')
    for _ in range(8):
        if 'Durdur' not in [label(n) for n in nodes()] and 'Ayet sonunda duracak' not in [label(n) for n in nodes()]:break
        time.sleep(1)
    tap('Okuyucu'); tap('Mehmet Emin Ay',partial=True)
    tap("Kur'an dinle")
    assert any('baştan dinlenecek' in label(n) for n in nodes())
    shot('whole-surah-notice');tap('Seslendir');tap('İndirmeyi başlat')
    for _ in range(12):
        result=media('mehmet-playing')
        if any('mehmet_emin_ay_surah_001' in s for s in result['files']):break
        time.sleep(2)
    assert result['session'] and result['session'][2]=='0'
    assert any('mehmet_emin_ay_surah_001' in s for s in result['files'])
    shot('mehmet-playing');tap('Durdur');time.sleep(1)
    assert media('mehmet-stopped')['session'] is None
    tap('Okuyucu');tap('Abu Bakr Ash-Shatri')
elif action=='meal':
    tap('Ana sayfa');shot('single-home')
    assert not any('Kişisel sayfa' in label(n) or 'Tanıtım ve destek' in label(n) for n in nodes())
    tap('Meal Oku',partial=True)
    time.sleep(2);shot('meal-from-home')
    assert any(label(n)=='Sureler' for n in nodes())
    tap('Ana sayfa')
    assert any(label(n)=='KuranApp' for n in nodes())
    # A horizontal gesture cannot create or select another home page.
    adb('shell','input','swipe','900','1000','150','1000','400')
    assert any(label(n)=='KuranApp' for n in nodes())
    print('Single home, translation card and return passed',flush=True)
elif action=='ezber':
    fields=[n for n in nodes() if n.get('class')=='android.widget.EditText']
    assert fields[2].get('text')=='3'
    shot('memorize-default3');field(1,'3');field(2,'1');tap('Ezbere başla')
    if any(label(n)=='İndirmeyi başlat' for n in nodes()):tap('İndirmeyi başlat')
    events=[];seen=set();start=time.monotonic()
    while time.monotonic()-start<90:
        r=media('memorize-current')
        if r['session'] and r['session'][0] not in seen:
            seen.add(r['session'][0]);events.append(r)
        if len(events)>=6 and r['session'] is None:break
        time.sleep(.2)
    (OUT/'memorize-sequence.json').write_text(json.dumps(events,indent=2))
    assert [r['files'][0] for r in events]==['shatri_001001','shatri_001001','shatri_001002','shatri_001001','shatri_001002','shatri_001003'],events
    print('Cumulative range 1–3 with custom count 1 passed',flush=True)
elif action=='early':
    adb('shell','input','swipe','450','1015','450','1015','800');tap('Ezber');field(1,'3');tap('Ezbere başla')
    before=media('early-before');assert before['session']
    tap('İlerle');after=media('early-after')
    assert after['session'] and after['session'][0]!=before['session'][0]
    rotation=adb('shell','settings','get','system','user_rotation').decode().strip()
    auto=adb('shell','settings','get','system','accelerometer_rotation').decode().strip()
    try:
        adb('shell','settings','put','system','accelerometer_rotation','0')
        adb('shell','settings','put','system','user_rotation','1');time.sleep(1)
        assert any(label(n)=='İlerle' for n in nodes());shot('memorize-early')
        tap('İlerle');third=media('early-third');assert third['session'] and third['session'][0]!=after['session'][0]
        tap('İlerle');assert media('early-finished')['session'] is None
    finally:
        adb('shell','settings','put','system','user_rotation',rotation)
        adb('shell','settings','put','system','accelerometer_rotation',auto)
    print('Early advance and final completion passed, including landscape',flush=True)
elif action=='nas':
    adb('shell','input','swipe','740','1650','740','1650','800')
    assert any(label(n)=='114:1' for n in nodes());tap('Ezber');field(1,'3');field(2,'1');tap('Ezbere başla')
    if any(label(n)=='İndirmeyi başlat' for n in nodes()):tap('İndirmeyi başlat')
    events=[];seen=set();start=time.monotonic()
    while time.monotonic()-start<60:
        r=media('nas-current')
        if r['session'] and r['session'][0] not in seen:
            seen.add(r['session'][0]);events.append(r)
        if len(events)>=6 and r['session'] is None:break
        time.sleep(.2)
    (OUT/'nas-sequence.json').write_text(json.dumps(events,indent=2))
    assert [r['files'][0] for r in events]==['shatri_114001','shatri_114001','shatri_114002','shatri_114001','shatri_114002','shatri_114003'],events
    print('Nas cumulative 1–3 passed',flush=True)
elif action=='landscape':
    try:
        adb('shell','wm','size','2340x1080');time.sleep(1)
        shot('reader-landscape');ns=nodes()
        assert any('604 / 604'==label(n) for n in ns)
        tap('Ana sayfa');shot('home-landscape')
        assert any(label(n)=='KuranApp' for n in nodes())
    finally: adb('shell','wm','size','reset')
    print('Landscape display metrics verified and restored',flush=True)
