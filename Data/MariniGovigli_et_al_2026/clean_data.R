#### Marini Govigli, V., Chimoita, E., Di Fiore, G., Khamassi, F., Kisakye, J.,
#### Mokhtari, N., Munubi, R. N., Ndetto, E. L., Piras, S. & Setti, M. (2026).
#### Do adverse events influence time preferences? Evidence from smallholder
#### African farmers. Journal of Agricultural Economics, 77, 130-155.
#### https://doi.org/10.1111/1477-9552.70012
#### Data: https://doi.org/10.5281/zenodo.14284426 (H2020 FoodLAND, crop and fish
#### farmers datasets, sheets "Experiments" and "Survey - Conditions")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps the 10 risk choices of every farmer in the two
## "Experiments" sheets, with sex and age joined from "Survey - Conditions" by the
## farmer id: 1987 crop farmers (Kenya, Morocco, Tunisia, Tanzania) and 406 fish
## farmers (Uganda), field experiment with tokens. Farmer, village and session
## ids are dropped; subjects are row numbers. 52 farmers have no survey record.
## Risk task: Holt-Laury list with balls, A = 100 or 80 tokens, B = 190 or 5
## tokens, the high prize with probability k/10 in row k; one row paid.
##
## Many answers do not respond to the probabilities (see also Kahsay et al. 2024,
## J. Behav. Exp. Econ. 102307, on the same data), so only the clean part is kept:
##  - Kenya and Uganda are left out as a whole: the share choosing B is flat
##    across rows (Kenya 0.43 in row 1, 0.48 in row 10; Uganda 0.32 to 0.59), so
##    even single switchers there cannot be told apart from random answers;
##  - in Morocco, Tunisia and Tanzania (B share rising from 0.05-0.15 to
##    0.80-0.91), only farmers who never go back from B to A and take B in row 10
##    (A there pays 100 for sure against B's 190, dominated) enter the
##    statistics: 1099 of 1482. The other 383 are kept for the download only,
##    with inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R).
## choice = number of B choices. female: 1 = female, 0 = male.
df <- read_csv("Data/MariniGovigli_et_al_2026/original_dataset.csv", show_col_types = FALSE)

B <- df %>% select(ra_ch1:ra_ch10) %>% mutate(across(everything(), ~ as.integer(.x == "B"))) %>% as.matrix()
consistent <- apply(B, 1, function(x) all(diff(x) >= 0)) & B[, 10] == 1

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!consistent)) %>%
  filter(country %in% c("MO", "TN", "TZ")) %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age,
            gender = female,
            country = recode(country, MO = "Morocco", TN = "Tunisia", TZ = "Tanzania"))
stopifnot(sum(df$inconsistent == 0) == 1099, sum(df$inconsistent) == 383)
## choice = number of B choices = 11 - the row where B starts
df <- df %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "MariniGovigli2026",
         paper = "Marini Govigli et al. 2026")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/MariniGovigli_et_al_2026/formatted_dataset.csv")
