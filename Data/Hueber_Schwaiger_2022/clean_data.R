#### Hueber, L. & Schwaiger, R. (2022).
#### Debiasing through experience sampling: The case of myopic loss aversion.
#### Journal of Economic Behavior and Organization, 198, 87-138. https://doi.org/10.1016/j.jebo.2022.03.026

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Experimental_Data.dta from the replication package, one row per participant
## and round (894 students of the University of Innsbruck, online, oTree, 2020).
## Participant codes, device/browser information and comments were removed
## before copying the file here.
## Stage 2 is the Gneezy-Potters task: 200 tokens per round for nine rounds, bet
## x tokens; with 1/3 win 2.5 times the bet, with 2/3 lose it.
##  - treatment: 0 = baseline (Minesweeper filler), 1 = debiasing training
##  - subtreatment: 0 = h (decide and feedback every round), 1 = l (one decision
##    for three rounds)
## Only the decision that is a single Gneezy-Potters gamble without any
## intervention is kept: baseline, sub-treatment h, round 1 (before feedback).
## gender: 1 = female (59% in the paper), 2 = male. One age of 100 -> NA.
df <- read_dta("Data/Hueber_Schwaiger_2022/original_dataset.dta")

df <- df %>% 
  filter(round == 1, treatment == 0, subtreatment == 0) %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = as.numeric(amount_invested),
            ## SOEP items were asked on 0-10 (paper, fn. 7) but stored as 1-11
            soep = as.numeric(risk_general) - 1,
            soep_financial = as.numeric(risk_finance) - 1,
            age = if_else(as.numeric(age) > 90, NA_real_, as.numeric(age)),
            gender = case_when(gender == 1 ~ 1, gender == 2 ~ 0, TRUE ~ NA_real_),
            country = "Austria",
            city = "Innsbruck")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Hueber2022",
         paper = "Hueber and Schwaiger 2022")

## online experiment, so no lab coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hueber_Schwaiger_2022/formatted_dataset.csv")
