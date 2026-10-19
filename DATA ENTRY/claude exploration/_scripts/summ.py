import os,re,glob
R='/home/paolo/Dropbox/METARET/METARET_github/DATA ENTRY/claude exploration'
rows=[]
for d in sorted(glob.glob(R+'/*/')):
    n=os.path.basename(d.rstrip('/'))
    if n.startswith('_') or not os.path.exists(d+'README.md'): continue
    t=open(d+'README.md').read()
    paper=re.search(r'## Paper\n(.*?)\n',t).group(1)
    paper=re.sub(r'\*|https://doi.org/\S+','',paper).strip()[:170]
    st=re.search(r'- Status: (.*)',t).group(1)
    data='yes' if st.startswith('Downloaded') else 'no (manual)'
    pdf='yes' if glob.glob(d+'*.pdf') else 'no'
    ds=re.search(r'- DOI: (\S+)',t).group(1)
    v=re.search(r'## Automatic RET keyword check.*?\n\n?(.*)',t,re.S)
    keys=re.findall(r'^- ([^:]+):',v.group(1),re.M) if v else []
    keys=[k.split(' /')[0].split(' (')[0] for k in keys if not k.startswith('no RET')]
    rows.append((n,paper,data,pdf,', '.join(keys) or '(not verifiable automatically)',ds))
tab='| Folder | Paper | Data | PDF | RET keywords found | Dataset DOI |\n|---|---|---|---|---|---|\n'+'\n'.join('| '+' | '.join(x.replace('|','/') for x in r)+' |' for r in rows)
open('table.md','w').write(tab)
open(R+'/README.md','w').write(f"""# Claude exploration: papers with risk elicitation tasks (RETs) and public data

Created 2026-10-19 by Claude (autonomous run). Each subfolder = one paper/dataset with `README.md` (bibliography, dataset DOI, download status, notes, automatic keyword check), the paper PDF if open access, and `data/` as published by the repository.

- `_decision_log.md`: choices made during the run. Full methodology in `report/` (Quarto, html + pdf).
- `_scripts/`: code to rerun discovery (`oa.py`, `cr.py`, `dc.py`, `dct.py`, `dcs.py`), building (`build.py`, `lib.py`) and vetting (`vet.py`).
- `_index.csv`: machine-readable index. `_excluded/`: candidates screened out.

**Caveat**: folders are NOT yet cleaned or checked for within-subject RET pairs, and RET presence is only keyword-checked. Treat as a lead list.

{tab}
""")
print(len(rows)); 
