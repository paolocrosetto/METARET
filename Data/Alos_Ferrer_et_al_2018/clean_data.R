#### Alós-Ferrer, C., García-Segarra, J. & Ritschel, A. (2018). Performance curiosity.
#### Journal of Economic Psychology, 64, 1-17. https://doi.org/10.1016/j.joep.2017.08.002
#### Data: https://osf.io/5hkj6/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Experiment1PerfCuriosity.csv, the authors' file (one row per subject, no personal data):
## Experiment 1, 180 students (90 women, 90 men) at the Cologne Laboratory for
## Economic Research, z-Tree. At the end everyone answered the Holt-Laury
## lottery questionnaire; risk1safe ... risk10safe = 1 if the safe lottery was
## chosen in that row. choice = number of risky choices, i.e. 11 - the row
## where B starts.
## Experiment 2 (osf file Experiment2PerfCuriosity.csv) has no risk task.
## female: 1 = woman, 0 = man.
## Inconsistent (inconsistent = 1, kept for the download only, see
## Data/inconsistent_rows.R): the 9 subjects who switch more than once, one row
## per switch to B, and the 7 others who keep the safe lottery in row 10, where
## B pays the high prize for sure (dominated) -- 16 in all.
df <- read_csv("Data/Alos_Ferrer_et_al_2018/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
B <- 1 - as.matrix(df[paste0("risk", 1:10, "safe")])
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject = subject,
            task = "HL",
            points, inconsistent,
            age = age,
            gender = female,
            country = "Germany",
            city = "Cologne")
stopifnot(sum(df$inconsistent) == 16)
df <- df %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "AlosFerrer2018",
         paper = "Alos-Ferrer et al. 2018")

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
df %>% write_csv("Data/Alos_Ferrer_et_al_2018/formatted_dataset.csv")
