#### Holm, H. J., Samahita, M., van Veldhuizen, R. & Wengström, E. (2025).
#### Anchoring and subjective belief distributions.
#### Journal of Economic Behavior and Organization, 240, 107304. https://doi.org/10.1016/j.jebo.2025.107304
#### Data: https://osf.io/d47qm/ (HetRepPack.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' pooled_data.dta: only the
## first experiment (CnD, Prolific, USA, May 2023), which is the one that asked
## the risk question; the second experiment (2024) did not ask it. The 724
## participants are the authors' final sample (completed, valid main-task answer).
## Only treatment, age, gender and the risk answer were kept; Qualtrics response
## ids, geolocation and the (empty) name/e-mail fields were dropped.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## risk: SOEP general question, 0 = completely unwilling, 10 = very willing.
## gender: "Woman" = 1, "Man" = 0, "Non-binary" = NA.
df <- read_csv("Data/Holm_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = subject,
            age = age,
            gender = case_when(gender == "Woman" ~ 1, gender == "Man" ~ 0, TRUE ~ NA_real_),
            choice = risk,
            task = "quest_only")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Holm2025",
         paper = "Holm et al 2025")

## online experiment on Prolific, US participants only
df$country = 'United States'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holm_et_al_2025/formatted_dataset.csv")
