#### Georgalos, K., Paya, I. & Peel, D. (2023). Higher order risk attitudes:
#### new model insights and heterogeneity of preferences.
#### Experimental Economics, 26, 145-192.
#### https://doi.org/10.1007/s10683-022-09784-5
#### Data: https://osf.io/xz9s6 (Analysis/data_exp.csv, Analysis/tasks_exp.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "A total of 49 participants were recruited from the Lancaster Experimental
## Economics Lab (LExEL) subject pool", custom Python interface, 29 binary
## choices between two lotteries, one paid for real (show-up fee 5 GBP, average
## earnings 19.40 GBP). Most tasks measure prudence and temperance and are not
## used. Tasks 5 to 9 (tasks_exp.csv, type RA) form a Holt-Laury list: option B
## pays 10 or 8, option A pays 19 or 1, and the chance of the high prize runs
## 10%, 30%, 50%, 70%, 90% -- the standard list (2.00/1.60 vs 3.85/0.10) scaled
## by about five, keeping every other row. Tasks 1 to 4 (a sure amount against
## a symmetric 50/50 spread around it) cannot rank risk-averse subjects and are
## not used.
##
## data_exp.csv: one row per subject, V1 ... V29, 1 = lottery A (the risky one
## in tasks 5-9). choice = number of risky choices in V5 ... V9. Kept: the 41
## subjects who move at most once, from the safe to the risky option, as the
## probability of the high prize rises; the 8 others are dropped, as for the
## multiple switchers of other HL papers. Bounds in the Georgalos2023 block of
## generate_r.R.
##
## No demographics in the package; Lancaster University, United Kingdom. The
## paper does not say when the sessions were run.
df <- read_csv("Data/Georgalos_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 49)

hl <- as.matrix(df[, paste0("V", 5:9)])
single <- apply(hl, 1, function(x) all(diff(x) >= 0))

df <- df %>%
  mutate(n_risky = rowSums(hl), single = single) %>%
  filter(single)

stopifnot(nrow(df) == 41)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = n_risky,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Georgalos2023",
            paper = "Georgalos et al. 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Lancaster Experimental Economics Lab; the map shows only the country
df$country = 'United Kingdom'
df$city = 'Lancaster'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Georgalos_et_al_2023/formatted_dataset.csv")
