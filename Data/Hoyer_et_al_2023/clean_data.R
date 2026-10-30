#### Hoyer, K., Zeisberger, S., Breugelmans, S. M. & Zeelenberg, M. (2023). A
#### culture of greed: Bubble formation in experimental asset markets with greedy
#### and non-greedy traders. Journal of Economic Behavior & Organization, 212,
#### 32-52. https://doi.org/10.1016/j.jebo.2023.05.005
#### Data: OSF 3ncyf (Data/qualtrics.csv); the price lists are in
#### Supplemental materials/Full questionnaire.pdf

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 195 students at Tilburg University, the Netherlands, 2019 (the first session,
## interrupted by a fire alarm, is not in the file). Before the asset markets
## they filled in a Qualtrics survey with two price lists of 11 rows, 20% paid:
##  - lottery_risk: 10 EUR or 0 EUR with equal chances (left, coded 1) against
##    0, 1, ..., 10 EUR for sure (right, coded 2). A lottery against a sure
##    amount, so CEPL; the same menu as Ifcher2024;
##  - lottery_loss: 10 EUR or -0 ... -10 EUR against 0 EUR, loss aversion, not
##    used;
##  - "How would you classify your willingness to take risks in general?", 1-5,
##    rescaled to 0-10 and kept in soep.
## The z-Tree Holt-Laury and risk modules were switched off (HLBefore, HLAfter
## and RiskAfter are 0 in every session). original_dataset.csv keeps the 11
## lottery_risk answers, the general risk question, age and sex; the
## participation number is dropped and subjects are row numbers.
## choice = the first sure amount taken (number of lotteries chosen); the
## certainty equivalent lies between choice - 1 and choice. Subjects who switch
## more than once, or take 0 EUR for sure over the lottery (dominated, one
## subject), 7 in all, are kept for the download only, with inconsistent = 1
## and one row per switch to the sure amount (Data/inconsistent_rows.R); their
## general risk answer still counts. Nobody took the lottery against a sure
## 10 EUR.
df <- read_csv("Data/Hoyer_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 195)

L <- df %>% select(lottery_risk_1:lottery_risk_11) %>% as.matrix()
single <- apply(L, 1, function(x) all(diff(x) >= 0)) & L[, 1] == 1

source("Data/inconsistent_rows.R")
S2 <- (L == 2) * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(S2)), function(i) switch_points(S2[i, ])),
         inconsistent = as.numeric(!single),
         soep_risk = (risk_pref_general - 1) / 4 * 10) %>%
  transmute(subject,
            task = "CEPL",
            points, inconsistent,
            soep = soep_risk,
            age,
            ## Male, Female, Other in the survey
            gender = case_when(gender == 2 ~ 1, gender == 1 ~ 0),
            country = "Netherlands",
            bibkey = "Hoyer2023",
            paper = "Hoyer et al. 2023") %>%
  ## choice = number of lotteries = the row where the sure amount starts - 1
  expand_switches(function(k) if_else(is.na(k), 11, k - 1))

stopifnot(sum(df$inconsistent == 0) == 188)

source("Data/generate_r.R")
cepl <- df$inconsistent == 0
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hoyer_et_al_2023/formatted_dataset.csv")
