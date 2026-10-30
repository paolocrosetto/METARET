## Andreas Drichoutis et Rodolfo M. Nayga 2013
## Eliciting risk and time preferences under induced mood states

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Drichoutis_Nayga_2013/DN_JSE_2013.dta")

## DelayedP == 0 keeps the risk choices (the other rows are the time preference
## task). Each subject has 27 risk rows (nchoice 1 ... 27), three Holt-Laury
## tables in random order (paper, section 2.4): "Table 2 (the 1x table), a table
## where payoffs were scaled up by 10 (the 10x table) and a table similar to
## Table 2 but without the last three rows (the 1x-framed table)". In the file:
## nchoice 1-10 the 1x table (A 2.00 / 1.60, B 3.85 / 0.10, P(high) 0.1 ... 1),
## 11-20 the 10x table, 21-27 the 1x-framed table (P(high) 0.1 ... 0.7), the
## same layout for all 86 subjects (the order shown on screen was randomised).
## Only the 1x table is used, the canonical HL list; the site holds one
## coefficient per subject per task.
## Corrected 30.10.2026: the old script told the tables apart by the B prize, so
## it summed the B choices of the 1x and the 1x-framed tables into one "HL"
## choice (17 rows, then dropped choice > 10) and scored the 10x table as a
## payoff-varying "PV" task. choices: 1 = right lottery (B), 0 = left (A).
data = df %>% filter(DelayedP == 0, nchoice <= 10) %>% arrange(Subject, nchoice)
stopifnot(n_distinct(data$Subject) == 86, all(count(data, Subject)$n == 10),
          all(round(data$Vprizeb1, 2) == 3.85), all(round(data$RowProbA * 10) == data$nchoice))

## Inconsistent: more than one switch, or A in row 10 where B pays 3.85 for
## sure. None in the file (all 86 switch once and take B in row 10); the code
## keeps them for the download only, as elsewhere (Data/inconsistent_rows.R).
## choice = number of B choices (= 11 - the row where B starts).
source("Data/inconsistent_rows.R")
drichoutis = data %>%
  group_by(Subject) %>%
  summarise(points = list(switch_points(choices)),
            inconsistent = as.numeric(!single_switch(choices) | last(choices) == 0),
            age = first(age), gender = first(gender), .groups = "drop") %>%
  mutate(task = "HL") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(sum(drichoutis$inconsistent) == 0)

# adding paper name and bibkey
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2013",
         paper = "Drichoutis et Nayga 2013")

source("Data/generate_r.R")
drichoutis$r <- consistent_r(drichoutis)   # r for consistent rows only

drichoutis = drichoutis %>%
  rename(subject = Subject) %>%
  # change gender for 1 - female, 0 - male
  mutate(gender = case_when(gender == 0 ~ 1,
                            gender == 1 ~ 0))

# Order of variables
drichoutis <- drichoutis %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, inconsistent, switch_no)
drichoutis$country = 'Greece'
# Writing to file
drichoutis %>% write_csv("Data/Drichoutis_Nayga_2013/formatted_dataset.csv")
