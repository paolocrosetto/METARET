import os,re,subprocess,zipfile,sys,glob
ROOT='/home/paolo/Dropbox/METARET/METARET_github/DATA ENTRY/claude exploration'
KW={'Holt-Laury / MPL':r'holt|laury|multiple price list|price list','Eckel-Grossman':r'eckel|grossman','Gneezy-Potters / investment game':r'gneezy|potters|investment game','BRET':r'bomb|\bBRET\b','BART':r'balloon|\bBART\b','Tanaka/CPT':r'tanaka|\bCPT\b|cumulative prospect','Binswanger':r'binswanger','Certainty equiv./BDM':r'certainty equivalent|\bBDM\b|becker','Lotteries/gambles':r'lotter|gambl','Self-report (DOSPERT/SOEP/etc.)':r'dospert|\bSOEP\b|willingness to take risk|risk question|self-report','Convex Time Budget':r'convex time|\bCTB\b|andreoni'}
def txt(path):
    e=path.lower().rsplit('.',1)[-1]
    try:
        if e=='pdf': return subprocess.run(['pdftotext','-q',path,'-'],capture_output=True,text=True,timeout=60).stdout
        if e=='docx':
            return re.sub('<[^>]+>',' ',zipfile.ZipFile(path).read('word/document.xml').decode('utf8','ignore'))
        if e in('txt','md','do','r','csv','tex','html','xml','json','py','m','sps','sas') and os.path.getsize(path)<3e6: return open(path,errors='ignore').read()
    except Exception: pass
    return ''
for d in sorted(glob.glob(ROOT+'/*/')+glob.glob(ROOT+'/_excluded/*/')):
    if not os.path.exists(d+'README.md'): continue
    res={}
    for src,pat in (('paper PDF',[f for f in glob.glob(d+'*.pdf')]),('data docs/code',[f for f in glob.glob(d+'data/**',recursive=True) if os.path.isfile(f)])):
        for f in pat:
            t=txt(f)
            for k,p in KW.items():
                n=len(re.findall(p,t,flags=re.I))
                if n: res.setdefault(k,{}).setdefault(src,0); res[k][src]+=n
    lines='\n'.join(f"- {k}: "+', '.join(f'{s} x{n}' for s,n in v.items()) for k,v in res.items()) or '- no RET keywords found in paper PDF or readable data docs (PDF may be missing; check manually)'
    r=open(d+'README.md').read()
    r=re.sub(r'\n## Automatic RET keyword check.*','',r,flags=re.S)
    r+=f"\n## Automatic RET keyword check (vet.py)\nKeyword counts in the paper PDF (if present) and readable data documentation/code. Indicative only; confirm by reading the paper.\n{lines}\n"
    open(d+'README.md','w').write(r)
    print(os.path.basename(d.rstrip('/'))[:45].ljust(46),'; '.join(res) or 'NONE')
