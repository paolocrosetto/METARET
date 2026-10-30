## Erkal, Gangadharan, and Koh (2020, JEP)
## Replication: Belief elicitation with quadratic and binarized scoring
## rules

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Erkal_2020/belief_elicitation-paper.dta")

df = df %>% 
  select(ID, starts_with('RGInputRisky'), RGSafeTotal, surveyAge,
         surveyFemale) %>% 
  rename(subject = ID,
         choice = RGSafeTotal,
         age = surveyAge,
         gender = surveyFemale)


## Inconsistent (29.10.2026): the 6 subjects who take the risky option in some
## row and the safe one in a later row (the authors' loop flagged exactly a
## risky answer followed by a safe one; the safe options come first, so the
## risky one is taken from the switching row on). Before they were dropped;
## now they are kept for the download only, with inconsistent = 1 and one row
## per switch to the risky option (Data/inconsistent_rows.R).
## choice = RGSafeTotal, the number of safe choices = the row where the risky
## option starts minus 1 (9 if never).
source("Data/inconsistent_rows.R")
R <- as.matrix(df %>% select(starts_with("RGInputRisky")))
stopifnot(ncol(R) == 9, all(rowSums(R == 0) == df$choice))
df <- df %>%
  mutate(points = lapply(seq_len(nrow(R)), function(i) switch_points(R[i, ])),
         inconsistent = as.numeric(!apply(R, 1, single_switch))) %>%
  select(subject, points, inconsistent, age, gender) %>%
  expand_switches(function(k) if_else(is.na(k), 9, k - 1))
stopifnot(n_distinct(df$subject[df$inconsistent == 1]) == 6)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Erkal2020",
         paper = "Erkal, Gangadharan, and Koh 2020")

df$country = 'Australia'
df$city = "Melbourne"
df$longitude = ''
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$task = 'CEPL'

source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Erkal_2020/formatted_dataset.csv")






