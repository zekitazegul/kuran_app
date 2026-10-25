"""Resumable silent full-corpus download/hash/decode audit; no listening-speed waits."""
import concurrent.futures, hashlib, http.client, json, sys, threading, time, urllib.parse
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path('build/audit-deps').resolve()))
import miniaudio

connections = threading.local()
OUT = Path('build/verification73')
OUT.mkdir(parents=True, exist_ok=True)
RESULTS = OUT / 'full-audio-decode.jsonl'
tracks = json.loads(Path('assets/audio.json').read_text(encoding='utf-8'))['tracks']
previous = {}
if RESULTS.exists():
    for line in RESULTS.read_text(encoding='utf-8').splitlines():
        row = json.loads(line)
        if row.get('ok'): previous[row['id']] = row

def check(track):
    started = time.monotonic()
    result = {'id': track['id'], 'reciter': track['reciter'], 'surah': track['surah'], 'verse': track['verse'], 'ok': False}
    try:
        for attempt in range(3):
            try:
                url = urllib.parse.urlsplit(track['url'])
                connection = getattr(connections, 'connection', None)
                if connection is None:
                    connection = http.client.HTTPSConnection(url.hostname, timeout=35)
                    connections.connection = connection
                connection.request('GET', url.path)
                response = connection.getresponse()
                data = response.read()
                if response.status != 200: raise RuntimeError(f'HTTP {response.status}')
                break
            except Exception:
                if getattr(connections, 'connection', None): connections.connection.close()
                connections.connection = None
                if attempt == 2: raise
        result['bytes'] = len(data)
        result['hashMatches'] = len(data) == track['bytes'] and hashlib.md5(data).hexdigest() == track['md5']
        decoded = miniaudio.mp3_read_s16(data)
        result['decodedMicroseconds'] = round(decoded.num_frames / decoded.sample_rate * 1000000)
        result['decoder'] = 'miniaudio-mp3'
        result['ok'] = result['hashMatches'] and result['decodedMicroseconds'] > 0
        if not result['ok']: (OUT / (track['id'] + '-failed.mp3')).write_bytes(data)
    except Exception as error:
        result['error'] = str(error)
    result['elapsed'] = round(time.monotonic() - started, 2)
    return result

pending = [t for t in tracks if t['id'] not in previous]
print(f'Checking {len(pending)} recordings; {len(previous)} already passed.', flush=True)
all_results = dict(previous)
with RESULTS.open('a', encoding='utf-8') as output, concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
    for result in pool.map(check, pending):
        all_results[result['id']] = result
        output.write(json.dumps(result) + '\n'); output.flush()
        if len(all_results) % 200 == 0 or not result['ok']:
            print(f'{len(all_results)}/{len(tracks)} checked; {sum(not r["ok"] for r in all_results.values())} failed; {result["id"]}', flush=True)

summary = {'checked': len(all_results), 'expected': len(tracks),
    'byReciter': dict(Counter(r['reciter'] for r in all_results.values() if r['ok'])),
    'failures': [r for r in all_results.values() if not r['ok']],
    'decoderMessages': [r['id'] for r in all_results.values() if r.get('decoderMessages')]}
(OUT / 'full-audio-summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
print(json.dumps(summary), flush=True)
assert summary['checked'] == summary['expected'] and not summary['failures']
