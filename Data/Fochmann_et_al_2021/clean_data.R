#### Fochmann, M., Mueller, N. & Overesch, M. (2021). Less cheating? The effects
#### of prefilled forms on compliance behavior. Journal of Economic Psychology,
#### 83, 102365. https://doi.org/10.1016/j.joep.2021.102365
#### Data: Mendeley Data, https://doi.org/10.17632/7c3vtm2ty8.1
#### (Mendeley_Raw_Data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Tax compliance experiment at the computerized laboratory of the University of
## Cologne (CLER), z-Tree, August to October 2017, subjects recruited with ORSEE.
## 213 subjects, mostly undergraduates, 122 female and 91 male, earning 19.04 EUR
## on average in about 97 minutes. Subjects earned an income in a math puzzle
## task and then filed a tax return that was blank or prefilled.
##
## Before all of that the authors ran the Holt and Laury (2002) task itself, in
## euros rather than dollars, and paid out one randomly drawn row of it. The data
## file keeps the ten rows as ht_1 ... ht_10 (1 = lottery B, the risky one) and
## their sum as anzahl_lotterieb_choices, which is the risk measure the paper
## uses ("the number of high risk lottery (lottery B) choices per individual",
## mean 3.96 over all 213).
##
## Statistics: the subjects whose ten answers switch at most once, from A to
## B, with B in row 10; the 12 who switch between two and eight times (and
## anyone who switches the wrong way or keeps A in row 10, where B pays more for
## sure, counted until 29.10.2026) are kept for the download only, with
## inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R).
## choice = number of B choices = 11 - the row where B starts.
## The file also has risikograd, a 0-10 self report, but neither the paper nor
## the do-file gives its wording, so it is not mapped to the soep slot.
## gender: the authors' geschlecht ("weiblich" = 1, "maennlich" = 0).
df <- read_csv("Data/Fochmann_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 213)
ht <- df %>% select(ht_1:ht_10) %>% as.matrix()
stopifnot(all(rowSums(ht) == df$anzahl_lotterieb_choices))
switches <- rowSums(ht[, -1] != ht[, -10])

stopifnot(sum(switches <= 1) == 201)
source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(ht)), function(i) switch_points(ht[i, ])),
         inconsistent = as.numeric(!apply(ht, 1, single_switch) | ht[, 10] == 0)) %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            age = alter,
            gender = if_else(geschlecht == "weiblich", 1, 0),
            country = "Germany") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Fochmann2021",
         paper = "Fochmann et al. 2021")

## the lab is in Cologne
df$city = 'Cologne'
df$lattitude = '50.9282'
df$longitude = '6.9286'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fochmann_et_al_2021/formatted_dataset.csv")
