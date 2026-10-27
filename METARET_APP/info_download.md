
Here you can inspect and download **the full dataset** in a single file: every risk elicitation task and every questionnaire, with the paper and the sample each observation comes from.

Each contributed dataset was cleaned to yield the same variables. There is **one row per subject and task**: a subject who did two tasks appears on two rows, with the same questionnaire answers on both, and a subject who only answered questionnaires has task `none`. Empty cells are missing values.

| Column | Meaning |
|---|---|
| `bibkey`, `paper`, `authors`, `pub_year`, `journal`, `doi` | the contributing paper |
| `country`, `city` | city and country of data collection |
| `collected_from`, `collected_to` | years of data collection |
| `subject` | subject unique identifier |
| `gender` | 1 = female, 0 = male |
| `age` | age in years; for the few studies that asked age in brackets, the bracket midpoint |
| `task` | HL, EG, EG_loss, IG, BRET, BART, BERP, CEPL, CE_staircase, PV, or `none` |
| `choice` | the subject's answer in the task |
| `r` | risk attitude on a common scale: the coefficient of a CRRA utility u(x) = x^r implied by the choice (r = 1 risk neutral, below 1 risk averse), capped at -10 and 10 |
| `soep`, `soep_financial`, `soep_patience`, `soep_impulsive` | SOEP self-assessments, 0 to 10 |
| `doall`, `dohealth`, `dosocial`, `doinvest`, `dogamble`, `doethic`, `dorecre` | DOSPERT, overall and by domain |
| `BIS`, `BSSS`, `AuditS`, `CDCrisk` | Barratt Impulsiveness Scale, Brief Sensation Seeking Scale, AUDIT, Youth Risk Behavior Survey |

Where a questionnaire boils down to a single score, that score is reported rather than the answers to its individual items.
