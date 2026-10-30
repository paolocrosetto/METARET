#### Fornwagner, H., Pompeo, M. & Serdarevic, N. (2023). Choosing competition on
#### behalf of someone else. Management Science.
#### https://doi.org/10.1287/mnsc.2022.4413
#### Data: the journal's replication package (AllTreatments_rawdata(_clean).dta,
#### the authors' do-files, instructions, LIONESS code), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment, "March 2020, Nottingham, United Kingdom" (readme), recruited
## with ORSEE and run in LIONESS: 688 subjects (agents, principals and
## decision makers alike), one row each.
##
## Task: Holt and Laury (2002) in stage 4, the same for every role. From the
## instructions: "Option A has a 1 in 10 chance of paying GBP 2.20 and a 9 in 10
## chance of paying GBP 1.75. Option B has a 1 in 10 chance of paying GBP 4.20 and
## a 9 in 10 chance of paying GBP 0.10", the chance of the high payoff rising by
## 1 in 10 per row. HLk is filled (with k) when B was taken in row k. choice = number
## of B choices, as for the other HL papers. 590 subjects switched once; the 98
## who switched more than once and the 16 who never took B (not even in row 10,
## where B pays GBP 4.20 for sure) are kept for the download only, with
## inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R).
##
## Questionnaire: "On a scale from 0 (completely unwilling to take risks) to 10
## (very willing to take risks), in general, how willing are you to take risks?"
## risk stores the 11 answers as 1-11, so 0-10 = risk - 1. It goes into soep,
## and it still counts for the inconsistent subjects.
##
## female: 1 = woman; age in years.
df <- read_csv("Data/Fornwagner_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 688, all(df$risk %in% 1:11))

hl <- df %>% select(num_range("HL", 1:10, suffix = "_B")) %>% as.matrix()
n_b <- rowSums(hl)
single <- sapply(seq_len(nrow(hl)), function(i)
  identical(unname(hl[i, ]), c(rep(0, 10 - n_b[i]), rep(1, n_b[i]))))
has_task <- single & n_b >= 1
stopifnot(sum(single) == 590, sum(has_task) == 574)

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(subject = row_number(),
         task = "HL",
         points = lapply(seq_len(nrow(hl)), function(i) switch_points(hl[i, ])),
         inconsistent = as.numeric(!has_task),
         soep = risk - 1) %>%
  transmute(subject, task, points, inconsistent, soep,
            gender = female,
            age,
            country = "United Kingdom",
            city = "Nottingham") %>%
  ## choice = number of B choices = 11 - the row where B starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Fornwagner2023",
         paper = "Fornwagner et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## (the questionnaire-only rows have no task, so no r)
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fornwagner_et_al_2023/formatted_dataset.csv")
