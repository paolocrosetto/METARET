#### Razen, M., Huber, J., Hueber, L., Kirchler, M. & Stefan, M. (2021).
#### Financial literacy, economic preferences, and adolescents' field behavior.
#### Finance Research Letters, 40, 101728. https://doi.org/10.1016/j.frl.2020.101728
#### Data: https://osf.io/sg5wr/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## data.dta from OSF: 627 pupils in 35 school classes in Tyrol (Austria), one row each.
df <- read_dta("Data/Razen_et_al_2021/original_dataset.dta")

## Eckel-Grossman task (Table 1 of the paper): choose one of six 50/50 lotteries
##   1) 10/10  2) 13/8  3) 16/6  4) 19/4  5) 22/2  6) 24/0 (euros)
## risk = number of the chosen lottery (1 = safest). 41 pupils have no choice and are dropped.
## self_risk_general and self_risk_finance are the SOEP items on a 0-10 scale.
## male: 1 male, 0 female.
df <- df %>% 
  filter(!is.na(risk)) %>% 
  transmute(subject = row_number(),
            choice = as.numeric(risk),
            soep = as.numeric(self_risk_general),
            soep_financial = as.numeric(self_risk_finance),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = case_when(male == 1 ~ 0,
                               male == 0 ~ 1,
                               TRUE ~ NA_real_))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "EG",
         bibkey = "Razen2021",
         paper = "Razen et al. 2021")

## schools across the province of Tyrol; coordinates of Innsbruck
df$country = 'Austria'
df$city = 'Tyrol'
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
df %>% write_csv("Data/Razen_et_al_2021/formatted_dataset.csv")
