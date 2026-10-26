#### Flambard, V., Le Lec, F. & Romaniuc, R. (2024). An experimental comparison of
#### contributions in collective prevention games and public goods games.
#### Economic Inquiry, 62(4), 1598-1617. https://doi.org/10.1111/ecin.13236
#### Data: openICPSR, https://doi.org/10.3886/E198944V3 (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is one row per subject from the authors' Experiment_Data.dta
## (168 subjects x 10 rounds): 8 sessions of 21 at the Laboratory for Experimental
## Anthropology, Lille, oTree; four between-subject treatments of a public goods /
## collective prevention game. Kept: session (renumbered), treatment, gender, the
## SOEP item and the ten Holt-Laury answers.
## Holt-Laury list (oTree code, app Holt_Laury_Inequity_aversion_lab): in row k
## option A pays 8.5 or 6.8 EUR and option B 16 or 0.5 EUR, the high outcome with
## probability k/10. aversion_choice_k: 0 = option A, 1 = option B (dictionary of
## variables; in row 10, where B pays 16 for sure, nearly everyone has 1). The
## authors' do-file calls the sum of these "HLsafe_choices", but by the dictionary
## and the row-10 check it is the number of risky (B) choices, which is what
## choice is here. 38 subjects switch more than once; as elsewhere in METARET the
## total count is used.
## participant_aversion is the SOEP general risk question (0 = afraid of risk,
## 10 = willing to take risks) and goes to soep.
## gender: 1 = woman, 0 = man. Age was not collected.
df <- read_csv("Data/Flambard_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = rowSums(across(starts_with("aversion_choice_"))),
            soep,
            gender,
            country = "France",
            city = "Lille")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Flambard2024",
         paper = "Flambard et al. 2024")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Flambard_et_al_2024/formatted_dataset.csv")
