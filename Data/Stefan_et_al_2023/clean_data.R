#### Stefan, M., Huber, J., Kirchler, M., Sutter, M. & Walzl, M. (2023).
#### Monetary and social incentives in multi-tasking: The ranking substitution
#### effect.
#### European Economic Review, 156, 104458.
#### https://doi.org/10.1016/j.euroecorev.2023.104458
#### Data: https://osf.io/ujncd

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## An online experiment with 286 finance professionals recruited from several
## EU countries through the authors' BEFORE database. The file has one row per
## subject. The tasks are a ranked effort task and an unranked prosocial one,
## neither of them a risk elicitation, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
df <- read_dta("Data/Stefan_et_al_2023/original_dataset.dta")

## q_risk ("Risk Tolerance") is released STANDARDISED, not as the raw answer.
## It takes 11 equally spaced values, step 0.45033, so the original 0 to 10
## answers come back by ranking them -- the same recovery the Bicchieri et al.
## 2022 file does. The check is exact: standardising the recovered answers
## reproduces q_risk to within 1e-5.
##
## Direction is the usual one, men averaging 6.36 against women's 5.69.
##
## gender is labelled "Female = 1", already this site's convention, and the
## 10.1% women match the 10% the paper reports. One age is 0 and is dropped to
## missing; the mean of the rest, 37.98, becomes the paper's 37.84 once that
## zero is counted in, which is how the two were reconciled.
lv <- sort(unique(round(df$q_risk, 6)))

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = match(round(q_risk, 6), lv) - 1,
            gender = as.numeric(gender),
            age = if_else(age > 0, as.numeric(age), NA_real_),
            bibkey = "Stefan2023",
            paper = "Stefan et al. 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online; the professionals came from several EU countries, so no single one
df$country = NA_character_
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Stefan_et_al_2023/formatted_dataset.csv")
