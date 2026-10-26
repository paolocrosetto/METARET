#### Chan, N. W., Knowles, S., Peeters, R. & Wolk, L. (2024).
#### Cost-(in)effective public good provision: an experimental exploration.
#### Theory and Decision, 96, 397-442. https://doi.org/10.1007/s11238-023-09956-6
#### Data: https://osf.io/9br85/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## data/full-data.csv from OSF, one row per subject: 308 Prolific participants
## (two sessions, Aug 2020 and Apr 2023). Only session, risk, gender and age were copied.
## Post-experiment Eckel-Grossman menu of 11 50/50 lotteries (Appendix of the
## journal version): A 10/10, B 12/9, C 14/8, D 16/7, E 18/6, F 20/5, G 22/4,
## H 24/3, I 26/2, J 28/1, K 30/0. risk = 1 (A, safest) ... 11 (K) = METARET choice.
## gender: "Female" = 1, "Male" = 0, other = NA; an age of 0 is set to missing.
## Prolific sample, country not recorded.
df <- read_csv("Data/Chan_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "EG",
            choice = risk,
            age = if_else(age < 15, NA_real_, as.numeric(age)),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0, TRUE ~ NA_real_),
            country = NA_character_,
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Chan2024",
         paper = "Chan et al. 2024")

## online experiment, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chan_et_al_2024/formatted_dataset.csv")
