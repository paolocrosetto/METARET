
Here you can inspect and download **the full dataset** in a single file, including every risk elicitation task and every questionnaire, with the paper and the sample each observation comes from.

| Column | Meaning |
|---|---|
| `bibkey`, `paper`, `authors`, `pub_year`, `journal`, `doi` | the contributing paper |
| `country`, `city` | city and country of data collection |
| `collected_from`, `collected_to` | years of data collection |
| `subject` | subject unique identifier |
| `gender` | 1 = female, 0 = male |
| `age` | age in years; for age ranges (e.g., 25–34), the midpoint is used |
| `task` | the type of task, or `none` |
| `choice` | the subject's answer in the task |
| `r` | risk attitude on a common scale: the coefficient of a CRRA utility u(x) = x^r implied by the choice |
| `soep`, `soep_financial`, `soep_patience`, `soep_impulsive` | SOEP self-assessments, 0 to 10 |
| `doall`, `dohealth`, `dosocial`, `doinvest`, `dogamble`, `doethic`, `dorecre` | DOSPERT, overall and by domain, 1 to 7 |
| `BIS`, `BSSS`, `AuditS`, `CDCrisk` | Barratt Impulsiveness Scale, Brief Sensation Seeking Scale, AUDIT, Youth Risk Behavior Survey |

Where a questionnaire boils down to a single score, that score is reported rather than the answers to its individual items.
