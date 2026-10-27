#### Chopra, V., Nguyen, H. M. & Vossler, C. A. (2025). Who are we up against?
#### Heterogeneous group contests with incomplete information. Journal of
#### Economic Behavior and Organization, 236, 107091.
#### https://doi.org/10.1016/j.jebo.2025.107091
#### Data: Harvard Dataverse, https://doi.org/10.7910/DVN/5O0QVJ
#### (Group_Contest.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## z-Tree laboratory experiment on inter-group Tullock contests, 21 sessions
## with 360 participants recruited at the University of Tennessee, Knoxville
## (the IRB protocol is UTK's); some sessions were run during the pandemic,
## flagged as Post. The repository file is a panel of 20 decision rounds;
## original_dataset.csv keeps one row per participant with the ten row answers
## of the risk task and the controls.
##
## Task: a ten-row lottery list run before the contest, each row $2 for sure
## against $4 with probability p and nothing otherwise, with p given in the
## data as 0.1, 0.2, ..., 1.0. risk11 ... risk110 are 1 when the safe option
## was taken, so choice = 10 minus their sum, the number of rows in which the
## lottery was taken.
##
## Dropped: the 32 subjects who went back to the safe option after once taking
## the lottery, since no single crossing means no interval; and the 4 who took
## the safe option in every row, including the last, where the lottery pays $4
## for sure against $2 for sure. 324 subjects remain.
## age: Age of the repository file ("Participant age, in years"), joined on
## SubjectID and SessionID. gender: Female is labelled "=1 if participant is
## female"; the 3 values of 2 have no label and are left missing.
##
## The figures reproduce the paper exactly on the full 360: 47.2% risk averse
## by the authors' definition (reported 47%), 43.6% female (44%), 56.4% with
## prior experiment experience (56%) and $2.51 average earnings from the risk
## task ($2.51).
df <- read_csv("Data/Chopra_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  rowwise() %>%
  mutate(rows = list(c_across(c(risk11:risk19, risk110))),
         n_safe = sum(rows),
         first_risky = if (any(rows == 0)) which(rows == 0)[1] else 11L,
         multiple_switching = any(rows[first_risky:10] == 1)) %>%
  ungroup() %>%
  filter(!multiple_switching, n_safe < 10) %>%
  transmute(subject = SubjectID,
            task = "HL",
            choice = 10L - n_safe,
            age = Age,
            gender = if_else(Female %in% c(0, 1), Female, NA_real_),
            country = "United States",
            city = "Knoxville")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chopra2025",
         paper = "Chopra et al. 2025")

df$lattitude = '35.9544'
df$longitude = '-83.9295'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chopra_et_al_2025/formatted_dataset.csv")
