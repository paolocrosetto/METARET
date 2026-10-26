#### Orland, A. (2025).
#### Sharing rules in Bertrand duopolies with increasing returns.
#### Journal of Economic Behavior and Organization, 106968. https://doi.org/10.1016/j.jebo.2025.106968
#### Data: https://doi.org/10.17605/osf.io/jnufw

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## SharingRules_data_20220913.xlsx from OSF. 100 subjects x 40 periods; the
## questionnaire and the risk task are recorded only in period 40 (99 elsewhere).
df <- read_excel("Data/Orland_2025/original_dataset.xlsx")

## Gneezy-Potters investment task: endowment of 1 euro, invested in 10-cent steps,
## 50% chance to lose the investment, 50% chance it pays 2.5-fold.
## riskaversion = number of 10-cent units invested (0-10), despite its name:
## checked against the payoffs, TotalProfit - totalearnings in period 40 equals
## (10 - x)*0.1 after a loss and (10 - x)*0.1 + 2.5*x*0.1 after a win.
## gender: 1 male, 2 female, 3 non-binary (order of the questionnaire item);
## non-binary is set to missing, as gender is coded 1 female / 0 male here.
df <- df %>% 
  filter(Period == 40) %>% 
  transmute(subject = row_number(),
            choice = as.numeric(riskaversion),
            gender = case_when(gender == 2 ~ 1,
                               gender == 1 ~ 0,
                               TRUE ~ NA_real_))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "IG",
         bibkey = "Orland2025",
         paper = "Orland 2025")

## Potsdam Laboratory for Economic Experiments (PLEx), University of Potsdam
df$country = 'Germany'
df$city = 'Potsdam'
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
df %>% write_csv("Data/Orland_2025/formatted_dataset.csv")
