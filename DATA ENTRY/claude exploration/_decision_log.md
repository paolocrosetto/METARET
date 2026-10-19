# Decision log (running notes, used later for the Quarto report)

- 2026-10-19: Task started. Scope per user: any paper with >=1 risk elicitation task (RET), incl. Tanaka-Camerer-Nguyen, Andreoni-Sprenger CTB and other tasks; journals JRU, Exp Econ, JEBO, JESA, ERAE, Q Open (+JBEF, others).
- User left; autonomous mode. Choices made without asking are logged here.
- DISCLOSURE: early OpenAlex calls (candidate listing) included the user's email in the `mailto` parameter. Stopped; later calls use no personal email (Unpaywall uses the public test address unpaywall@impactstory.org).
- OpenAlex free daily budget exhausted -> switched to Crossref (abstracts, bibliographic data) and DataCite (dataset discovery).
- Discovery strategy: (1) OpenAlex full-text search in 6 journals (639 candidates) -> Crossref abstracts -> keyword RET screen (212); (2) DataCite title match paper->dataset; (3) DataCite description search for RET terms (Holt-Laury, Eckel-Grossman, Gneezy-Potters, BRET, Tanaka, DOSPERT...).
- openICPSR/ICPSR data need login + terms acceptance -> NOT downloaded (rule: no accounts / no accepting terms); only metadata + link recorded.
- 2026-10-19: build pipeline: DataCite->Crossref (paper by IsSupplementTo relation else title match >0.85)->Unpaywall PDF->dataset download (cap 250MB)->README per folder; index in _index.csv
- User asked to avoid forcing volume: a few papers at a time is fine, method must be sound and rerunnable. Scripts copied to _scripts/ (paths inside still point to scratchpad for intermediate JSON).
- Excluded Braas-Garza et al. 2023 (Exp Econ, 'Paid and hypothetical time preferences'): time preferences only, no RET (keyword screen false positive). Moved to _excluded/. Lesson: keyword screen 'risk' is loose -> each folder README must name the RET used; verify before keeping.
- UA changed to honest 'METARET-research-script/1.0'. heiDATA shows an anti-bot challenge for browser-like UAs; we do not circumvent challenges -> if still blocked, left for manual download. Dryad needs token, openICPSR/ICPSR need login: manual.
- Report rendered: report/report.html and report.pdf (quarto from RStudio bundle). Final counts: 36 folders, 23 with data, 13 manual, 6 PDFs.
