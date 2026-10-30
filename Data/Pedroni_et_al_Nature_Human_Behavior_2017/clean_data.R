#### Pedroni et al. "The Risk Elicitation Puzzle", Nature Human Behaviour 2017
#### Frey et al. "Risk preference shares the psychometric structure of major psychological traits", Science Advances 2017

#### cleaning data to be used for the meta-anlaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)
source("Data/inconsistent_rows.R")


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

## Inconsistent HL answers (29.10.2026): CheckHolt 1 or 2. Rebuilt from the row
## answers of problem 1 (mpl.csv, dp == 1, the standard Holt-Laury list;
## choice 0 = B there), the rule of the site -- a single switch to B and B in
## row 10 -- gives exactly the authors' 1331 consistent and 174 inconsistent
## subjects. The 174 are kept for the download only, with inconsistent = 1 and
## one row per switch to B (Data/inconsistent_rows.R), added after the other
## rows. MPLr counts the B choices minus one (10 - the row where B starts).
## Since 30.10.2026 choice is the number of B choices, MPLr + 1 = 11 - the row
## where B starts, the convention of every other HL paper with the standard
## bounds (before, choice was MPLr and r fell one interval too low); a switch at
## row k is coded 11 - k (0 if B is never taken).
mpl_rows <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/mpl/mpl.csv") %>%
  filter(dp == 1) %>%
  arrange(partid, decision) %>%
  group_by(partid) %>%
  summarise(points = list(switch_points(as.numeric(choice == 0))), .groups = "drop")
hl_inc_ids <- hl$partid[hl$CheckHolt %in% c(1, 2)]
stopifnot(length(hl_inc_ids) == 174)

hl <- hl %>% 
  select(subject = partid, 
         inconsistent = CheckHolt,
         HL = MPLr) %>% 
  mutate(HL = HL + 1) %>% 
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

## the inconsistent HL answers, with the subject's demographics and
## questionnaires, after the consistent rows
hl_inc <- mpl_rows %>%
  filter(partid %in% hl_inc_ids) %>%
  rename(subject = partid) %>%
  mutate(task = "HL", inconsistent = 1) %>%
  left_join(left_join(id, quest, by = "subject"), by = "subject") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
df <- df %>%
  mutate(inconsistent = 0) %>%
  bind_rows(hl_inc)

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
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/formatted_dataset.csv")
