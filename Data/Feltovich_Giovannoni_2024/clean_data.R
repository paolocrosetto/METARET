#### Feltovich, N. & Giovannoni, F. (2024).
#### Campaign Messages, Polling, and Elections: Theory and Experimental Evidence.
#### American Journal of Political Science, 68(2), 408-426.
#### https://doi.org/10.1111/ajps.12722
#### Data: https://doi.org/10.7910/DVN/DAYSCX

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The experiment is a repeated election game; after the sixth supergame every
## subject did a one-shot Eckel-Grossman lottery task and a demographic
## questionnaire. original_dataset.txt is the full panel, one row per subject
## per round (9020 rows), so the risk task has to be collapsed back to one row
## per subject. Session runs 1-18 and Subject is only unique within a session,
## so the two together identify the 290 subjects -- which matches the paper's
## Table 1 (80 + 83 + 63 + 64 subjects in the MH, ML, EH and EL cells).
raw <- read_tsv("Data/Feltovich_Giovannoni_2024/original_dataset.txt",
                show_col_types = FALSE, guess_max = 9000)

## RiskChoice and Female are subject characteristics repeated down the panel;
## both are constant within (Session, Subject) and neither has a missing value,
## so taking the first row per subject loses nothing.
base <- raw %>%
  distinct(Session, Subject, .keep_all = TRUE) %>%
  arrange(Session, Subject) %>%
  mutate(subject = row_number())

## Task: one of six 50/50 gambles, 4/4, 3/6, 2/8, 1/10, 0/12 and -1/13 AUD, paid
## on top of the game earnings and a 5 AUD participation payment. The codebook
## gives RiskChoice as 1 = safest to 6 = riskiest, which is this site's EG
## convention, so the column is kept as it is. Option 6 can cost the subject a
## dollar, hence EG_loss rather than EG; generate_r.R explains how the lotteries
## were recovered and how the loss is handled.
##
## The codebook calls RiskPayoff non-negative, but 16 of the 36 subjects who
## chose option 6 were paid -1, so that line of the codebook is simply wrong --
## the loss was really applied. Final payments stayed positive anyway: total
## earnings ran from 23.05 to 112.05 AUD.
##
## Gender is coded Female = 1, already this site's convention. Age was asked in
## the questionnaire but is not in the public file.
df <- base %>%
  transmute(subject,
            task = "EG_loss",
            choice = as.numeric(RiskChoice),
            gender = as.numeric(Female),
            age = NA_real_,
            bibkey = "Feltovich2024",
            paper = "Feltovich and Giovannoni 2024")

## Sessions were run at Monash University, Clayton, in suburban Melbourne, and
## programmed in z-Tree.
df$country = 'Australia'
df$city = 'Melbourne'
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
df %>% write_csv("Data/Feltovich_Giovannoni_2024/formatted_dataset.csv")
