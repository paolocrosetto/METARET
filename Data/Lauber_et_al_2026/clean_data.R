#### Lauber, A., March, C. & Sahm, M. (2026). Three-player round-robin tournaments in the
#### lab: Lottery contests vs. all-pay auctions.
#### Journal of Behavioral and Experimental Economics, 124, 102605. https://doi.org/10.1016/j.socec.2026.102605
#### Data: https://data.mendeley.com/datasets/j6wjzgd8sr/1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## LauberMarchSahm_RRT-LCvsAPA_Data.xlsx (sheet Dataset) is one row per subject and
## period; one row per subject was kept (138 students, BLER lab, University of
## Bamberg, 2016-2017, two treatments of 69).
## Part 1 risk task (footnote 6): ten rows, a sure 180 points against a lottery
## paying 400 points with probability 0.1, 0.2, ..., 1.0, otherwise 0; one row paid.
## riskDecisions[k]: 1 = safe, 2 = risky. As for Chlass2026 (sure amount against
## a lottery with a rising probability), this is coded as CEPL;
## choice = number of risky choices = 10 - SafeChoices = 11 - the row where the
## lottery starts. Inconsistent (counted until 29.10.2026): 12 subjects switch
## more than once and some take the sure 180 in row 10, where the lottery pays
## 400 for sure, 14 in all; kept for the download only, with inconsistent = 1
## and one row per switch to the lottery (Data/inconsistent_rows.R).
## The self-assessed risk question is on a 1-7 scale (not SOEP) and is not used.
df <- read_csv("Data/Lauber_et_al_2026/original_dataset.csv", show_col_types = FALSE)
source("Data/inconsistent_rows.R")
B_risk <- (as.matrix(df[, paste0("riskDecisions[", 1:10, "]")]) == 2) * 1

df <- df %>% 
  transmute(subject = row_number(),
            task = "CEPL",
            points = lapply(seq_len(n()), function(i) switch_points(B_risk[i, ])),
            inconsistent = as.numeric(!apply(B_risk, 1, single_switch) | B_risk[, 10] == 0),
            age = as.numeric(Age),
            gender = as.numeric(Female),
            country = "Germany",
            city = "Bamberg") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(n_distinct(df$subject[df$inconsistent == 1]) == 14)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Lauber2026",
         paper = "Lauber et al. 2026")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Lauber_et_al_2026/formatted_dataset.csv")
