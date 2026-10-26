#### Clist, P., D'Exelle, B. & Verschoor, A. (2025).
#### Risk Taking With Social Consequences.
#### Journal of Development Studies. https://doi.org/10.1080/00220388.2025.2453523
#### Data: https://doi.org/10.7910/DVN/MN2BMQ

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## prepared.dta from Dataverse, one row per subject: 319 adults from a random
## sample of 20 villages in rural eastern Uganda, lab-in-the-field. Only the
## id, village, part-1 choice, age and female were copied here.
## Part 1 (decisions1) is an individual Eckel-Grossman style choice among eight
## 50/50 lotteries (Table 1, UGX): 7 = 7000/7000, 6 = 6000/10000,
## 5 = 5000/12000, 4 = 4000/14000, 3 = 3000/16000, 2 = 2000/18000,
## 1 = 1000/20000, 0 = 0/22000. One of the seven decisions was paid.
## Parts 2-3 are choices that also pay a partner and are not used.
## METARET codes EG choices from the safest (1) to the riskiest, so
## choice = 8 - lottery number.
df <- read_csv("Data/Clist_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "EG",
            choice = 8 - decisions1,
            age = as.numeric(age),
            gender = as.numeric(female),
            country = "Uganda",
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Clist2025",
         paper = "Clist et al. 2025")

## field experiment in several villages, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Clist_et_al_2025/formatted_dataset.csv")
