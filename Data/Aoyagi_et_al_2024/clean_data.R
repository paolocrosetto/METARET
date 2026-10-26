#### Aoyagi, M., Frechette, G. R. & Yuksel, S. (2024). Beliefs in repeated games:
#### An experiment. American Economic Review, 114(12), 3944-3975.
#### https://doi.org/10.1257/aer.20220639
#### Data: openICPSR, https://doi.org/10.3886/E205541 (dat_combined.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment on finitely and indefinitely repeated prisoner's
## dilemmas with belief elicitation, run in zTree at the UCSB lab with students
## recruited through ORSEE; 32 sessions, 556 subjects (398 indefinite, 158
## finite). Earnings ran from 22.00 to 63.75 USD, 35.30 on average.
##
## At the END of every session, after the last supergame, the authors elicited
## risk preferences with "the bomb task (Crosetto and Filippin 2013)". It was
## incentivized at the same 3 cents per ECU as the rest, and the paper states
## that "maximal ECU earnings from the bomb task were 99", which pins the task
## down as the standard 100 boxes with one bomb: collecting all 100 always hits
## the bomb, so 99 is the most that can be earned.
##
## bomb_choice is the number of boxes collected, one value per subject (checked:
## it never varies within a subject and is never missing). Range 0 to 99, mean
## 43.3, with 75 subjects at exactly 50, the risk neutral point.
## original_dataset.csv is the subject level extract: session, the finite /
## indefinite treatment and this number. The repeated game itself, the beliefs
## and the strategy estimates are not used.
## Both treatments are kept: the bomb task came after all of the game play and
## was identical in each.
## The package has no gender or age, so both stay empty.
df <- read_csv("Data/Aoyagi_et_al_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 556, all(df$bomb_choice >= 0 & df$bomb_choice <= 99))

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = bomb_choice,
            gender = NA_real_,
            age = NA_real_,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Aoyagi2024",
         paper = "Aoyagi et al. 2024")

## the lab is at the University of California, Santa Barbara
df$city = 'Santa Barbara'
df$lattitude = '34.4140'
df$longitude = '-119.8489'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Aoyagi_et_al_2024/formatted_dataset.csv")
