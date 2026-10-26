#### Bauer, M., Chytilova, J. & Miguel, E. (2020). Using survey questions to
#### measure preferences: Lessons from an experimental validation in Kenya.
#### European Economic Review, 127, 103493.
#### https://doi.org/10.1016/j.euroecorev.2020.103493
#### Data: "Replication files.7z" (Validation_Dataset.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Validation of the Global Preference Survey with low-income adults from
## Kibera, Nairobi, in the Busara Center lab: two visits a week apart, one
## with incentivized experiments and one with the survey. The qualitative
## risk item of the survey is the GPS / SOEP self-assessment on 0 to 10
## ("using a scale from 0 to 10"), s_risk_qual. The rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## THE INCENTIVIZED TASK IS NOT CODED YET. It is a certainty-equivalent list,
## "21 binary choices between a lottery that yielded a positive amount or zero
## with equal probability, and a safe payment option that increased in each
## subsequent binary choice" (e_risk = switching row). The prize and the 21
## safe amounts are only in the Online Appendix, which is not in the package;
## once it is at hand the rows can be filed as CEPL.
##
## 123 rows in the file, 120 people: survey_id 142149 appears four times with
## the same experimental record, risk answer, age and gender, differing only in
## other survey items, and is kept once. gender and age are taken from the
## survey visit (s_gender, s_age); four ages are missing.
df <- read_csv("Data/Bauer_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 120, all(df$risk_qual %in% 0:10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = risk_qual,
            gender = case_when(s_gender == "Female" ~ 1, s_gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            age = s_age,
            bibkey = "Bauer2020",
            paper = "Bauer et al. 2020")

## no task coded, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Busara Center, Nairobi; participants from Kibera
df$country = 'Kenya'
df$city = 'Nairobi'
df$lattitude = '-1.3133'
df$longitude = '36.7876'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bauer_et_al_2020/formatted_dataset.csv")
