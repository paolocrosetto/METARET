#### U. Weitzel; C. Huber; J. Huber; M. Kirchler; F. Lindner; J. Rose (2019).
#### Bubbles and Financial Professionals

#### The Review of Financial Studies
#### https://doi.org/10.1093/rfs/hhz093

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- readxl::read_excel("Data/Weitzel_et_al_2020/Weitzel_etal_2019_RiskMeasures.xls") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires

df <- df %>% pivot_longer(BRET, names_to = 'task', values_to = 'choice')

# rename column names
df <- df %>%
  rename(
    soep = RiskType1,
    soep_financial = RiskType2,
    subject = SubjectID)

# adding paper name and bibkey

df <- df %>%
  mutate(bibkey = "Weitzel2019",
         paper = "Weitzel, Huber, Huber, Kirchler, Lindner and Rose 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## No country: the student sessions were split between Innsbruck and Nijmegen
## and the data file does not say which subject sat where, so guessing one for
## all 384 would put them on the map in the wrong place.
df$country = NA_character_

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Weitzel_et_al_2020/formatted_dataset.csv")
