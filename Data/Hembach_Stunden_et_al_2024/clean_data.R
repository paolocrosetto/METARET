#### Hembach-Stunden, K., Vorlaufer, T. & Engel, S. (2024). Threshold ambiguity and
#### sustainable resource management: A lab experiment.
#### Ecological Economics, 226, 108353. https://doi.org/10.1016/j.ecolecon.2024.108353
#### Data: https://doi.org/10.17605/OSF.IO/WEAYH (Replication Package, component d3wer)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' data_individual.dta (one row
## per participant, no personal data): 360 students, 17 sessions at the WISO
## Experimental Lab of Hamburg University (Nov 2019 - Feb 2020), SoPHIE.
## Only session, id, treatment, female, age and Q1 were kept.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## Q1: SOEP general question, 0 = not willing to take risk, 10 = very willing
## (mean 5.2, as reported in the paper).
## One participant reports age 10, which cannot be right for this subject pool,
## so that age is set to NA.
df <- read_csv("Data/Hembach_Stunden_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            age = if_else(age < 16, NA_real_, age),
            gender = female,
            choice = risk,
            task = "quest_only")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "HembachStunden2024",
         paper = "Hembach-Stunden et al 2024")

df$country = 'Germany'
df$city = 'Hamburg'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hembach_Stunden_et_al_2024/formatted_dataset.csv")
