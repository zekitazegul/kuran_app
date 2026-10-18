import sys
sys.path.insert(0,'.tool-deps')
import cv2, numpy as np
import pymupdf
from pathlib import Path
cv2.setNumThreads(1)
_template=None

def detect(rgb, crop):
    global _template
    gray=cv2.cvtColor(rgb,cv2.COLOR_RGB2GRAY)
    if _template is None:
        document=pymupdf.open(Path(__file__).resolve().parents[1]/'content/kuran-husrev-hatti.pdf')
        pix=document[175].get_pixmap()
        image=np.frombuffer(pix.samples,np.uint8).reshape(pix.height,pix.width,3)
        _template=cv2.cvtColor(image,cv2.COLOR_RGB2GRAY)[84:104,106:126]
    template=_template
    detections=[]
    for dimension in range(13,24):
        t=cv2.resize(template,(dimension,dimension))
        mask=np.ones_like(t,np.uint8)*255
        a,b=int(dimension*.3),int(dimension*.7)
        mask[a:b,a:b]=0
        scores=cv2.matchTemplate(gray,t,cv2.TM_CCOEFF_NORMED,mask=mask)
        scores[~np.isfinite(scores)]=-1
        for _ in range(150):
            _,score,_,(x,y)=cv2.minMaxLoc(scores)
            if score<.75: break
            if crop[0]-5<=x<=crop[2] and crop[1]<=y<=crop[3]:
                detections.append((score,x,y,dimension))
            scores[max(0,y-10):y+11,max(0,x-10):x+11]=-1
    result=[]
    for score,x,y,d in sorted(detections,reverse=True):
        if all(abs(x+d/2-(m[0]+m[2])/2)>10 or abs(y+d/2-(m[1]+m[3])/2)>10 for m in result):
            result.append([float(x),float(y),float(x+d),float(y+d)])
    return sorted(result,key=lambda m:(round((m[1]+m[3])/24),-m[0]))

