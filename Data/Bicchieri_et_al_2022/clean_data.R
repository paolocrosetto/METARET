#### Bicchieri, C., Dimant, E., Gächter, S. & Nosenzo, D. (2022).
#### Social proximity and the erosion of norm compliance.
#### Games and Economic Behavior, 132, 59-72. https://doi.org/10.1016/j.geb.2021.11.012
#### Data: https://osf.io/e5xpm/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is the period-1 row of each subject from the authors'
## "Dimant et al. (2022 GEB) - Data.dta" (842 subjects x 20 periods), keeping
## treatment, group, subject number, age, gender and stdRISK only.
## Experiment 1 of the paper: 842 University of Pennsylvania students in the lab.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
##
## Only the standardised answer to the SOEP general risk question (Dohmen et al.
## 2011) is released. It takes 11 equally spaced values (step 0.4515), so the
## original answers are recovered by ranking them 0 ... 10. Check: the recovered
## answers have mean 5.56 and sd 2.21, as in Online Appendix Table A1
## ("Risk (1 = no risk-taking; 10 = risk-taking)", mean 5.50-5.60, sd 2.09-2.26),
## so higher values mean more willing to take risks, as on the SOEP scale.
## Gender: 0 = female, 1 = male (authors' label), recoded to 1 = female.
df <- read_csv("Data/Bicchieri_et_al_2022/original_dataset.csv", show_col_types = FALSE)

levels_std <- sort(unique(round(df$stdRISK, 4)))

df <- df %>%
  transmute(subject = SubjectNo,
            age = Age,
            gender = 1 - Gender,
            choice = match(round(stdRISK, 4), levels_std) - 1,
            task = "quest_only")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Bicchieri2022",
         paper = "Bicchieri et al 2022")

df$country = 'United States'
df$city = 'Philadelphia'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bicchieri_et_al_2022/formatted_dataset.csv")
