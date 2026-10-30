#### Kovenock, D., Song, J. & Trevisan, F. (2026). Caps on bids in all-pay
#### contests with identity-dependent externalities. Games and Economic
#### Behavior, 158, 691-716. https://doi.org/10.1016/j.geb.2026.05.003
#### Data: OSF, https://osf.io/sg9cd (Data/data_IDE Tullock.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## oTree experiment at the Economic Science Institute of Chapman University,
## 12 sessions, 144 undergraduates in three between-subject bid-cap treatments
## (48 each), mean age 20.0. The main part is a 60-period three-player Tullock
## contest with identity-dependent externalities; the risk task comes after it.
## original_dataset.csv collapses the 8,640 round rows of the repository file
## to one row per participant, keeping the session, the treatment, the authors'
## riskaversion, the raw row-by-row answers, gender and age.
##
## Task: ten rows, each a sure 1.50 against a lottery paying 3.00 with
## probability p and 0.10 otherwise, p rising 0.1, ..., 1.0 down the list.
## Neither the paper nor the online appendix prints the menu; it is recovered
## from the realised part 2 payoffs, which are 1.50 for every subject who
## refused, 3.00 for every one who played and won and 0.10 for every one who
## played and lost. raw_responses stores the ten answers in row order, true for
## taking the lottery, and the authors' riskaversion equals the number of false
## answers for all 144 subjects. choice = number of rows the lottery was taken.
##
## A CRRA interval needs a single crossing, so the 36 subjects who went back to
## the sure amount after once taking the lottery are out of the statistics. Of
## the remaining 108, the 6 who refused every row also refused the last one,
## where the lottery pays 3.00 for sure against 1.50 for sure, which is
## dominated; they are out too and 102 subjects remain. The 42 are kept for the
## download only, with inconsistent = 1 and one row per switch to the lottery
## (Data/inconsistent_rows.R).
##
## gender is the questionnaire answer: 1 for the 92 who answered Female, 0 for
## the 48 who answered Male, missing for the 4 who answered Other (the authors'
## own Female dummy puts those four with the men).
df <- read_csv("Data/Kovenock_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## the ten answers sit in the stored string in row order
rows_of <- function(s) str_extract_all(s, "true|false")[[1]] == "true"
source("Data/inconsistent_rows.R")

df <- df %>%
  rowwise() %>%
  mutate(v = list(rows_of(raw_responses)),
         first_yes = if (any(v)) which(v)[1] else 11L,
         multiple_switching = any(!v[first_yes:10]),
         points = list(switch_points(as.numeric(v)))) %>%
  ungroup() %>%
  mutate(inconsistent = as.numeric(multiple_switching | riskaversion == 10))
stopifnot(sum(df$inconsistent == 0) == 102, sum(df$inconsistent) == 42)
df <- df %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            age,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            country = "United States",
            city = "Orange") %>%
  ## choice = rows with the lottery = 11 - the row where it starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Kovenock2026",
         paper = "Kovenock et al. 2026")

df$lattitude = '33.7936'
df$longitude = '-117.8534'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kovenock_et_al_2026/formatted_dataset.csv")
