#### Fornwagner, H. (2026). Hot flashes, cold feet? No evidence of a menopause
#### effect on risk preferences.
#### Journal of Economic Psychology, 116, 102923. https://doi.org/10.1016/j.joep.2026.102923
#### Data: https://osf.io/upjgm/ (view-only link from the paper)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' Menopause_clean.dta (the final
## sample after the preregistered exclusions): 1829 women living in the UK,
## recruited on Prolific, online oTree experiment. Only the investment, its
## parameters, age, menopause status and the British dummy were kept; Prolific
## ids and the raw oTree/Prolific exports on OSF were not copied.
## Risk task (Gneezy and Potters 1997): endowment 0.50 GBP, the amount invested
## (steps of 0.10) is multiplied by 2.5 with 50%, else lost.
## All participants are women (gender = 1).
df <- read_csv("Data/Fornwagner_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = lottery_investme,
            age,
            gender = 1,
            country = "United Kingdom")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Fornwagner2026",
         paper = "Fornwagner 2026")

## online experiment, and the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fornwagner_2026/formatted_dataset.csv")
