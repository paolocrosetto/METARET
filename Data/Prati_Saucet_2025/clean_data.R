#### Prati, A. & Saucet, C. (2025).
#### Is motivated memory (just) a matter of mood?
#### Experimental Economics.
#### https://doi.org/10.1017/eec.2025.10028
#### Data: https://osf.io/ur726

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The laboratory arm, run in z-Tree at GATE-Lab in Lyon over five waves
## between April 2019 and October 2022. Session 1 of the package (P1.dta) has
## 344 subjects; the columns copied here are the session id and date, the
## investment, its realised payoff, gender and year of birth.
##
## The paper reports 337 recruited and analyses 294 of them, because 43 never
## returned for session 2. The investment task sits in session 1, so the
## second session is irrelevant to it and all 344 rows are kept.
df <- read_csv("Data/Prati_Saucet_2025/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 344)

## THE TASK is a Gneezy-Potters investment, part 5 of session 1: 200 cents,
## invest anything from 0 to 200, the investment wins with probability 1/3.
## Why its parameters differ from this site's other Gneezy-Potters entries,
## and why the expected value of investing is negative here, is set out in the
## Prati2025 block of generate_r.R.
##
## The upshot for reading the numbers: in a losing gamble no amount of
## investment can reveal risk aversion, so the 57 subjects who invested
## nothing land on the censored lower corner at -1 and the 287 who invested
## something all come out above 1. The median of those 287 is 1.23 and the
## quartiles 1.16 and 1.47.
##
## The authors never use the task as a risk measure -- in session 2 they only
## ask whether subjects remember having done it -- which is presumably why the
## sign of its expected value went unremarked.
##
## demo_gender is 1 for men, per the package codebook, so the site's gender is
## its complement: 163 women against 181 men.
##
## Age is the session year minus the year of birth. The date column carries
## the session stamp as yymmdd_hhmm, which gives the year directly, and the
## waves ran in 2019 and 2022.
df <- df %>%
  mutate(year = 2000 + as.numeric(str_sub(date, 1, 2))) %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = as.numeric(invest),
            gender = 1 - as.numeric(demo_gender),
            age = year - as.numeric(demo_dateofbirth),
            bibkey = "Prati2025",
            paper = "Prati and Saucet 2025")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## GATE-Lab, Lyon.
df$country = 'France'
df$city = 'Lyon'
df$lattitude = '45.7640'
df$longitude = '4.8357'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Prati_Saucet_2025/formatted_dataset.csv")
