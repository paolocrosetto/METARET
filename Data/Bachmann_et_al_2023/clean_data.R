#### Bachmann, K., Lot, A., Xu, X. & Hens, T. (2023).
#### Experimental research on retirement decision-making: Evidence from replications.
#### Journal of Banking and Finance, 152, 106851. https://doi.org/10.1016/j.jbankfin.2023.106851
#### Data: https://osf.io/jbkwz/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Five online replications (Anderhub et al. 2000, Fatas et al. 2007, Koehler et al.
## 2015, Meissner 2016, Blaufus and Milde 2021) with subjects from the German panel
## of the market research company Bilendi, Sep 2021 - Mar 2022. A subject who
## started one replication was excluded from the others, so the samples do not overlap.
## original_dataset.csv has one row per subject who finished (the authors'
## "finished == 1 | !missing(delay_choice)" rule), built from the five raw files
## by extract_subjects_from_raw.R: 339 + 530 + 344 + 278 + 522 = 2013, as in Table 2.
## Risk task after the main task (screenshots): invest a % of the task earnings in a
## risky asset that gains 2.5 times the amount with 1/3 and loses it with 2/3
## (Gneezy and Potters). risk = % invested.
## Age is approximated as 2022 - birth year (sessions 2021-2022, so +/- 1 year).
## gender: "female" = 1, "male" = 0, "no_answer" = NA.
df <- read_csv("Data/Bachmann_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = risk,
            age = 2022 - birth_year,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0, TRUE ~ NA_real_),
            country = "Germany",
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Bachmann2023",
         paper = "Bachmann et al. 2023")

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
df %>% write_csv("Data/Bachmann_et_al_2023/formatted_dataset.csv")
