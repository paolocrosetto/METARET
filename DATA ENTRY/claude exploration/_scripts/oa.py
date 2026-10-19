import json,urllib.request,urllib.parse,sys,time
issn={'JRU':'0895-5646','ExpEcon':'1386-4157','JEBO':'0167-2681','JESA':'2199-6776','ERAE':'0165-1587','QOpen':'2633-9196','JBEF':'2214-6350','JEP':'0167-4870','AgEcon':'0169-5150','AJAE':'0002-9092','FoodPol':'0306-9192','TheoryDec':'0040-5833','GEB':'0899-8256','EJ':'0013-0133','JDM':'1930-2975','JEEA':'1542-4766','Mgmt':'0025-1909','JEconBeh':'2214-8043','AgEcon2':'1574-0862'}
terms=['"risk elicitation"','"Holt and Laury"','"Eckel and Grossman"','"Gneezy and Potters"','"bomb risk"','"Tanaka" "risk aversion" experiment','"multiple price list" risk','"risk preferences" experiment lottery','"risk attitudes" elicited experiment','"Andreoni and Sprenger"','"certainty equivalent" lottery experiment','"investment game" risk','"risk aversion" "lab experiment" farmers','"DOSPERT"','"willingness to take risks"']
out={}
for k,i in issn.items():
  for t in terms:
    url='https://api.openalex.org/works?'+urllib.parse.urlencode({'search':t,'filter':f'primary_location.source.issn:{i},from_publication_date:2008-01-01,type:article','per-page':50,'select':'id,doi,title,publication_year,authorships,primary_location','mailto':'paolo.crosetto@gmail.com'})
    try: j=json.load(urllib.request.urlopen(url,timeout=30))
    except Exception as e: print('err',k,t,e,file=sys.stderr); continue
    for w in j['results']:
        out[w['id']]=dict(doi=w['doi'],title=w['title'],year=w['publication_year'],j=k,au=[a['author']['display_name'] for a in w['authorships'][:3]])
    time.sleep(.1)
json.dump(out,open('cands.json','w'))
print(len(out))
