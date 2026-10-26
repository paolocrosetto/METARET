#### Jagau, S. (2024). To catch a stag: Identifying payoff- and risk-dominance
#### effects in coordination games.
#### Games and Economic Behavior, 147, 429-448.
#### https://doi.org/10.1016/j.geb.2024.08.011
#### Data: Harvard Dataverse, https://doi.org/10.7910/DVN/MPR2R5 (CC0)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Coordination games in a choice-list format, run in 2022 at the Experimental
## Social Science Laboratory of the University of California, Irvine: 17
## sessions, 254 students, 8 in person (116 subjects) and 9 online (138). The
## games themselves are about payoff and risk dominance in stag hunts, not a
## risk elicitation, so the rows are 'quest_only' and generate_data_for_app.R
## moves `choice` into `soep`.
##
## The closing survey carried the general risk question. The variable label in
## the Dataverse file is exactly "11-pt. Likert: In general, how willing are
## you to take risks?", which is the SOEP item.
##
## The answers run 1 to 10 and never 0, which on its own would leave the scale
## open: 0 to 10 with nobody at the bottom, or 1 to 11 with nobody at the top.
## The three other 11-point items in the same survey settle it -- svo1, svo2
## and svo3 all run 0 to 10 in the data, so the software recorded these scales
## from zero and the risk answers need no shifting.
##
## The item was NOT incentivized ("an unincentivized risk attitude- and social
## value orientation-assessments"), which is the usual case for a survey item.
##
## original_dataset.csv is the panel collapsed to one row per subject: the file
## holds 8,379 game rows, about 33 per person.
df <- read_csv("Data/Jagau_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 254, all(df$risk >= 0 & df$risk <= 10, na.rm = TRUE))

## gender: the file's label is "0 if male, 1 if female, 2 if other", so 0 and 1
## already match the site and the 8 answers of 2 go to missing.
df <- df %>%
  transmute(subject = row,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(risk),
            gender = case_when(gender == 1 ~ 1, gender == 0 ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Jagau2024",
            paper = "Jagau 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## all subjects came from the ESSL pool at the University of California, Irvine,
## the online sessions included; the file's own country field is the subject's
## nationality, which is not where they took part
df$country = 'United States'
df$city = 'Irvine'
df$lattitude = '33.6405'
df$longitude = '-117.8443'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Jagau_2024/formatted_dataset.csv")
