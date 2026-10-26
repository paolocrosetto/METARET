#### Campigotto, N., Catola, M., D'Alessandro, S., Guarnieri, P. & Spadoni, L. (2025).
#### Curbing energy consumption through voluntary quotas: Experimental evidence.
#### Energy Economics, 150, 108881. https://doi.org/10.1016/j.eneco.2025.108881
#### Data: https://osf.io/6rvxz (Replication files/voluntary_quotas_main.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps the treatment, the risk answer, sex and age from the
## authors' file (one row per subject): 800 UK residents aged 18-45, recruited on
## Prolific, online oTree experiment (January 2022). Prolific ids, group ids,
## time stamps, ethnicity, language, country of birth and nationality are dropped;
## subjects are row numbers.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (Dohmen et al. 2011), 0-10,
## higher = more willing (women 5.10, men 5.68). female: 1 = woman, 0 = man.
df <- read_csv("Data/Campigotto_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = self_risk,
            task = "quest_only",
            country = "United Kingdom")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Campigotto2025",
         paper = "Campigotto et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Campigotto_et_al_2025/formatted_dataset.csv")
