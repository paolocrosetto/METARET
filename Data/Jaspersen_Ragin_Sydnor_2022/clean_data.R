#### Jaspersen, J. G., Ragin, M. A. & Sydnor, J. R. (2022). Predicting insurance
#### demand from risk attitudes. Journal of Risk and Insurance, 89(1), 63-96.
#### https://doi.org/10.1111/jori.12342
#### Data: GitHub PredictingInsDemand (data/MainAll_wide.dta); the lists are in
#### Table A.1 of the online appendix

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 1,730 subjects in March 2018: 1,352 on Amazon mTurk and 378 in person at the
## University of Wisconsin-Madison. The same experiment is analysed in
## Jaspersen, Ragin & Sydnor (2020, JRU), so it enters METARET once, here.
## Six 16-row tables, one row paid. Four of them are Tanaka-style choices
## between two lotteries (GD1, GD2, LD1, LD2) and LA varies probabilities of a
## mixed gamble; these are not used. The certainty-preference table CP is a
## sure 2.00 USD against a lottery paying x with probability 0.2 and 1.00 USD
## otherwise, x = 2.50, 4.50, 4.75, 5, 5.5, 6, 6.5, 7, 8, 9, 10, 12, 15, 20, 30,
## 60, i.e. a sure amount against a lottery: CEPL. choice = ce_nsafe, the number
## of rows in which the sure 2.00 was taken (the switch row was chosen once, so
## choices are monotone by design).
## As in the authors' code, subjects who made a stochastically dominated choice
## in any table have no preference measure. Their CP answer itself is a single
## switch with no dominated row, but the dominated choice elsewhere in the same
## session makes it unreliable, so (29.10.2026) they keep their CP row with
## inconsistent = 1, for the download only (Data/inconsistent_rows.R); the
## general risk question (GRQ, Dohmen et al. 2011, 0-10), which everyone
## answered, is in soep for everyone and still counts for them.
## Country: the lab sample is the United States; mTurk subjects are given their
## self-reported country, and the 56 whose report does not match their IP
## address (badcountry) are dropped. original_dataset.csv keeps the sample, the
## CP count, the FOSD flag, GRQ, female, age and the self-reported country.
df <- read_csv("Data/Jaspersen_Ragin_Sydnor_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 1730)

df <- df %>%
  filter(badcountry == 0) %>%
  mutate(cepl = violate_fosd == 0,
         country = case_when(mturk == 0 ~ "United States",
                             country_self == "United States of America" ~ "United States",
                             TRUE ~ country_self)) %>%
  transmute(subject,
            task = "CEPL",
            choice = cp_nsafe,
            inconsistent = as.numeric(!cepl),
            soep = grq,
            age,
            gender = female,
            country,
            city = if_else(mturk == 0, "Madison", NA_character_),
            lattitude = if_else(mturk == 0, "43.0731", ""),
            longitude = if_else(mturk == 0, "-89.4012", ""),
            bibkey = "Jaspersen2022",
            paper = "Jaspersen et al. 2022")

stopifnot(nrow(df) == 1674, sum(df$inconsistent == 0) == 1246)

source("Data/generate_r.R")
cepl <- df$inconsistent == 0
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Jaspersen_Ragin_Sydnor_2022/formatted_dataset.csv")
