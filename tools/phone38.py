import subprocess,xml.etree.ElementTree as E,sys
from pathlib import Path
adb=str(Path.home()/'AppData/Local/Android/Sdk/platform-tools/adb.exe')
def run(*args): return subprocess.check_output([adb,*args],text=True,encoding='utf-8',errors='replace')
if len(sys.argv)>1: run('shell','input',*sys.argv[1:])
run('shell','uiautomator','dump','/sdcard/window.xml');run('pull','/sdcard/window.xml','phone38.xml')
for x in E.parse('phone38.xml').iter('node'):
 label=x.get('text') or x.get('content-desc')
 if label: print(label[:120],x.get('bounds'))
