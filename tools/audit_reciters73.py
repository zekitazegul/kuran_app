"""Compare every catalog recording with current source listings and verify Beyyine bytes."""
import concurrent.futures, hashlib, json, re, time, urllib.request
from pathlib import Path

OUT = Path('build/verification73')
OUT.mkdir(parents=True, exist_ok=True)
catalog = json.loads(Path('assets/audio.json').read_text(encoding='utf-8'))

def fetch(url):
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=45) as response:
                return response.read()
        except Exception:
            if attempt == 2: raise
            time.sleep(1)

def audit(reader):
    tracks = [t for t in catalog['tracks'] if t['reciter'] == reader['id']]
    address = tracks[0]['url'].rsplit('/', 1)[0] + '/'
    listing = fetch(address).decode()
    (OUT / (reader['id'] + '.html')).write_text(listing, encoding='utf-8')
    sizes = dict(re.findall(r'<span class="name">(\d{6}\.mp3)</span>.*?<td data-order="(\d+)"', listing, re.S))
    issues = []
    for t in tracks:
        name = t['url'].rsplit('/', 1)[1]
        if name not in sizes: issues.append({'id': t['id'], 'error': 'missing source'})
        elif int(sizes[name]) != t['bytes']: issues.append({'id': t['id'], 'error': 'source size changed', 'bytes': int(sizes[name])})
    verified = []
    for t in tracks:
        if t['surah'] != 98: continue
        data = fetch(t['url'])
        ok = len(data) == t['bytes'] and hashlib.md5(data).hexdigest() == t['md5']
        (OUT / (t['id'] + '.mp3')).write_bytes(data)
        verified.append({'id': t['id'], 'bytes': len(data), 'hashMatches': ok})
        if not ok: issues.append({'id': t['id'], 'error': 'Beyyine hash mismatch'})
    result = {'reciter': reader['id'], 'catalogCount': len(tracks), 'sourceCount': len(sizes), 'issues': issues, 'beyyine': verified}
    print(json.dumps(result), flush=True)
    return result

with concurrent.futures.ThreadPoolExecutor(max_workers=5) as pool:
    results = list(pool.map(audit, catalog['reciters']))
(OUT / 'audio-audit.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
assert all(not r['issues'] and r['catalogCount'] == 6236 for r in results)
