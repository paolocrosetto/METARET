#### Dalton, P. S., Nhung, N. & Ruschenpohler, J. (2020). Worries of the poor:
#### The impact of financial burden on the risk attitudes of micro-entrepreneurs.
#### Journal of Economic Psychology, 79, 102198.
#### https://doi.org/10.1016/j.joep.2019.102198
#### Data: replication file "Worries of the Poor - Data and Replication file"

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment with shop owners at Tam Bac Market, Hai Phong,
## Vietnam, May 2015. Owners were primed with hypothetical scenarios of
## financial burden ("hard", the treatment) or small expenses ("easy",
## placebo); then risk was measured "through the incentive-compatible
## elicitation method introduced by Gneezy and Potters (1997) ... endowed with
## an amount X (VND 30,000 or US$2.75) ... a risky bet which is known to triple
## the amount invested with probability p = 1/2" -- parameters in the
## Dalton2020 block of generate_r.R. Both arms are kept, as for other primed
## samples on the site (Masters2025); the treatment flag stays in
## original_dataset.csv.
##
## 132 shops took part; the three rows without an answer to the investment are
## dropped, leaving 130. The authors' main analysis further excludes eleven
## outliers in shop size and income volatility, which are business
## characteristics, not risk answers, so they are kept here.
## gender: sesgender is 1 female, 2 male (clean_DATA_raw.do), 93% women.
## age = 2015 minus the year of birth.
df <- read_csv("Data/Dalton_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 130, all(df$riskinvest >= 0 & df$riskinvest <= 30000))

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = riskinvest,
            gender = case_when(gender_raw == 1 ~ 1, gender_raw == 2 ~ 0, TRUE ~ NA_real_),
            age = 2015 - birthyear,
            bibkey = "Dalton2020",
            paper = "Dalton et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Tam Bac Market, Hai Phong
df$country = 'Vietnam'
df$city = 'Hai Phong'
df$lattitude = '20.8561'
df$longitude = '106.6822'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Dalton_et_al_2020/formatted_dataset.csv")
