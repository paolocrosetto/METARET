#### Beaud, M., Sun, Y. & Willinger, M. (2026).
#### No effect of endowment risk on dictator giving in the lab.
#### Economics Letters, 112774. https://doi.org/10.1016/j.econlet.2025.112774
#### Data: https://github.com/yujiangsun0209/Exposure-to-BR_Suppl (Data/data.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
df <- read_csv("Data/Beaud_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## Static BRET on a 10x10 grid, 100 boxes, one decision (see codebook_bret.md).
## bret_boxes_collected is the number of collected boxes.
## Survey items (0-10) follow the SOEP wording: risque_general -> soep,
## risque_argent -> soep_financial, patience -> soep_patience.
## gender: 0 = female in the original data (see the authors' analysis script).
## Age is computed from the year of birth and the session date.
df <- df %>% 
  transmute(subject = row_number(),
            choice = as.numeric(bret_boxes_collected),
            soep = as.numeric(risque_general),
            ## same column order as in df_mod.csv (soep, soep_patience, soep_impulsive, soep_financial)
            soep_patience = as.numeric(patience),
            soep_impulsive = NA_real_,   # not measured; kept only to preserve column order
            soep_financial = as.numeric(risque_argent),
            age = as.numeric(substr(session_date, 1, 4)) - as.numeric(year_of_birth),
            ## 1 - female, 0 - male
            gender = if_else(gender == 0, 1, 0))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "BRET",
         bibkey = "Beaud2026",
         paper = "Beaud et al. 2026")

## Laboratoire d'Economie Experimentale de Montpellier (LEEM)
df$country = 'France'
df$city = 'Montpellier'
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
df %>% write_csv("Data/Beaud_et_al_2026/formatted_dataset.csv")
