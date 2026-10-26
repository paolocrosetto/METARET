#### Fallucchi, F., Marietta Leina, A. & Quercia, S. (2026).
#### Validating a survey measure of conditional cooperation.
#### Journal of Economic Psychology, 114, 102901.
#### https://doi.org/10.1016/j.joep.2026.102901
#### Data: https://osf.io/ah5e8

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## An Italian study pairing an online survey with a laboratory sequential
## prisoner's dilemma; 259 participants remain after the authors' exclusions,
## which is the sample the paper reports. Only the three columns used here were
## copied out of their Dataset.csv.
##
## The experiment elicits conditional cooperation, not risk, so the rows are
## 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
df <- read_csv("Data/Fallucchi_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## The survey carries items from the Global Preferences Survey of Falk et al.
## The paper notes they kept "only one measure of risk preferences instead of
## two as in the original GPS", and the one they kept is the general
## willingness question, released on the usual 0 to 10 scale. The data agree on
## the direction: men average 6.37 against women's 5.37.
##
## gender is written out in Italian; Donna becomes 1 and Uomo 0, while the four
## who answered Altro are left missing.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk_willingness),
            gender = case_when(gender == "Donna" ~ 1, gender == "Uomo" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Fallucchi2026",
            paper = "Fallucchi et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Italian sample; the package does not name the laboratory's city
df$country = 'Italy'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fallucchi_et_al_2026/formatted_dataset.csv")
