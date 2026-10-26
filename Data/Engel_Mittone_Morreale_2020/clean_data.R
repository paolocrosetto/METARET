#### Engel, C., Mittone, L. & Morreale, A. (2020). Tax morale and fairness in conflict - an experiment.
#### Journal of Economic Psychology, 81, 102314. https://doi.org/10.1016/j.joep.2020.102314
#### Data: https://osf.io/tckgs/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' raw oTree files
## EMM181127raw.dta and EMM181206raw.dta (one row per subject and round): one row
## per subject was kept, with only session, age, sex and the ten Holt-Laury
## answers; participant codes and IP addresses were dropped.
## 90 students in Trento (5 sessions of 18), oTree. hl_1 ... hl_10: 1 = option A
## (safe), 2 = option B (risky), as in the authors' EMM200820DataPreparation.do.
## choice = number of risky choices (5 subjects switch more than once; as
## elsewhere in METARET the total count is used).
## sex: "Femminile" = 1, "Maschile" = 0.
df <- read_csv("Data/Engel_Mittone_Morreale_2020/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = subject,
            task = "HL",
            choice = (hl_1 == 2) + (hl_2 == 2) + (hl_3 == 2) + (hl_4 == 2) + (hl_5 == 2) +
                     (hl_6 == 2) + (hl_7 == 2) + (hl_8 == 2) + (hl_9 == 2) + (hl_10 == 2),
            age = age,
            gender = case_when(sex == "Femminile" ~ 1, sex == "Maschile" ~ 0, TRUE ~ NA_real_),
            country = "Italy",
            city = "Trento")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Engel2020",
         paper = "Engel et al. 2020")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Engel_Mittone_Morreale_2020/formatted_dataset.csv")
