#### Adema, J., Nikolka, T., Poutvaara, P. & Sunde, U. (2022). On the stability
#### of risk preferences: Measurement matters. Economics Letters, 210, 110172.
#### https://doi.org/10.1016/j.econlet.2021.110172
#### Data: Mendeley Data jzysn9brrb (ANPS_main.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## A survey of university students in the Czech Republic, India, Mexico and
## Spain, asked twice: in 2019 and again during the Covid-19 pandemic. Only the
## first wave (WAVE_dum == 0, answers dated April-December 2019) is kept, so
## that each person appears once and the measure is not taken under the
## pandemic shock the paper studies.
##
## Two measures:
##  - the investment question the paper calls incentivized: out of 100 euros,
##    the invested part is lost or returned 2.5 times with probability 1/2 --
##    the Gneezy-Potters setting with k = 2.5 (Adema2022 block of generate_r.R).
##    choice = euros invested, 0 ... 100. It was answered by 1,834 of the
##    3,572 first-wave respondents;
##  - the general self-assessment, "on a scale 1-10" in the paper, rescaled
##    linearly to 0-10 as for Drouvelis_Qiu_2026: soep = (risk_stated - 1) * 10 / 9.
## Respondents with the investment answer are IG rows carrying their soep;
## those with only the self-assessment are 'quest_only' rows, and
## generate_data_for_app.R moves their `choice` into `soep`. The 307 with
## neither are dropped.
##
## gender: female 1, male 0. Two ages (77 and 100) are not credible for a
## student sample and are set to NA.
df <- read_csv("Data/Adema_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 3572,
          all(df$risk_elicited %in% c(0:100, NA)), all(df$risk_stated %in% c(1:10, NA)))

df <- df %>%
  filter(!is.na(risk_elicited) | !is.na(risk_stated)) %>%
  mutate(soep = (risk_stated - 1) * 10 / 9)

stopifnot(nrow(df) == 3265, sum(!is.na(df$risk_elicited)) == 1834)

df <- df %>%
  transmute(subject,
            task = if_else(is.na(risk_elicited), "quest_only", "IG"),
            ## choice is what generate_data_for_app.R moves into soep for quest_only
            choice = if_else(is.na(risk_elicited), soep, risk_elicited),
            soep = if_else(is.na(risk_elicited), NA_real_, soep),
            gender = female,
            age = if_else(age > 60, NA_real_, age),
            country,
            bibkey = "Adema2022",
            paper = "Adema et al. 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
## get_r only on the IG rows: it has no value to return for quest_only
ig <- df$task == "IG"
df$r <- NA_real_
df$r[ig] <- purrr::pmap_dbl(list(df$bibkey[ig], df$task[ig], df$choice[ig]), get_r)

## the map shows only the country, so no coordinates
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Adema_et_al_2022/formatted_dataset.csv")
