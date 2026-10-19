import json,urllib.request,urllib.parse,re
Q=['"Holt and Laury"','"Holt-Laury"','"Eckel and Grossman"','"Eckel-Grossman"','"Gneezy and Potters"','"Gneezy-Potters"','"bomb risk elicitation"','"BRET" risk','"risk elicitation"','"Tanaka" "Camerer" "Nguyen"','"Binswanger" lottery','"multiple price list" risk','"risk preferences" "lab experiment"','"risk aversion" "experiment" lottery choice','"risk attitudes" "experiment" incentivized','"Andreoni" "Sprenger" convex time budgets','"Dohmen" "willingness to take risks"','"DOSPERT"','"investment game" risk','"certainty equivalent" lottery','"risk and time preferences"','"risk, time"  preferences experiment','"risk preferences" "field experiment" farmers','"loss aversion" "lottery" experiment', '"prospect theory" "elicit"', '"ambiguity aversion" "risk aversion" experiment','"Drichoutis" "Lusk" risk','"risk tolerance" "experimental"','"gamble" "risk" "replication data" experiment']
out={}
for q in Q:
  for p in (1,2,3):
    u='https://api.datacite.org/dois?'+urllib.parse.urlencode({'query':q,'resource-type-id':'dataset','page[size]':100,'page[number]':p})
    try: j=json.load(urllib.request.urlopen(u,timeout=40))
    except Exception as e: break
    for d in j['data']:
        a=d['attributes']
        out[a['doi']]=dict(t=(a['titles'] or [{}])[0].get('title'),pub=str(a.get('publisher')),yr=a.get('publicationYear'),url=a.get('url'),desc=' '.join(x.get('description','') for x in (a.get('descriptions') or []))[:600],rel=[r['relatedIdentifier'] for r in (a.get('relatedIdentifiers') or [])][:5],q=q)
    if len(j['data'])<100: break
json.dump(out,open('dcs.json','w'))
print(len(out))
