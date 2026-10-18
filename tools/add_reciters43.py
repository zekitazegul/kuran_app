"""Build the catalog from cached source metadata; fail on unmapped chapter names."""
import json, re, unicodedata, hashlib, urllib.request, concurrent.futures
from pathlib import Path

p = Path('assets/audio.json')
catalog = json.loads(p.read_text(encoding='utf-8'))
sizes = dict(re.findall(r'<span class="name">(\d{6}\.mp3)</span>.*?<td data-order="(\d+)"', Path('build/maher.html').read_text(encoding='utf-8'), re.S))
checksums = {name: md5 for md5, name in re.findall(r'([a-f0-9]{32}) \*Maher_AlMuaiqly_64kbps/(\d{6}\.mp3)', Path('build/maher-md5.txt').read_text())}
# The published checksum file predates recordings in old/ and replaced/.
# Verify their current replacements directly instead of shipping stale hashes.
changed = set()
for folder in ['old','replaced']:
    html = urllib.request.urlopen('https://everyayah.com/data/Maher_AlMuaiqly_64kbps/'+folder+'/', timeout=30).read().decode()
    changed.update(re.findall(r'<span class="name">(\d{6}\.mp3)</span>',html))
def current_hash(name):
    data = urllib.request.urlopen('https://everyayah.com/data/Maher_AlMuaiqly_64kbps/'+name, timeout=30).read()
    assert len(data) == int(sizes[name]), name
    return name, hashlib.md5(data).hexdigest()
with concurrent.futures.ThreadPoolExecutor(6) as pool:
    checksums.update(pool.map(current_hash, sorted(changed)))
counts = json.loads(Path('assets/page_verses.json').read_text(encoding='utf-8'))['pages']
refs = [v for page in counts for v in page]
tracks = []
for ref in refs:
    s,v = ref['surah'],ref['verse']
    name = f'{s:03}{v:03}.mp3'
    tracks.append(dict(id='maher_'+name[:-4],reciter='maher',surah=s,verse=v,bytes=int(sizes[name]),md5=checksums[name],url='https://everyayah.com/data/Maher_AlMuaiqly_64kbps/'+name))

catalog['reciters'] = [r for r in catalog['reciters'] if r['id'] not in ['maher','mehmet_emin_ay','mustafa_ismail']] + [
    dict(id='maher',name='Mahir al Muaiqly',partial=False,verseByVerse=True),
]
catalog['tracks'] = [t for t in catalog['tracks'] if t['reciter'] not in ['maher','mehmet_emin_ay','mustafa_ismail']] + tracks
catalog['version'] = 4
p.write_text(json.dumps(catalog,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
print(f'Catalog has {len(catalog["reciters"])} complete reciters')
