import subprocess,xml.etree.ElementTree as E,sys,re
from pathlib import Path
adb=str(Path.home()/'AppData/Local/Android/Sdk/platform-tools/adb.exe')
def run(*args): return subprocess.check_output([adb,*args],text=True,encoding='utf-8',errors='replace')
def nodes():
 run('shell','uiautomator','dump','/sdcard/window.xml');run('pull','/sdcard/window.xml','phone39.xml')
 return [(x.get('text') or x.get('content-desc'),x.get('bounds')) for x in E.parse('phone39.xml').iter('node') if x.get('text') or x.get('content-desc')]
if len(sys.argv)>1:
 if sys.argv[1]=='label':
  entries=nodes(); matches=[b for t,b in entries if t==sys.argv[2]]
  if not matches: raise RuntimeError('Label not found: '+sys.argv[2])
  l,t,r,b=map(int,re.findall(r'\d+',matches[0]));run('shell','input','tap',str((l+r)//2),str((t+b)//2))
 else: run('shell','input',*sys.argv[1:])
for label,bounds in nodes(): print(label[:150],bounds)
