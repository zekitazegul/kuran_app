"""Small explicit-device UI driver for build 45 verification."""
import re, subprocess, sys, time
from pathlib import Path
import xml.etree.ElementTree as ET

ADB = str(Path.home()/'AppData/Local/Android/sdk/platform-tools/adb.exe')
SERIAL, action, *args = sys.argv[1:]
OUT = Path(__file__).resolve().parents[1]/'build/verification45'
OUT.mkdir(exist_ok=True)
def adb(*parts):
    return subprocess.check_output([ADB,'-s',SERIAL,*parts],timeout=50)
def nodes():
    adb('shell','uiautomator','dump','/sdcard/kuran45.xml')
    data = adb('shell','cat','/sdcard/kuran45.xml')
    (OUT/'phone.xml').write_bytes(data)
    return list(ET.fromstring(data).iter('node'))
def dump():
    for n in nodes():
        label=n.get('text') or n.get('content-desc')
        if label: print(ascii((label,n.get('bounds'))))
if action=='dump': dump()
elif action=='tap':
    matches=[n for n in nodes() if args[0] in (n.get('text'),n.get('content-desc'))]
    if not matches: raise RuntimeError('Missing label: '+args[0])
    l,t,r,b=map(int,re.findall(r'\d+',matches[-1].get('bounds')))
    adb('shell','input','tap',str((l+r)//2),str((t+b)//2))
    time.sleep(.7);dump()
elif action=='shot': (OUT/(args[0]+'.png')).write_bytes(adb('exec-out','screencap','-p'))
elif action=='input':
    adb('shell','input',*args);time.sleep(.7);dump()
