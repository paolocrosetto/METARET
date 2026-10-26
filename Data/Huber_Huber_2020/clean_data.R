#### Huber, C. & Huber, J. (2020). Bad bankers no more? Truth-telling and
#### (dis)honesty in the finance industry.
#### Journal of Economic Behavior and Organization, 180, 472-493.
#### https://doi.org/10.1016/j.jebo.2020.10.020
#### Data: https://osf.io/c9dbj/ (component "Data & Analyses", stored in the linked
#### Bitbucket repository): _tt.RData

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' _tt.RData (truth-telling
## experiment, one row per subject, online oTree): 581 subjects in three pools --
## 166 students of the University of Innsbruck, 115 financial professionals from
## the before.world pool (several EU countries, no country per person) and 300
## financial professionals recruited on Prolific (country of residence from the
## Prolific export). Kept: pool, treatment, the risk answer, gender, age and, for
## Prolific only, the country of residence; Prolific ids, codes and the other
## Prolific fields were dropped.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (paper, section 2.2), asked on
## a 1-7 scale. As for Back2023, it is rescaled linearly to 0-10:
## soep = (risk - 1) / 6 * 10. The direction was checked on the data: women
## answer 3.76 on average against men's 4.42, so the high end means more willing.
## female: 1 = woman, 0 = man, 2 (one subject) = NA. Two impossible ages (above
## 100) are set to NA.
df <- read_csv("Data/Huber_Huber_2020/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age = if_else(age > 100, NA_real_, age),
            gender = if_else(female %in% c(0, 1), female, NA_real_),
            choice = (risk_1to7 - 1) / 6 * 10,
            task = "quest_only",
            country = case_when(pool == "students" ~ "Austria",
                                pool == "prolific" ~ residence,
                                TRUE ~ NA_character_),
            city = if_else(pool == "students", "Innsbruck", NA_character_))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Huber2020",
         paper = "Huber and Huber 2020")

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Huber_Huber_2020/formatted_dataset.csv")
