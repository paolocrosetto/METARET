import json,urllib.request,urllib.parse,time,sys
c=json.load(open('cands.json'))
items=[(k,v) for k,v in c.items() if v['doi']]
dois={v['doi'].replace('https://doi.org/','').lower():k for k,v in items}
L=list(dois); hits={}
for i in range(0,len(L),15):
    ch=L[i:i+15]
    q=' OR '.join('relatedIdentifiers.relatedIdentifier:"%s"'%d for d in ch)
    url='https://api.datacite.org/dois?'+urllib.parse.urlencode({'query':q,'page[size]':100})
    try: j=json.load(urllib.request.urlopen(url,timeout=40))
    except Exception as e: print('err',i,e,file=sys.stderr); continue
    for d in j['data']:
        a=d['attributes']
        rel=[r for r in (a.get('relatedIdentifiers') or []) if r['relatedIdentifier'].lower() in ch]
        for r in rel:
            hits.setdefault(r['relatedIdentifier'].lower(),[]).append((a['doi'],(a['titles'] or [{}])[0].get('title'),r['relationType'],a['publisher'] if isinstance(a['publisher'],str) else str(a['publisher'])))
    time.sleep(.2)
json.dump(hits,open('dc_hits.json','w'),indent=1)
for d,h in hits.items():
    print(c[dois[d]]['j'],c[dois[d]]['year'],c[dois[d]]['title'][:80],'->',h[0][0],h[0][3])
print(len(hits))
