#### Mahmoud, O. (2022). The willingness to pay for diversification.
#### Management Science. https://doi.org/10.1287/mnsc.2021.4122
#### Data: the journal's replication package (RAW_DATA.xls, the instructions and
#### questionnaire, DATA_ANALYSIS.xls), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment in oTree, students invited "through the Behavioral
## Laboratory of the University of St. Gallen"; participant.time_started runs
## from 9 to 30 January 2018. RAW_DATA.xls has 302 rows, 241 of which answered
## the price lists; original_dataset.csv holds those 241, with each list
## answer read from player.dump_q3a.
##
## Task (Question 3 (A) of div_cost_questionnaire.docx): ten choices between a
## sure CHF 0.50, 1, ..., 5 and "If red then CHF 5, if blue then CHF 0" on a die
## with three red and three blue sides. choice = number of sure amounts below
## which the lottery was taken (0-10), so the certainty equivalent lies between
## CHF 0.5 * choice and 0.5 * (choice + 1). 233 subjects switched once; the other
## 8, and the 2 who took the lottery even against a sure CHF 5 (weakly
## dominated), are out of the statistics and kept for the download only, with
## inconsistent = 1 and one row per switch to the sure amount
## (Data/inconsistent_rows.R); choice = that row - 1. Question 2 (a Gneezy-Potters game where the expected payoff does not
## depend on the amount played) is not used: it separates only risk lovers from
## everyone else.
##
## player.gender is "Female" or "Male"; age was not asked.
df <- read_csv("Data/Mahmoud_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 241, sum(df$single_switch) == 233)

source("Data/inconsistent_rows.R")
sure <- (as.matrix(select(df, starts_with("q3a_"))) == "sure") * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(sure)), function(i) switch_points(sure[i, ])),
         inconsistent = as.numeric(!(single_switch & lottery_choices <= 9))) %>%
  transmute(subject = row_number(),
            task = "CEPL",
            points, inconsistent,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            age = NA_real_,
            country = "Switzerland",
            city = "St. Gallen") %>%
  expand_switches(function(k) if_else(is.na(k), 10, k - 1))
stopifnot(sum(df$inconsistent == 0) == 231)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Mahmoud2022",
         paper = "Mahmoud 2022")

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
df %>% write_csv("Data/Mahmoud_2022/formatted_dataset.csv")
