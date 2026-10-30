## Andreas Drichoutis et Rodolfo M. Nayga
## On the stability of risk and time preferences amid the COVID-19 pandemic".

#### libraries
library(haven)
library(tidyverse)
library(broom)
library(dplyr)
library(lubridate)

df <- read_dta("Data/Drichoutis_Nayga_2022/osfstorage-archive/data.dta")

### Filter only first wave, prepare df for calculating crras
data = df %>% filter(year == '2019', wave == 3) %>%
  select(AM, nchoice, choices, Vprizeb1, time1, time2, starts_with("bis"), risk,
         riskinvestment, gender, byear) %>% rename(
           soep = risk,
           soep_financial = riskinvestment,
           soep_patience = time1,
           soep_impulsive = time2) %>% 
  mutate(age = 2019 - byear)  %>%
  drop_na() 

## the two lists: rows 31-40 the Holt-Laury list (A 2.00/1.60, B 3.85/0.10,
## probability of the high prize 0.1 ... 1), rows 41-50 the payoff-varying list
## (50/50, A 1.0-2.8 or 1.0, B 1.2-15.0 or 0.2); choices 1 = B, 0 = A,
## -1 = indifferent
data <- data %>%
  arrange(AM, nchoice) %>%
  mutate(task = if_else(nchoice <= 40, "HL", "PV"))
stopifnot(all(data$nchoice %in% 31:50), all(data$choices %in% c(-1, 0, 1)))

## Inconsistent (29.10.2026, Data/inconsistent_rows.R): a switch back from B to
## A, any indifference (-1; the authors' code meant to drop every -1, but its
## condition, "... & choices[i] == 1 & choices[i+1] == 0 | choices[i+1] == -1",
## was not limited to the same subject and list, so a -1 in the first PV row
## flagged the subject's HL list instead), or A in HL row 10, where B pays 3.85
## for sure (dominated; until now counted, choice 0). No PV row is dominated.
## Inconsistent lists are kept for the download only, one row per switch to B.
source("Data/inconsistent_rows.R")
drichoutis <- data %>%
  group_by(AM, task) %>%
  summarise(a = list(as.numeric(choices)), .groups = "drop") %>%
  mutate(B = lapply(a, function(x) as.numeric(x == 1)),
         points = lapply(B, switch_points),
         inconsistent = as.numeric(sapply(a, function(x) any(x == -1)) |
                                     !sapply(B, single_switch) |
                                     (task == "HL" & sapply(B, function(x) x[10] == 0)))) %>%
  select(AM, task, points, inconsistent) %>%
  ## choice = number of B choices = 11 - the row where B starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2022",
         paper = "Drichoutis et Nayga 2022")

source("Data/generate_r.R")
drichoutis$r <- consistent_r(drichoutis)   # r for consistent rows only (Data/inconsistent_rows.R)

drichoutis =  drichoutis %>% 
  left_join(data %>%
   group_by(AM, task) %>% 
   summarise(across(c(starts_with('soep'), age, gender), ~ mean(.x, na.rm = TRUE)), .groups = "drop"),
   by = c('task', 'AM')) %>%
  rename(subject = AM) %>% 
  # change gender for 1 - female, 0 - male
  mutate(gender = case_when(gender == 0 ~ 1,
                            gender == 1 ~ 0))

# adding paper name and bibkey to all the lines 
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2022",
         paper = "Drichoutis et Nayga 2022")
drichoutis$country = 'Greece'
# Order of variables
drichoutis <- drichoutis %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
drichoutis %>% write_csv("Data/Drichoutis_Nayga_2022/formatted_dataset.csv")

