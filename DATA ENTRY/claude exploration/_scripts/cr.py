import json,urllib.request,re,sys
from concurrent.futures import ThreadPoolExecutor
c=json.load(open('cands.json'))
def f(k):
    v=c[k]
    if not v['doi']: return k,''
    d=v['doi'].replace('https://doi.org/','')
    for t in range(3):
        try:
            j=json.load(urllib.request.urlopen(urllib.request.Request('https://api.crossref.org/works/'+d,headers={'User-Agent':'METARET/1.0 (mailto:paolo.crosetto@gmail.com)'}),timeout=30))
            return k,re.sub('<[^>]+>',' ',j['message'].get('abstract',''))
        except Exception as e: pass
    return k,''
with ThreadPoolExecutor(6) as ex:
    for k,a in ex.map(f,list(c)): c[k]['abs']=a
kw=re.compile(r'holt|laury|risk elicitation|eckel|grossman|gneezy|potters|tanaka|bomb|BRET|lotter|risk aversion|risk preference|risk attitude|risk tolerance|risk-taking|risk taking|gambl|DOSPERT|binswanger|price list|certainty equivalent|prospect theory|loss aversion|risk-averse|risk averse',re.I)
for v in c.values(): v['ret']=bool(kw.search((v['title'] or '')+' '+v['abs']))
print(sum(v['ret'] for v in c.values()), sum(1 for v in c.values() if v['abs']))
json.dump(c,open('cands2.json','w'))
