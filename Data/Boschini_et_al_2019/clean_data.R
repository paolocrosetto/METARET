#### Boschini, A., Dreber, A., von Essen, E., Muren, A. & Ranehill, E. (2019).
#### Gender, risk preferences and willingness to compete in a random sample of the
#### Swedish population. Journal of Behavioral and Experimental Economics, 83,
#### 101467. https://doi.org/10.1016/j.socec.2019.101467
#### Data: SND snd1021-1, version 3 (snd1021-1_v3.zip: 1021-1-V3sv.sav, the
#### telephone interviews)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## A random sample of the Swedish population aged 18-73 drawn by Statistics
## Sweden, interviewed by telephone by a polling company "in September through
## November 2011", with real payments (SEK 100 fee plus earnings). 1,003
## interviews (1021-1-V3sv.sav); the postal survey (1021-2) holds the other roles
## of the social games and no risk task.
##
## Task: "a multiple price list where participants make seven choices between a
## risky option and a safe option. The risky option was the same across the
## different decisions, giving SEK 200 or 0 with equal probability, while the safe
## option varied from SEK 40 to SEK 160 in increments of 20 SEK" (q6_40kr ...
## q6_160kr; "att singla slant" = the coin flip). choice = number of rows with
## the lottery. 851 subjects took the lottery for the lowest safe amounts and the
## safe amount from some row on; the other 152 switched more than once and are
## dropped.
##
## kon: Kvinna = woman. bg_alder is the year of birth (0 = missing); age = 2011 -
## year. The interviews were nationwide, so no city or coordinates.
df <- read_csv("Data/Boschini_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 1003)

lot <- df %>% select(ends_with("_lottery")) %>% as.matrix()
k <- rowSums(lot)
single <- sapply(seq_len(nrow(lot)), function(i)
  identical(unname(lot[i, ]), as.numeric(c(rep(1, k[i]), rep(0, 7 - k[i])))))
stopifnot(sum(single) == 851)

df <- df %>%
  mutate(k = k, single = single) %>%
  filter(single) %>%
  transmute(subject = id,
            task = "CEPL",
            choice = k,
            age = if_else(birth_year > 1900, 2011 - birth_year, NA_real_),
            gender = case_when(kon == "Kvinna" ~ 1, kon == "Man" ~ 0),
            country = "Sweden",
            city = "",
            bibkey = "Boschini2019",
            paper = "Boschini et al. 2019")

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Boschini_et_al_2019/formatted_dataset.csv")
