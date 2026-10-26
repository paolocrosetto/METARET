#### Mantovani, M. & Filippin, A. (2026).
#### When do prediction markets return average beliefs? Experimental evidence.
#### Games and Economic Behavior, 156, 135-148. https://doi.org/10.1016/j.geb.2025.12.004
#### Data: https://osf.io/c264t

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## dataset_full.dta from the OSF replication files (one row per subject x trade);
## 440 subjects in 20 sessions, EELAB Milan-Bicocca, 2017-2018.
df <- read_dta("Data/Mantovani_Filippin_2026/original_dataset.dta")

## Sessions 11-20 (220 subjects, call market) are the same subjects as in
## Filippin and Mantovani (2023), already in METARET: every one of them matches a
## subject there on investment, age, gender and the payoff of the risk task.
## Only the double-auction sessions 1-10, new to this paper, are kept.
df <- df %>% 
  filter(session <= 10) %>% 
  distinct(id, .keep_all = TRUE)

## Investment Game (Gneezy and Potters 1997): endowment of 200 MU, the invested
## amount pays 2.5 times with probability 1/2 and is lost otherwise.
## risk = MU invested. female: 1 female, 0 male.
df <- df %>% 
  transmute(subject = as.numeric(id),
            choice = as.numeric(risk),
            age = as.numeric(age),
            gender = as.numeric(female))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "IG",
         bibkey = "Mantovani2026",
         paper = "Mantovani and Filippin 2026")

## EELAB, University of Milan-Bicocca
df$country = 'Italy'
df$city = 'Milan'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mantovani_Filippin_2026/formatted_dataset.csv")
