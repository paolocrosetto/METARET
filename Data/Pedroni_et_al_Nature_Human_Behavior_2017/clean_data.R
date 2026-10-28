#### Pedroni et al. "The Risk Elicitation Puzzle", Nature Human Behaviour 2017
#### Frey et al. "Risk preference shares the psychometric structure of major psychological traits", Science Advances 2017

#### cleaning data to be used for the meta-anlaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data

## data is split over several files. Getting them one by one

# participants ID and demographifcs
id <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/participants/participants.csv")

id <- id %>% 
  select(subject = partid, gender = sex, age, country = location) %>% 
  mutate(gender = if_else(gender == "female", 1, 0)) %>% 
  mutate(country = if_else(country == "Basel", "Switzerland", "Germany"))

# BART: adjusted pump by subject
bart <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/bart/bart.csv")

bart <- bart %>% 
  select(subject = partid, BART = pumps_adj)

# Quetionnaires -- note MANY MORE done, now only using some for the time being
quest <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/quest/quest_scores.csv")

## DOSPERT: the 40-item German version, answered "von 1 bis 5" (sehr
## unwahrscheinlich ... sehr wahrscheinlich; quest_print.pdf). Deth, Dhea, Drec and
## Dsoc are the means of their 8 items, Dgam and Dinv of their 4 (Dgam is exactly
## items 3, 11, 22 and 33), so doall, the mean of all 40 items, is the item-weighted
## mean of the six; checked against the raw items in quest_raw.csv, it matches the
## item mean for 99.7% of the participants. The other DOSPERT data in METARET use
## the 1-7 scale, so every score is rescaled linearly, as for Michael2020:
## 1 + (x - 1) * 6 / 4.
to7 <- function(x) 1 + (x - 1) * 6 / 4

quest <- quest %>%
  select(subject = partid,
         soep = SOEP,
         Deth, Dinv, Dgam, Dhea, Drec, Dsoc) %>%
  mutate(soep = soep - 1,
         doall    = to7((8 * (Deth + Dhea + Drec + Dsoc) + 4 * (Dgam + Dinv)) / 40),
         doethic  = to7(Deth),
         doinvest = to7(Dinv),
         dogamble = to7(Dgam),
         dohealth = to7(Dhea),
         dorecre  = to7(Drec),
         dosocial = to7(Dsoc)) %>%
  select(-Deth, -Dinv, -Dgam, -Dhea, -Drec, -Dsoc)

# CEPL -- multiple price list
hl <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/mpl/mplBehavior.csv")

hl <- hl %>% 
  select(subject = partid, 
         inconsistent = CheckHolt,
         HL = MPLr) %>% 
  filter(inconsistent == 0) %>% 
  filter(!is.na(HL)) %>% 
  select(-inconsistent)

## merging
df <- left_join(id, quest, by = "subject")
df <- left_join(df, bart, by = "subject")
df <- left_join(df, hl, by = "subject")

## gathering
df <- df %>% 
  gather(task, choice, -subject, -gender, -age, -soep, -doall, -doethic, -dogamble, -doinvest,
         -dohealth, -dorecre, -dosocial, -country)

## 
df <- df %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Frey2017",
         paper = "Frey et al Science Advances 2017",
         treatment = "")

## better qualify the location
df <- df %>% 
  mutate(city = if_else(country == "Germany", "Berlin", "Basel"),
## The map shows only the country, so no coordinates (removed on 23.10.2026).
         longitude = NA_real_,
         latitude = NA_real_)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/formatted_dataset.csv")
