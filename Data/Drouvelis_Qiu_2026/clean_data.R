#### Drouvelis, M. & Qiu, Z. (2026). Reciprocity and the tragedies of maintaining and
#### providing the commons: A replication and an extension to income inequality.
#### Economic Inquiry, 64(1). https://doi.org/10.1111/ecin.13297
#### Data: replication package replication_MD_ZQ_2025.zip (study1and2.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## study1and2.dta pools the authors' own Prolific participants (treatments
## equalmain, equalpro, unequalmain, unequalpro; 780 subjects) with the external
## data of GKQ2017 (lab) and GKQ2022 (MTurk). Only the authors' own subjects
## answered the risk question, so only they are kept (rows with risk not missing).
## Only ID, treatment, risk, age and gender were copied here.
## There is no incentivised risk task: the paper contributes the general risk
## question of Dohmen et al. (2011) only, so the rows are 'quest_only' (as
## Charness2019 and Trutmann2023); generate_data_for_app.R moves choice into soep.
## The question was answered on a 1-10 scale (paper, note to Table 2), not the
## usual 0-10, so it is rescaled linearly: soep = (risk - 1) * 10 / 9.
## gender: 1 = female (58.5% in the data, as in Table 2).
df <- read_csv("Data/Drouvelis_Qiu_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "quest_only",
            choice = (risk - 1) * 10 / 9,
            age = age,
            gender = gender)

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% 
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Drouvelis2026",
         paper = "Drouvelis and Qiu 2026")

## online experiment on Prolific; country not recorded
df$country = NA_character_

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Drouvelis_Qiu_2026/formatted_dataset.csv")
