import sys,os,re,json,difflib,urllib.parse,urllib.request,shutil,csv,time
sys.path.insert(0,'.')
from lib import *
ROOT='/home/paolo/Dropbox/METARET/METARET_github/DATA ENTRY/claude exploration'
MAXMB=250
def clean(s): return re.sub(r'<[^>]+>','',s or '')
def crossref_by_doi(d):
    return get('https://api.crossref.org/works/'+urllib.parse.quote(d))['message']
def crossref_by_title(t):
    j=get('https://api.crossref.org/works?'+urllib.parse.urlencode({'query.bibliographic':t,'rows':3,'select':'DOI,title,author,issued,container-title,type'}))
    best=None
    for m in j['message']['items']:
        mt=clean((m.get('title') or [''])[0])
        r=difflib.SequenceMatcher(None,mt.lower(),t.lower()).ratio()
        if r>0.85 and (not best or r>best[0]) and m.get('type')=='journal-article': best=(r,m['DOI'])
    return best[1] if best else None
def strip_prefix(t):
    t=re.sub(r'^(replication (data|package|code)|data and code|data|dataset|replication files?)( and code)?( for| from)?\s*[:“”"]*\s*','',t.strip(),flags=re.I)
    return t.strip(' "“”')
def build(ddoi,paper_doi=None,note='',force_name=None):
    a=dc(ddoi); title=a['titles'][0]['title']
    pd_=paper_doi
    if not pd_:
        for r in a.get('relatedIdentifiers') or []:
            if r.get('relatedIdentifierType')=='DOI' and r['relationType'] in('IsSupplementTo','IsReferencedBy','IsCitedBy','IsDescribedBy') and not r['relatedIdentifier'].lower().startswith(('10.17632','10.7910')):
                pd_=r['relatedIdentifier'];break
    if not pd_:
        try: pd_=crossref_by_title(strip_prefix(title))
        except Exception: pd_=None
    cm=None
    if pd_:
        try: cm=crossref_by_doi(pd_)
        except Exception: pass
    if cm:
        au=cm.get('author') or []; fam=(au[0].get('family') if au else 'Unknown')
        yr=(cm.get('issued',{}).get('date-parts') or [[None]])[0][0]
        jn=(cm.get('container-title') or [''])[0]
        name=force_name or re.sub(r'[^A-Za-z0-9_]','',f"{fam}_{yr}_{re.sub(r'[^A-Za-z]','',jn)[:12]}")
    else:
        name=force_name or re.sub(r'[^A-Za-z0-9_]','',re.sub(r'\s+','_',strip_prefix(title))[:40])+'_'+ddoi.split('/')[-1][:10]
    d=os.path.join(ROOT,name); os.makedirs(d,exist_ok=True)
    # data
    fl=files(ddoi,a.get('url')); dstat=''
    ddir=os.path.join(d,'data'); 
    if isinstance(fl,list) and fl:
        tot=sum(x[1] or 0 for x in fl)/1e6
        if tot>MAXMB: dstat=f'NOT downloaded: {tot:.0f} MB exceeds {MAXMB} MB cap ({len(fl)} files).'
        else:
            os.makedirs(ddir,exist_ok=True); ok=[]
            for n,s,u in fl:
                try:
                    b=get(u,raw=True,t=300); open(os.path.join(ddir,re.sub(r'[/\\]','_',n)),'wb').write(b); ok.append(n)
                except Exception as e: dstat+=f'failed {n}: {str(e)[:60]}; '
            dstat=f'Downloaded {len(ok)}/{len(fl)} files ({tot:.1f} MB) from {a.get("url")}. '+dstat
    else:
        dstat=f'NOT downloaded ({fl or "repository requires login / no public API (e.g. openICPSR) or no files listed"}). Access manually at {a.get("url")}.'
    # pdf
    pstat='no PDF found (not open access / not located)'
    if pd_:
        try:
            u=get('https://api.unpaywall.org/v2/'+urllib.parse.quote(pd_)+'?email=unpaywall@impactstory.org')
            locs=[u.get('best_oa_location')]+(u.get('oa_locations') or [])
            for l in locs:
                if l and l.get('url_for_pdf'):
                    try:
                        b=get(l['url_for_pdf'],raw=True,t=120)
                        if b[:4]==b'%PDF': open(os.path.join(d,name+'.pdf'),'wb').write(b); pstat='PDF saved from '+l['url_for_pdf']; break
                    except Exception: continue
        except Exception: pass
    # readme
    if cm:
        auth='; '.join(f"{x.get('family','')}, {x.get('given','')}" for x in cm.get('author',[]))
        bib=f"{auth} ({yr}). {clean((cm.get('title') or [''])[0])}. *{jn}*, {cm.get('volume','')}({cm.get('issue','')}), {cm.get('page','')}. https://doi.org/{pd_}"
    else: bib=f'(paper not identified automatically; dataset title: {title})'
    cre='; '.join(c.get('name','') for c in a.get('creators',[]))
    abstract=clean((cm or {}).get('abstract','')) 
    open(os.path.join(d,'README.md'),'w').write(f"""# {name}

## Paper
{bib}

{('Abstract (Crossref): '+abstract) if abstract else ''}

## Dataset
- Title: {title}
- Creators: {cre}
- DOI: https://doi.org/{ddoi}
- Landing page: {a.get('url')}
- Publisher/repository: {a.get('publisher')}
- Status: {dstat}

## PDF
{pstat}

## Notes (Claude exploration, {time.strftime('%Y-%m-%d')})
{note or '(none yet)'}
- Folder produced automatically; contents of `data/` are exactly as published by the repository (not cleaned, not checked for within-subject RET pairs). Check the repository's own README before using.
""")
    row=[name,pd_ or '',ddoi,a.get('url'),dstat[:80],pstat[:40]]
    with open(os.path.join(ROOT,'_index.csv'),'a',newline='') as f: csv.writer(f).writerow(row)
    print(name,'|',dstat[:90],'|',pstat[:40])
if __name__=='__main__':
    for x in sys.argv[1:]:
        try: build(x)
        except Exception as e: print('FAIL',x,e)
