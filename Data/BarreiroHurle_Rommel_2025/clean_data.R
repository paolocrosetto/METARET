#### Barreiro-Hurle, J. & Rommel, J. (2025).
#### Behaviourally informed interventions to maximize environmental delivery under
#### the new CAP green architecture.
#### European Review of Agricultural Economics, 53(1), 374-414.
#### https://doi.org/10.1093/erae/jbaf029
#### Data: OSF qu8wc, "Farmer experiment - ECS & AECM" ("All material, data and
#### code are publicly and permanently available"; no licence set on OSF).
#### Data, do-file, questionnaires and supplementary material in raw_repository/
#### (the pitch slides are not copied).

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## SM 5. EARESI_DATA.dta: one row per farmer, 1,745 farmers in Germany, Romania,
## Spain and Sweden ("A pre-registered online experiment with 1,745 European
## farmers in four countries"; some interviews by telephone, ONLINE = 0).
df <- read_dta("Data/BarreiroHurle_Rommel_2025/original_dataset.dta") %>%
  zap_labels()
stopifnot(nrow(df) == 1745, all(df$DE + df$RO + df$ES + df$SE == 1))

## Risk task, question C.22 (SM 1): the static BRET with 100 boxes, "choose a
## number between 1 and 100 that will correspond to the number of boxes you
## wish to collect"; one in ten winners is paid "the number answered divided by
## ten" euros. risk_bomb = boxes collected. Collecting 100 loses for sure.
## Question C.23: "In a scale from 1 to 10, where 1 means 'I do not take risks
## at all' and 10, means 'I take all risks', are you generally a person who is
## fully prepared to take risks or do you try to avoid taking risks?" - the
## SOEP item on a 1-10 scale, rescaled linearly onto 0-10 as for Cox2026.
## FEMALE: 1 woman. AGE only holds the midpoints of ten-year bands (25, 35,
## ..., 75), so age is left missing.
df <- df %>%
  transmute(subject = row_number(),
            age = NA_real_,
            gender = FEMALE,
            task = "BRET",
            choice = risk_bomb,
            soep = (risk_stated - 1) * 10 / 9,
            treatment = if_else(ONLINE == 1, "online", "telephone"),
            country = case_when(DE == 1 ~ "Germany", RO == 1 ~ "Romania",
                                ES == 1 ~ "Spain", SE == 1 ~ "Sweden"))
stopifnot(all(df$choice %in% 1:100))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "BarreiroHurle2025",
         paper = "Barreiro-Hurle and Rommel 2025")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## National farmer samples (quotas by region and farm size), so no city and no
## coordinates.
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, soep, everything())

# Writing to file
df %>% write_csv("Data/BarreiroHurle_Rommel_2025/formatted_dataset.csv")
