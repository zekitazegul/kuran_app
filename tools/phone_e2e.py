"""Read and interact with the connected test phone via ADB."""
import json, re, subprocess, sys, time
from pathlib import Path
import xml.etree.ElementTree as ET
ADB = str(Path.home() / 'AppData/Local/Android/sdk/platform-tools/adb.exe')
SERIAL = '192.168.68.102:43425'
OUT = Path(__file__).resolve().parents[1] / 'build/e2e'
OUT.mkdir(parents=True, exist_ok=True)
def adb(*args):
    return subprocess.check_output([ADB, '-s', SERIAL, *args], timeout=40)
def nodes():
    adb('shell','uiautomator','dump','/sdcard/kuran-e2e.xml')
    data = adb('shell','cat','/sdcard/kuran-e2e.xml')
    (OUT/'screen.xml').write_bytes(data)
    return list(ET.fromstring(data).iter('node'))
def dump():
    for n in nodes():
        if n.get('text') or n.get('content-desc'):
            print(ascii((n.get('text'),n.get('content-desc'),n.get('bounds'))))
def tap(label):
    navigation = label.startswith('nav:')
    if navigation: label = label[4:]
    matches=[n for n in nodes() if label in (n.get('text','')+' '+n.get('content-desc',''))]
    if not matches: raise RuntimeError('Not visible: '+label)
    n = max(matches, key=lambda n:int(re.findall(r'\d+', n.get('bounds'))[1])) if navigation else min(matches,key=lambda n:len(n.get('text','')+' '+n.get('content-desc','')))
    x1,y1,x2,y2=map(int,re.findall(r'\d+',n.get('bounds')))
    adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
    time.sleep(.7)
if __name__=='__main__':
    action=sys.argv[1]
    if action=='dump':dump()
    elif action=='tap':tap(sys.argv[2]);dump()
    elif action=='back':adb('shell','input','keyevent','4');time.sleep(.7);dump()
    elif action=='swipe':adb('shell','input','swipe',*sys.argv[2:]);time.sleep(.6);dump()
    elif action=='type':adb('shell','input','text',sys.argv[2]);time.sleep(.6);dump()
    elif action=='shot':
        (OUT/(sys.argv[2]+'.png')).write_bytes(adb('exec-out','screencap','-p'))
