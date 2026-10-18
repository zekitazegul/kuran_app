"""Observe actual native player sessions without modifying application data."""
import json, re, subprocess, sys, time
from pathlib import Path

serial, expected, x, y = sys.argv[1:]
expected = int(expected)
adb = str(Path.home()/'AppData/Local/Android/sdk/platform-tools/adb.exe')
out=Path(__file__).resolve().parents[1]/'build/verification41'
def run(*args): return subprocess.check_output([adb,'-s',serial,*args],timeout=30).decode('utf8',errors='replace')
run('shell','input','tap',x,y)
start=time.monotonic()
events=[]; seen=set(); last_active=start
while time.monotonic()-start<240:
    data=run('shell','dumpsys','media.player')
    match=re.search(r'packageName: com\.zekitazegul\.kuranapp.*?connId\((\d+)\).*?state\((\d+)\).*?renderer\(paused\((\d+)\)',data,re.S)
    files=sorted(set(re.findall(r'files/audio-v1/([a-z0-9_]+)\.audio',data)))
    if match:
        last_active=time.monotonic()
        cid=match.group(1)
        if cid not in seen:
            seen.add(cid)
            event={'elapsed':round(time.monotonic()-start,2),'connection':cid,'state':match.group(2),'paused':match.group(3),'files':files}
            events.append(event); print(json.dumps(event),flush=True)
    elif events and time.monotonic()-last_active>2:
        break
    time.sleep(.35)
result={'expectedSessions':expected,'observedSessions':len(events),'elapsed':round(time.monotonic()-start,2),'events':events,'finished':match is None}
(out/f'audio-{expected}-sessions.json').write_text(json.dumps(result,indent=2))
print(json.dumps({k:v for k,v in result.items() if k!='events'}),flush=True)
if len(events)!=expected or not result['finished']: sys.exit(1)
