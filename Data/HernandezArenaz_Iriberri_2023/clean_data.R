#### Hernandez-Arenaz, I. & Iriberri, N. (2023). Gender differences in
#### alternating-offer bargaining: an experimental study.
#### Experimental Economics, 26, 879-914.
#### https://doi.org/10.1007/s10683-023-09796-9
#### Data: https://osf.io/9wu2e (Bargaining_level_2021.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory bargaining experiment in z-Tree, recruited "through ORSEE ...
## with a total of 562 participants -- 278 (49.4%) men", in Bilbao (University
## of the Basque Country; February to May 2017) and Castellon (Universitat
## Jaume I; November 2020). The bargaining is not a risk task, but at the end
## "we also elicited risk attitudes following the methodology in Eckel and
## Grossman (2002)", incentivized.
##
## The menu is not in the paper; it is in the z-Tree program
## 3_Controles_withSVO.ztt ("Tienes que elegir una de las 8 posibles opciones",
## each outcome 50%), where Payment_Risk is set by Risk_Pref: 1.5/1.5,
## 1.3/1.8, 1.1/2.1, 0.9/2.4, 0.7/2.7, 0.6/2.8, 0.4/2.9, 0/3 euros. Cuts in the
## HernandezArenaz2023 block of generate_r.R.
##
## The data are at the bargaining level: one row per pair and period, with the
## proposer's and the responder's traits side by side. original_dataset.csv
## stacks the two roles and keeps one row per participant (562, every
## participant with one risk answer, one gender and one age), which matches
## the paper's count of men and women exactly.
df <- read_csv("Data/HernandezArenaz_Iriberri_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 562, sum(df$male == 1) == 278, all(df$risk_pref %in% 1:8))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = risk_pref,
            gender = 1 - male,
            age,
            bilbao,
            bibkey = "HernandezArenaz2023",
            paper = "Hernandez-Arenaz and Iriberri 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## two laboratories
df <- df %>%
  mutate(country = 'Spain',
         city = if_else(bilbao == 1, 'Bilbao', 'Castellon'),
         lattitude = if_else(bilbao == 1, '43.2630', '39.9930'),
         longitude = if_else(bilbao == 1, '-2.9350', '-0.0690')) %>%
  select(-bilbao)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/HernandezArenaz_Iriberri_2023/formatted_dataset.csv")
