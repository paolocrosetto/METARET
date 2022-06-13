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
  select(subject = partid, gender = sex, age) %>% 
  mutate(gender = if_else(gender == "female", 1, 0))

# BART: adjusted pump by subject
bart <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/bart/bart.csv")

bart <- bart %>% 
  select(subject = partid, BART = pumps_adj)

# Quetionnaires -- note MANY MORE done, now only using some for the time being
quest <- read_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/original_data/quest/quest_scores.csv")

quest <- quest %>% 
  select(subject = partid, 
                soep = SOEP,
                dogamble = Dgam,
                doinvest = Dinv,
                dohealth = Dhea,
         Deth, Drec, Dsoc) %>% 
  mutate(soep = soep - 1) %>% 
  mutate(doall = 1+(Deth+Drec+dogamble+dohealth+doinvest+Dsoc)/6) %>%  ##TODO this is just a hack, as renato about this
  select(-Deth, -Drec, -Dsoc)

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
  gather(task, choice, -subject, -gender, -age, -soep, -doall, -dogamble, -doinvest, -dohealth)

## 
df <- df %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Frey2017",
         paper = "Frey et al Science Advances 2017",
         treatment = "")

df$country = 'Austria'
df$city = "Innsbruck"
df$longitude = "11.398020"
df$lattitude = "47.269001"


## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Pedroni_et_al_Nature_Human_Behavior_2017/formatted_dataset.csv")
