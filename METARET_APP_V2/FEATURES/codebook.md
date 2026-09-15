# Task characteristics

Step 01 of the roadmap — breaking each risk elicitation task down by its design
features, so that later steps can ask which of those features drive external
validity.

One row per contributed paper and task. `bibkey` joins to `DATA/df_mod.csv`.
The coding was done in Russian; column names and coded values were translated
once, here, so that nothing downstream has to.

## task_features.csv — 104 rows

How each task was implemented in each paper.

| column | type | meaning |
|---|---|---|
| `bibkey` | text | paper key, joins to `df_mod.csv` |
| `citation` | text | short citation |
| `task` | text | task code (HL, EG, IG, BRET, …) |
| `n` | integer | subjects contributing to this row |
| `mean_r` | number | mean CRRA coefficient for this paper and task |
| `hypothetical_payment` | logical | choices were not paid out |
| `safe_option` | logical | the menu contains a riskless option |
| `fixed_50_50` | logical | probabilities are fixed at 50/50 |
| `forced_switching_point` | logical | the design allows a single switch only |
| `real_losses` | logical | an outcome can reduce what the subject already holds |
| `single_choice` | logical | one decision rather than a list |
| `sources` | text | which pass of the coding the row comes from (`v1`, `v2`, `v4`, or a combination) |
| `status` | text | `coded`, or `task not yet coded` |

83 rows are coded; 21 are `task not yet coded`.

## data_quality.csv — 84 rows

What, if anything, is wrong with each contributed dataset. Six flags, plus a
count and a readable list of whichever flags are set.

| column | type | meaning |
|---|---|---|
| `n_all` | integer | rows contributed |
| `n_plot` | integer | rows that survive into the plots |
| `corrupt_data` | logical | values that cannot be what they claim to be |
| `task_misunderstood` | logical | subjects appear not to have understood the task |
| `noise_not_removed` | logical | the authors left in responses they themselves flag as noise |
| `too_few_observations` | logical | too small to correlate |
| `deception` | logical | the design deceives subjects |
| `not_peer_reviewed` | logical | working paper or unpublished |
| `n_defects` | integer | how many of the six flags are set |
| `defects` | text | those flags, `"; "`-separated, empty when clean |

49 of the 84 are clean.

## task_vs_selfreport.csv — 18 rows

Each task against the self-reported measure, alongside three of the design
flags — the first cut at the question step 03 asks in full.

| column | type | meaning |
|---|---|---|
| `rho` | number | rank correlation between task and self-report |
| `p` | number | its p-value |
| `safe_option`, `fixed_50_50`, `price_list` | logical | design flags, as above |
