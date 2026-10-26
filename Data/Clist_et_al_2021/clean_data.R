#### Clist, P., D'Exelle, B. & Verschoor, A. (2021).
#### An endowment effect for risk levels: Evidence from a Ugandan lab.
#### Journal of Economic Behavior and Organization, 182, 297-310. https://doi.org/10.1016/j.jebo.2020.12.013

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## all.dta from the authors' replication files: 292 randomly sampled adults
## from farming villages in eastern Uganda (lab-in-the-field). Only treatment,
## the two decisions, sex and age were copied here (village names, religion and
## marital status were left out).
## Task: ten 500 UGX coins split between a safe and a risky basket; risky coins
## are doubled with an 80% chance and lost with a 20% chance (one draw for all).
## risky1 = coins in the risky basket in round 1 (0-10).
## treatment = starting position of the coins: 1 = investment (9 safe, 1 risky),
## 2 = neutral (1 safe, 1 risky, 8 in between), 3 = insurance (9 risky, 1 safe).
## The starting position shifted choices (the paper's main result), so only the
## neutral treatment is kept, and only round 1 (round 2 follows a social signal).
## sex: 1 = female (51/52/58% by treatment as in Table 5), 2 = male.
df <- read_csv("Data/Clist_et_al_2021/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(treatment == 2) %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = risky1,
            age = age,
            gender = case_when(sex == 1 ~ 1, sex == 2 ~ 0, TRUE ~ NA_real_),
            country = "Uganda",
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Clist2021",
         paper = "Clist et al. 2021")

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
df %>% write_csv("Data/Clist_et_al_2021/formatted_dataset.csv")
