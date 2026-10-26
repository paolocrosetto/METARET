#### von Bieberstein, F., Feess, E. & Packham, N. (2026). Multi-step delegation
#### and the frequency of immoral decisions: Theory and experiment.
#### European Economic Review.
#### https://doi.org/10.1016/j.euroecorev.2025.105161
#### Data: supplementary files of the article (EEREV-D-24-01222R1)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment on Amazon MTurk, June to August 2022, with 7,074
## participants. The experiment is about delegating a lie down a chain of
## decision makers, which is not a risk elicitation, so the rows are
## 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
##
## The closing survey carried the general risk item, quoted from the paper:
## "We measured the willingness to take risks by the question 'Are you
## generally a person who is willing to take risks, or do you try to avoid
## taking risks?' on a scale from 0 (lowest willingness to take risks) to 10
## (Dohmen et al., 2011)." The variable runs over all eleven values, so no
## rescaling is needed.
##
## 5,294 of the 7,074 answered it; the rest broke off, 1,446 of them flagged as
## comprehension-quiz dropouts.
##
## Country: the paper required "subjects ... to reside in the USA", so unlike
## the Prolific studies here this one does have a country.
df <- read_csv("Data/VonBieberstein_et_al_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 7074)

df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(risk),
            gender = as.numeric(female),
            age = as.numeric(age),
            bibkey = "VonBieberstein2026",
            paper = "von Bieberstein et al. 2026")

stopifnot(nrow(df) == 5294, all(df$choice >= 0 & df$choice <= 10))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## MTurk workers resident in the United States, nationwide, so no city
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/VonBieberstein_et_al_2026/formatted_dataset.csv")
