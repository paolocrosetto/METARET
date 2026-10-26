#### Masters, N., Lloyd, T. & Starmer, C. (2025).
#### Do emotional carryover effects carry over?
#### Journal of Behavioral and Experimental Economics, 114, 102312.
#### https://doi.org/10.1016/j.socec.2024.102312
#### Data: replication package of the paper

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 186 students of the University of Nottingham, recruited through ORSEE. The
## paper asks whether an emotional prime carries over into later decisions;
## after the prime every subject valued two lotteries, one risky and one
## ambiguous, in a randomised order.
df <- read_dta("Data/Masters_et_al_2025/original_dataset.dta")

## Task: the risky lottery pays GBP 12 with probability 1/2 (a disc drawn from
## a bag of 10 blue and 10 red), else nothing. Its certainty equivalent was
## elicited on a 25-row price list, the sure amount rising from GBP 3.00 to
## GBP 9.00 in 25p steps (Fig. 3). Only this task is kept; the second lottery
## has an unknown probability and measures ambiguity, not risk.
##
## risky_full holds the smallest sure amount the subject preferred to the
## lottery, and 9.25 -- a step past the last row -- codes a subject who kept
## the lottery all the way down. That reading is pinned by the data: had the
## variable held the last amount at which the lottery was still kept, it could
## never exceed the final row's 9.00, yet 9.25 occurs.
##
## This site records a CEPL as the number of rows where the lottery is kept,
## which is how many steps the switch sits above the first row.
##
## Subjects who switched more than once leave the certainty equivalent
## unidentified; Single_r flags the 167 with a single switch point, and the
## authors use exactly those in their own analysis (their `risky` variable),
## so the other 19 are dropped.
##
## genrisk is the general risk question of Dohmen et al. (2011) on the usual
## 0-10 scale, which goes into soep, on the same rows as the task.
df <- df %>%
  mutate(across(c(Single_r, Gender), ~ as.character(haven::as_factor(.)))) %>%
  filter(Single_r == "yes", !is.na(risky_full)) %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = (as.numeric(risky_full) - 3.00) / 0.25,
            gender = case_when(Gender == "female" ~ 1,
                               Gender == "male" ~ 0,
                               TRUE ~ NA_real_),
            age = as.numeric(age),
            soep = as.numeric(genrisk),
            bibkey = "Masters2025",
            paper = "Masters et al. 2025")

## University of Nottingham.
df$country = 'United Kingdom'
df$city = 'Nottingham'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Masters_et_al_2025/formatted_dataset.csv")
