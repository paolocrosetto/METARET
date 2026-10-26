#### Ellis, A. & Freeman, D. J. (2024).
#### Revealing Choice Bracketing.
#### American Economic Review, 114(9), 2668-2700.
#### https://doi.org/10.1257/aer.20210877
#### Data: openICPSR 10.3886/E202681V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The replication package holds three experiments; this is the online risk
## experiment, 200 Prolific workers resident in the United States, all with
## status APPROVED. The other two (a 99-subject laboratory version at the
## Toronto Experimental Economics Lab and Simon Fraser, and a shopping
## experiment) carry no risk-attitude survey item, so only this file is used.
df <- read_csv("Data/Ellis_Freeman_2024/original_dataset.csv",
               show_col_types = FALSE)

## WHY quest_only, even though the paper is an incentivised risk experiment:
## the task is a two-state portfolio allocation. In each of five rounds the
## subject splits a budget between two Arrow securities, one paying in dice
## rolls 1-3 and the other in 4-6 (risk.csv in the oTree app gives the five
## rounds). Three of those rounds are symmetric -- both securities pay the same
## amount, so every risk-averse subject splits the budget evenly and the round
## identifies nothing beyond consistency -- and the remaining variation is the
## paper's own treatment, whether the two accounts are bracketed together or
## apart. That is not one of this site's elicitation formats, so the task is
## left out and only the survey item is kept.
##
## The survey item is the general risk question in its usual wording, taken
## from Final_Survey.html: "In general, how willing or unwilling are you to
## take risks? Please use a scale from 0 to 10, where 0 means you are
## 'completely unwilling to take risks', and 10 means you are 'completely
## willing to take risks'." All eleven points are used, with no missing
## answers.
##
## Sex.x is the experiment's own question; opt1 is men and opt2 women, which
## the Prolific record confirms (85 of the 89 opt1 are Male there and 106 of
## the 110 opt2 are Female). One subject chose the third option and is left
## missing. The direction is the usual one: men average 5.51 against women's
## 4.56.
##
## Two age sources disagree by a year: YearBorn is self-reported during the
## experiment and complete, while `age` is Prolific's own record, taken at
## export, and blank for the five whose data had expired. Adding the two gives
## 2021 for 108 subjects and 2022 for 77, so no single session year fits
## YearBorn; Prolific's own figure is used instead and those five stay missing.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(SOEPrisk),
            gender = case_when(Sex.x == "opt2" ~ 1,
                               Sex.x == "opt1" ~ 0,
                               TRUE ~ NA_real_),
            age = suppressWarnings(as.numeric(age)),
            bibkey = "Ellis2024",
            paper = "Ellis and Freeman 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Online on Prolific; every subject reports the United States as country of
## residence, and no city is recorded.
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Ellis_Freeman_2024/formatted_dataset.csv")
