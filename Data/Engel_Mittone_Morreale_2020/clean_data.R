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
## choice = number of risky choices, i.e. 11 - the row where B starts.
## The 6 subjects who switch back from B to A (counted until 29.10.2026) are
## kept for the download only, with inconsistent = 1 and one row per switch to
## B (Data/inconsistent_rows.R); nobody kept A in row 10.
## sex: "Femminile" = 1, "Maschile" = 0.
df <- read_csv("Data/Engel_Mittone_Morreale_2020/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
B <- (as.matrix(df[paste0("hl_", 1:10)]) == 2) * 1
df <- df %>% 
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject = subject,
            task = "HL",
            points, inconsistent,
            age = age,
            gender = case_when(sex == "Femminile" ~ 1, sex == "Maschile" ~ 0, TRUE ~ NA_real_),
            country = "Italy",
            city = "Trento")
stopifnot(sum(df$inconsistent) == 6)
df <- df %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Engel2020",
         paper = "Engel et al. 2020")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Engel_Mittone_Morreale_2020/formatted_dataset.csv")
