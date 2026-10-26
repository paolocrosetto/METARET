#### Zilker, V. & Pachur, T. (2021). Does option complexity contribute to the
#### framing effect, loss aversion, and delay discounting in younger and older
#### adults?
#### Journal of Behavioral Decision Making, 34(5).
#### https://doi.org/10.1002/bdm.2224
#### Data: https://osf.io/bj2tv (folder data, general_files_matrix.Rda)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Eighty younger adults aged 18 to 28 and eighty older adults aged 61 to 77,
## recruited from the participant pool of the Max Planck Institute for Human
## Development in Berlin. The three tasks of the study -- framing, loss
## aversion and delay discounting -- are choices between manipulated option
## sets rather than a risk elicitation, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## The survey carried the SOEP triple. The paper: "Participants were also asked
## to indicate their self-reported risk preference on a one-item general risk
## question (a higher value indicates a higher propensity to take risks; Dohmen
## et al., 2011) and to self-report their impulsivity and patience on standard
## items."
##
## general_risk is that item. The answers run 1 to 9 here, with nobody at 0 or
## 10; the two neighbouring items in the same file, general_time and
## general_impulsivity, both run 0 to 10, so the scale is the usual 0 to 10 and
## the answers need no shifting.
##
## general_time is the patience item and general_impulsivity the impulsiveness
## one, filled into soep_patience and soep_impulsive. Note that the paper
## states the direction only for the risk item; the other two are taken to run
## the standard SOEP way.
##
## The file is named general_files_matrix.Rda but is a semicolon-separated text
## table, not an R workspace.
df <- read_csv("Data/Zilker_Pachur_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 160, sum(df$gender == "w") == 79)

## gender: "w" for weiblich, "m" for maennlich
df <- df %>%
  filter(!is.na(general_risk)) %>%
  transmute(subject = subjid,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(general_risk),
            soep_patience = as.numeric(general_time),
            soep_impulsive = as.numeric(general_impulsivity),
            gender = case_when(gender == "w" ~ 1, gender == "m" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Zilker2021",
            paper = "Zilker and Pachur 2021")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Max Planck Institute for Human Development, Berlin
df$country = 'Germany'
df$city = 'Berlin'
df$lattitude = '52.4647'
df$longitude = '13.2889'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zilker_Pachur_2021/formatted_dataset.csv")
