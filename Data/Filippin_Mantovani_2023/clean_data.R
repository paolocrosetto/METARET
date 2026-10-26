#### Filippin, A. & Mantovani, M. (2023).
#### Risk aversion and information aggregation in binary-asset markets.
#### Quantitative Economics, 14. https://doi.org/10.3982/QE1981
#### Data: https://osf.io/d6ey5/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## dataset_call_randomprice.dta from the OSF replication files (one row per
## subject x period); 258 subjects in 12 sessions, EELAB Milan-Bicocca, 2018.
df <- read_dta("Data/Filippin_Mantovani_2023/original_dataset.dta")

## Investment Game (Gneezy and Potters 1997): endowment of 200 MU, the invested
## amount pays 2.5 times with probability 1/2 and is lost otherwise.
## risk = MU invested. female: 1 female, 0 male (matches the gender string).
## NB: 220 of these subjects (the call-market sessions) are also used in
## Mantovani and Filippin (2026); they are kept here and dropped there.
df <- df %>% 
  distinct(id, .keep_all = TRUE) %>% 
  transmute(subject = as.numeric(id),
            choice = as.numeric(risk),
            age = as.numeric(age),
            gender = as.numeric(female))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "IG",
         bibkey = "Filippin2023",
         paper = "Filippin and Mantovani 2023")

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
df %>% write_csv("Data/Filippin_Mantovani_2023/formatted_dataset.csv")
