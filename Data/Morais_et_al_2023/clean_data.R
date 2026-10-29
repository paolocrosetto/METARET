#### Morais, M. R., Schoti, C., Resende, J. G. de L. & Tabak, B. M. (2023).
#### Limits to Myopic loss aversion and learning.
#### Economics Letters, 229, 111190.
#### https://doi.org/10.1016/j.econlet.2023.111190
#### Data: Mendeley Data, "Limits to MLA and Learning",
#### https://doi.org/10.17632/gbypg9zky3.1 (CC BY 4.0); the single file "mladata"
#### is a gzipped R data frame, kept as raw_repository/mladata.rds

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## One row per participant and period (18 periods). "We recruited 287
## undergraduate students at the Federal University of Tocantins (UFT) between
## October 2018 and March 2019 ... The final sample contained 269 participants"
## (18 dropped by the authors for very fast, mechanical bets; they are not in
## the file). Treatments: H bets every round and sees each outcome; L bets once
## for each block of three rounds, E once for each block of six.
## Each round: "an endowment of 100 currency units ... chose an X amount of this
## endowment (0 <= X <= 100) to bet in the lottery that offered a 2/3 (67%)
## chance of losing the amount bet and a 1/3 (33%) chance of winning two and a
## half times the amount". One third of the participants were paid.
## As for Gneezy1997 and Haigh2005, only treatment H in period 1 (before any
## feedback) is kept: a single Gneezy-Potters gamble. In L and E the first bet
## is placed on three or six lotteries at once, a different gamble.
## `name` restarts across sessions, so subjects are renumbered.
df <- readRDS("Data/Morais_et_al_2023/original_dataset.rds") %>%
  filter(treatment == "H", period == "1")
stopifnot(nrow(df) == 82)

df <- df %>%
  transmute(subject = row_number(),
            age = as.numeric(age),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            task = "IG",
            choice = as.numeric(bet))
stopifnot(all(df$choice >= 0 & df$choice <= 100))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Morais2023",
         paper = "Morais et al. 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "15 experimental sessions at a computer lab" at the Federal University of
## Tocantins, Palmas campus.
df$country = 'Brazil'
df$city = 'Palmas'
df$lattitude = '-10.1840'
df$longitude = '-48.3336'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Morais_et_al_2023/formatted_dataset.csv")
