#### Jaspersen, J. G., König-Kersting, C. & Ragin, M. A. (2026). Prospective
#### reference theory: Experimental evidence and the connection to anchoring.
#### Journal of Risk and Uncertainty, 72, 381-413.
#### https://doi.org/10.1007/s11166-026-09482-0
#### Data: OSF hj42w (all_apps_wide_2023-11-27.csv, oTree export); the lists are
#### in instructions/Instructions_en_nov16.pdf

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 198 students of the Innsbruck EconLab, Austria, 10 sessions on 20, 21 and
## 27 November 2023. One of 11 choice lists was paid. The first three are
## certainty-equivalent lists: 20 EUR with probability 25% (ce1), 50% (ce2) or
## 75% (ce3), else 0, against a sure 1, 2, ..., 19 EUR, with enforced
## monotonicity. The 50% list is used, as for the other CEPL papers on the site;
## ce1, ce3 and the remaining eight lists (dominance and CPT patterns) are not.
## ce2_first_b is the first row where the sure amount was taken, so the
## certainty equivalent lies between first_b - 1 and first_b EUR; 0 means the
## lottery was kept in all 19 rows and, as in the authors' do-file, is recoded to
## 20 (CE above 19 EUR). There is no risk questionnaire. original_dataset.csv
## keeps a session number, the three switching rows, age, sex and the economics
## student dummy; seat labels, oTree codes and start times are dropped and
## subjects are row numbers.
df <- read_csv("Data/Jaspersen_et_al_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 198)

df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = if_else(ce2_first_b == 0, 20, ce2_first_b),
            age,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0),
            country = "Austria",
            city = "Innsbruck",
            bibkey = "Jaspersen2026",
            paper = "Jaspersen et al. 2026")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '47.2692'
df$longitude = '11.4041'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Jaspersen_et_al_2026/formatted_dataset.csv")
