#### Gleue, M., Luigs, T. & Ziegler, A. (2025). The relevance of non-state climate
#### protection activities as motivation for individual climate protection:
#### Results from a framed field experiment.
#### Resource and Energy Economics, 81, 101473.
#### https://doi.org/10.1016/j.reseneeco.2024.101473
#### Data: replication files in the article's supplementary material (mmc1:
#### Replication Files/Data.dta), downloaded by hand

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online survey experiment of the Kassel economics lab (Klab), December 2021,
## with students living in Kassel and enrolled at the University of Kassel.
## original_dataset.csv keeps the 671 respondents of the authors' final sample
## (final_sample == 1, those who met all quality criteria; 234 others in the file
## are dropped) with the treatment, the risk answer, sex and age; the authors' ids
## are replaced by row numbers.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general question "Overall, how willing are you to take
## risks?" on a 5-point scale (1 = not at all willing ... 5 = very willing; the
## authors' risk_taking dummy is 1 for answers 4 and 5). As for Back2023 and
## Huber2020, it is rescaled linearly to 0-10: soep = (risk - 1) / 4 * 10.
## female: 1 = woman, 0 = man; the authors code the 'diverse' answer (sex 3) as 0,
## here it is NA.
df <- read_csv("Data/Gleue_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = if_else(sex_other == 1, NA_real_, female),
            choice = (risk_1to5 - 1) / 4 * 10,
            task = "quest_only",
            country = "Germany")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Gleue2025",
         paper = "Gleue et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gleue_et_al_2025/formatted_dataset.csv")
