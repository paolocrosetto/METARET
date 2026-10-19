import json,urllib.request,urllib.parse,re,difflib
from concurrent.futures import ThreadPoolExecutor
c=json.load(open('cands2.json'))
def norm(s): 
    s=re.sub(r'^(replication|data|code|dataset|raw data|supplementary|materials|and|for|from|package|files?)[\s:,]*','',s.lower().strip())
    s=re.sub(r'^(replication|data|code|dataset|raw data|and|for|from|package|files?)[\s:,]*','',s)
    return re.sub(r'[^a-z0-9 ]',' ',s).split()
def f(k):
    v=c[k]; t=re.sub('<[^>]+>','',v['title'] or '')
    q=urllib.parse.urlencode({'query':'titles.title:"%s"'%re.sub(r'["\\]',' ',t)[:150],'resource-type-id':'dataset','page[size]':10})
    for _ in range(3):
        try: j=json.load(urllib.request.urlopen('https://api.datacite.org/dois?'+q,timeout=30)); break
        except Exception: j=None
    res=[]
    for d in (j or {}).get('data',[]):
        a=d['attributes']; tt=(a['titles'] or [{}])[0].get('title','')
        r=difflib.SequenceMatcher(None,' '.join(norm(t)),' '.join(norm(tt))).ratio()
        if r>0.8: res.append((round(r,2),a['doi'],tt,str(a.get('publisher')),a.get('url')))
    return k,res
with ThreadPoolExecutor(5) as ex:
    for k,r in ex.map(f,list(c)): c[k]['ds']=r
json.dump(c,open('cands3.json','w'))
for k,v in c.items():
    if v['ds']: print(v['j'],v['year'],'RET' if v['ret'] else '---',v['title'][:70],'|',v['ds'][0][1],v['ds'][0][3])
