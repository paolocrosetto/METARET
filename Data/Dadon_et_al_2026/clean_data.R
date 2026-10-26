#### Dadon, E., Villeval, M. C. & Zultan, R. (2026).
#### Corporate social responsibility as a signal in the labor market.
#### Journal of Economic Behavior and Organization, 107384. https://doi.org/10.1016/j.jebo.2025.107384
#### Data: https://osf.io/5982g

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Data_DVZ.csv from the OSF replication package (variables in Replication_DVZ.txt).
## One row per subject x period x offer; risk and gender are constant within subject.
df <- read_csv("Data/Dadon_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## Gneezy-Potters investment task (part 3): endowment of 100 points, invest 0-100,
## 50% chance the investment pays 2.5 times the amount invested, 50% chance it is lost.
## risk = points invested. gender: 1 Male, 2 Female (missing for the first sessions,
## where the questionnaire did not record it).
df <- df %>% 
  distinct(sid, .keep_all = TRUE) %>% 
  transmute(subject = as.numeric(sid),
            choice = as.numeric(risk),
            ## 1 - female, 0 - male
            gender = case_when(gender == 2 ~ 1,
                               gender == 1 ~ 0,
                               TRUE ~ NA_real_))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "IG",
         bibkey = "Dadon2026",
         paper = "Dadon et al. 2026")

## GATE-LAB, Lyon
df$country = 'France'
df$city = 'Lyon'
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
df %>% write_csv("Data/Dadon_et_al_2026/formatted_dataset.csv")
