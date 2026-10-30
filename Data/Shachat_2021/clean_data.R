## Daniel Friedman, Sameh Habib, Duncan James, and Brett Williams
## Varieties of Risk Preference Elicitation 
## 2022 

library(tidyverse)
library(broom)
library(lubridate)

## task 6 for gains  and task 10 for losses
## Task 6 (experimental_instructions.pdf): nine rows, a 50-50 lottery of 9 or 3
## RMB against 3.00, 3.75, ..., 9.00 RMB for sure. risk_gain is "row in which
## subject switches from lottery to sure amount ... 10 indicates no switch.
## Missing values indicate subjects who switch more than once"
## (wuhan_risk_data_var_names.txt).
## Inconsistent (29.10.2026): the 29 multiple switchers (risk_gain missing),
## dropped until then, and the dominated corners -- risk_gain 1, 3 RMB for sure
## taken over a lottery paying at least 3, and 10, the lottery kept against 9
## for sure -- counted until then. They are kept for the download only, with
## inconsistent = 1, one row each (choice empty for the multiple switchers, the
## file keeps no row-by-row answers). drop_na() also dropped 7 subjects with
## gender missing; they are now kept.
df <- read_csv("Data/Shachat_2021/wuhan_risk_data.csv")
df = df %>% select(-risk_loss) %>%
  mutate(inconsistent = as.numeric(is.na(risk_gain) | risk_gain %in% c(1, 10)),
         switch_no = if_else(inconsistent == 1, 1, NA_real_)) %>% 
# 1 - females 
  mutate(gender = case_when(gender == 1~0,
                            gender == 0~1)) %>% 
  rename(choice = risk_gain,
         subject = id)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Shachat2021",
         paper = "Shachat 2021")

df$country = 'China'
df$city = 'Wuhan'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

df$task = 'CEPL'
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)
stopifnot(nrow(df) == 602, sum(df$inconsistent) == 29 + 16 + 8)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Shachat_2021/formatted_dataset.csv")
