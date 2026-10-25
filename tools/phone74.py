"""Explicit Wi-Fi device verification. Reject stale UI dumps and preserve app data."""
import re, subprocess, sys, time
from pathlib import Path
import xml.etree.ElementTree as ET

ADB = str(Path.home() / 'AppData/Local/Android/sdk/platform-tools/adb.exe')
serial, action, *args = sys.argv[1:]
OUT = Path('build/verification74'); OUT.mkdir(parents=True, exist_ok=True)

def adb(*parts):
    return subprocess.check_output([ADB, '-s', serial, *parts], timeout=45)

def nodes():
    for attempt in range(3):
        adb('shell', 'rm', '-f', '/sdcard/kuran74.xml')
        adb('shell', 'uiautomator', 'dump', '/sdcard/kuran74.xml')
        try:
            data = adb('shell', 'cat', '/sdcard/kuran74.xml')
            tree = ET.fromstring(data)
            (OUT / 'phone.xml').write_bytes(data)
            return list(tree.iter('node'))
        except (subprocess.CalledProcessError, ET.ParseError):
            if attempt == 2: raise
            time.sleep(.5)

def label(node): return node.get('text') or node.get('content-desc') or ''
def dump():
    for node in nodes():
        if label(node): print(ascii((label(node), node.get('bounds'))))

if action == 'dump': dump()
elif action == 'tap':
    matches = [n for n in nodes() if label(n) == args[0]]
    assert matches, ascii(args[0])
    left, top, right, bottom = map(int, re.findall(r'\d+', matches[-1].get('bounds')))
    adb('shell', 'input', 'tap', str((left+right)//2), str((top+bottom)//2))
    time.sleep(.6); dump()
elif action == 'shot':
    (OUT / (args[0] + '.png')).write_bytes(adb('exec-out', 'screencap', '-p'))
elif action == 'gesture':
    width, height = map(int, re.findall(r'(\d+)x(\d+)', adb('shell', 'wm', 'size').decode())[-1])
    x1, y1, x2, y2 = map(float, args[:4])
    adb('shell', 'input', 'swipe', str(round(x1*width)), str(round(y1*height)),
        str(round(x2*width)), str(round(y2*height)), args[4] if len(args)>4 else '500')
    time.sleep(.5); dump()
