"""Extract verse endpoints from the supplied PDFs, never estimate verse order.

Vector editions expose numbered glyphs. Husrev's scanned edition uses colored
verse rosettes; extraction must match the packaged page reference count.
Run with .tool-deps (opencv/numpy) available; output is runtime-only geometry.
"""
import sys, json, re
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / '.tool-deps'))
import cv2
import numpy as np
import pymupdf
from match_rosettes import detect
cv2.setNumThreads(1)

ROOT = Path(__file__).resolve().parents[1]
refs = json.loads((ROOT/'assets/page_verses.json').read_text())['pages']
editions = json.loads((ROOT/'assets/editions.json').read_text(encoding='utf8'))
names = {'computer':'kuran-bilgisayar-hatti.pdf','hat2':'kuran-hat-2.pdf','husrev':'kuran-husrev-hatti.pdf'}
repair='--repair' in sys.argv
output = json.loads((ROOT/'assets/verse_regions.json').read_text()) if repair else {}
errors = []
for edition in editions:
    eid = edition['id']
    doc = pymupdf.open(ROOT/'content'/names[eid])
    pages = []
    for number in range(605):
        if repair and output[eid][number] and all(v[2] for v in output[eid][number]):
            pages.append(output[eid][number])
            continue
        p = doc[number + edition['pdfOffset']]
        crop = edition.get('pageCrops', [])[number] if edition.get('pageCrops') else edition['cropFirst' if number == 0 else 'cropSecond' if number == 1 else 'cropOdd' if number % 2 else 'cropEven']
        left, top, right, bottom = crop
        markers = []
        if eid == 'hat2':
            for b in p.get_text('rawdict')['blocks']:
                for line in b.get('lines', []):
                    for s in line['spans']:
                        if eid == 'computer' and 'Suleyman' in s['font']:
                            for c in s['chars']:
                                if 770 <= ord(c['c']) <= 1055 and c['bbox'][2]-c['bbox'][0] > 10:
                                    markers.append(list(c['bbox']))
                        if eid == 'hat2' and s['font'] == 'AlArqaam':
                            text = ''.join(c['c'] for c in s['chars'])
                            if re.fullmatch(r'\(\d+\)', text.strip()): markers.append(list(s['bbox']))
        else:
            pix = p.get_pixmap()
            rgb = np.frombuffer(pix.samples, np.uint8).reshape(pix.height,pix.width,3)
            r,g,b = [rgb[:,:,i].astype(int) for i in range(3)]
            mask = ((r-b>35)&(g-b>25)&(r<190)&(g<180)&(r-g<55)).astype('uint8')*255
            _,_,stats,_ = cv2.connectedComponentsWithStats(mask)
            for x,y,w,h,area in stats[1:]:
                minsize, maxsize = (10,25) if eid=='husrev' else (15,22)
                if minsize <= w <= maxsize and minsize <= h <= maxsize and .75<w/h<1.3 and area >= 40 and left-5 <= x <= right and top <= y <= bottom:
                    interior=rgb[y+h//4:y+3*h//4,x+w//4:x+3*w//4,:]
                    cream=((interior[:,:,0]>210)&(interior[:,:,1]>195)&(interior[:,:,2]>135)).mean()
                    if eid!='husrev' or cream>.20:
                        markers.append([float(x),float(y),float(x+w),float(y+h)])
        markers.sort(key=lambda m: (round((m[1]+m[3])/2/12), -m[0]))
        if eid=='husrev' and number==0:
            markers.insert(0,[94.,337.,105.,350.])
        if eid=='husrev' and number==440:
            # This supplied scan uses plain verse numbers rather than rosettes.
            markers=[[x-5.,y-6.,x+5.,y+6.] for x,y in [(492,143),(232,195),(111,247),(231,299),(398,352),(212,403),(404,457),(494,558),(206,612),(251,664),(362,717),(206,717),(127,768),(408,821),(113,821)]]
        if eid=='husrev' and len(markers)!=len(refs[number]):
            markers=detect(rgb,crop)
        groups=[]
        for marker in sorted(markers,key=lambda m:(m[1]+m[3])/2):
            cy=(marker[1]+marker[3])/2
            if not groups or cy-(groups[-1][0][1]+groups[-1][0][3])/2>12:
                groups.append([])
            groups[-1].append(marker)
        markers=[m for group in groups for m in sorted(group,key=lambda m:-m[0])]
        if len(markers) != len(refs[number]):
            errors.append((eid,number,len(markers),len(refs[number])))
            pages.append([])
            continue
        # Each edition uses an evenly spaced writing grid. Determine its phase
        # from actual endpoints, preserving the special opening-page scale.
        step = (42.8 if eid=='computer' else 37.8 if eid=='hat2' else 52.0)
        if number < 2:
            step = 31.0 if eid=='computer' else 30.0 if eid=='hat2' else 44.0
        centers = [(m[1]+m[3])/2 for m in markers]
        # Grid phase from the first endpoint; extend to the first writing row.
        first = centers[0]
        while first-step > top+step*.25: first -= step
        rows = []
        cy = first
        while cy < bottom:
            rows.append(cy); cy += step
        pix=p.get_pixmap()
        image=np.frombuffer(pix.samples,np.uint8).reshape(pix.height,pix.width,3)
        black=(image.max(axis=2)<170)&((image.max(axis=2).astype(int)-image.min(axis=2))<30)
        endpoint_rows={min(range(len(rows)),key=lambda i:abs(rows[i]-c)) for c in centers}
        writing_rows=set(endpoint_rows)
        for index,cy in enumerate(rows):
            stripe=black[max(0,int(cy-step*.48)):int(cy+step*.48),int(left+3):int(right-3)]
            xs=np.where(stripe.sum(axis=0)>1)[0]
            if stripe.sum()>120 and len(xs)>0 and (number<2 or xs[-1]-xs[0]>(right-left)*.80):
                writing_rows.add(index)
        previous_row, previous_x = 0, right
        regions = []
        for ref, marker, center in zip(refs[number],markers,centers):
            end_row = min(range(len(rows)), key=lambda i: abs(rows[i]-center))
            boxes = []
            for row in range(previous_row, end_row+1):
                if row not in writing_rows: continue
                x1 = marker[0] if row == end_row else left
                x2 = previous_x if row == previous_row else right
                if x2 > x1:
                    boxes.append([round(x1/p.rect.width,6),round(max(top,rows[row]-step*.48)/p.rect.height,6),round(x2/p.rect.width,6),round(min(bottom,rows[row]+step*.48)/p.rect.height,6)])
            regions.append([ref['surah'],ref['verse'],boxes])
            previous_row, previous_x = end_row, marker[0]
        pages.append(regions)
    output[eid] = pages
    print(eid, 'complete', flush=True)
print('Mismatches:', len(errors), errors[:80])
(ROOT/'assets/verse_regions.json').write_text(json.dumps(output,separators=(',',':')))
(ROOT/'build/verse-region-audit.json').write_text(json.dumps(errors))
