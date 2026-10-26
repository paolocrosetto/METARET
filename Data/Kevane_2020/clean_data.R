#### Kevane, M. (2020). Reading fiction and economic preferences of rural youth
#### in Burkina Faso. Economic Development and Cultural Change.
#### https://doi.org/10.1086/701704
#### Data: Harvard Dataverse, doi:10.7910/DVN/JS7FNB (JTL_for_EDCC.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 557 rural youth aged 13-25 in villages of western Burkina Faso, part of a
## randomised evaluation of a young-adult fiction reading programme. Games were
## played in three sessions (May 2013, August 2013, May 2014) for real money:
## 500 CFA francs show-up fee plus 500-1,500 francs from one randomly chosen game.
## original_dataset.csv keeps the risk choice of every session, the treatment and
## library-village flags, age in 2013 and sex; the authors' respondent and group
## ids are dropped and subjects are row numbers.
## Risk task (EG): one of six 50/50 gambles, in CFA francs 1000/1000, 1300/900,
## 1600/800, 1900/600, 2200/500, 2500/100. choice = gamble 1-6. Only the first
## session (May 2013, 432 participants) is used, so that each person counts once.
## Gamble 4 has an expected value below gamble 5's for a smaller spread and is
## never the best gamble under CRRA; see generate_r.R for how it is coded.
## female: 1 = female, 0 = male.
df <- read_csv("Data/Kevane_2020/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(eg_choice_may2013)) %>%
  transmute(subject,
            task = "EG",
            choice = eg_choice_may2013,
            age = age2013,
            gender = female,
            country = "Burkina Faso")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Kevane2020",
         paper = "Kevane 2020")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kevane_2020/formatted_dataset.csv")
