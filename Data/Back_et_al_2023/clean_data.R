#### Back, C., Morana, S. & Spann, M. (2023).
#### When do robo-advisors make us better investors? The impact of social
#### design elements on investor behavior.
#### Journal of Behavioral and Experimental Economics, 103, 101984.
#### https://doi.org/10.1016/j.socec.2023.101984
#### Data: https://osf.io/z9jd5

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Two separate studies on the disposition effect with a robo-advisor, both at
## the MELESSA laboratory of LMU Munich, with no subject in common (the user
## ids do not overlap). Neither has an incentivised risk elicitation task, so
## this paper contributes questionnaire answers only and the rows are marked
## 'quest_only'; generate_data_for_app.R moves `choice` into `soep`.
##
## What is used is the general risk question of Dohmen et al. (2011), which the
## paper lists among its self-assessed control variables. It was asked on a
## 7-point scale here rather than the usual 0-10, so it is rescaled linearly,
## as Drouvelis and Qiu's 1-10 answers are.
##
## The direction of that scale is documented nowhere -- the variable carries no
## value labels -- so it was settled on the data: men score 4.49 against women's
## 3.27 in study 1 and 4.49 against 3.62 in study 2, both differences far beyond
## chance. A gap of that size and sign only arises when the high end means more
## willing to take risks, which is also the direction of the SOEP scale.
##
## Gender is coded G1 to G4 with no labels either. The study 1 do-file sets
## male = 1 for G2, and the counts agree with the paper: 120 of 195 men in study
## 1 is 62%, 109 of 407 in study 2 is 27%, which is what the paper reports. G3
## and G4 are the few other answers and are left missing.
##
## The loss aversion list of Gaechter et al. (2021) was also run (ten binary
## items). It measures lambda, not the curvature this site stores, so it is
## left out.
read_study <- function(file, risk, gender, age, uid) {
  read_dta(file.path("Data/Back_et_al_2023", file)) %>%
    transmute(uid = as.character(.data[[uid]]),
              risk = as.numeric(.data[[risk]]),
              g = as.character(.data[[gender]]),
              age = as.numeric(.data[[age]]),
              .keep_all = FALSE)
}

## Study 1: 197 rows, two of them test runs left in the file by the authors
## (their ids carry "TEST", and their own do-file drops those rows), so 195
## subjects -- the number the paper reports.
s1_raw <- read_dta("Data/Back_et_al_2023/original_study1.dta") %>%
  filter(!grepl("TEST", as.character(resultuserid)))

## Both studies dropped the subjects who failed at least two of three attention
## checks in the post-experimental survey -- the survey that carries the risk
## question -- so they are dropped here too. The checks are rebuilt from the
## survey file alone: a subject sees only the version of each check that belongs
## to their treatment, so the others are simply empty.
##
## Study 1: the robo-advisor group is the one asked trustac1, check one passes
## at 7, check two (moderatorsac2) at 1, and the name check fails only for that
## group when manipulationscheck2 is not "MC3A". This leaves 2 failures, exactly
## the number the paper excludes.
s1 <- s1_raw %>%
  mutate(robo = !is.na(trustac1),
         a_name = if_else(robo & as.character(manipulationscheck2) != "MC3A", 0, 1),
         a1 = if_else(!is.na(trustac1) & as.numeric(trustac1) == 7, 1, 0),
         a2 = if_else(!is.na(moderatorsac2) & as.numeric(moderatorsac2) == 1, 1, 0)) %>%
  filter(a_name + a1 + a2 >= 2) %>%
  transmute(risk = as.numeric(attitudetowardsriskrisk1),
            g = as.character(gender),
            age = as.numeric(age))

## Study 2: 408 rows for 407 subjects -- one id appears twice -- and the same
## three checks, written differently in this file. Dropping the repeat first
## leaves 19 failures, again exactly the number the paper excludes.
s2 <- read_dta("Data/Back_et_al_2023/original_study2.dta") %>%
  filter(!duplicated(as.character(resultUserId))) %>%
  mutate(a0 = if_else(coalesce(as.character(check35) == "MC3A",  FALSE) |
                      coalesce(as.character(check46) == "MC3C",  FALSE), 1, 0),
         ac1 = coalesce(as.numeric(TrustG2G3G5AC1), as.numeric(TrustG4AC1)),
         a1 = if_else(!is.na(ac1) & ac1 == 7, 1, 0),
         a2 = if_else(!is.na(as.numeric(ModeratorsAC2)) & as.numeric(ModeratorsAC2) == 1, 1, 0)) %>%
  filter(a0 + a1 + a2 >= 2) %>%
  transmute(risk = as.numeric(AttitudeTowardsRiskRisk1),
            g = as.character(Gender),
            age = as.numeric(Age))

df <- bind_rows(s1, s2) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = (risk - 1) * 10 / 6,
            gender = case_when(g == "G1" ~ 1, g == "G2" ~ 0, TRUE ~ NA_real_),
            age,
            bibkey = "Back2023",
            paper = "Back et al. 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## MELESSA, LMU Munich.
df$country = 'Germany'
df$city = 'Munich'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Back_et_al_2023/formatted_dataset.csv")
