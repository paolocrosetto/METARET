#### Wang, Z. (2026).
#### Coordination under Uncertainty and Noisy Communication:
#### A Generalized Email Game.
#### Working paper, Department of Economics, University of Virginia.
#### Data: sent to us directly by the author, 24 October 2026, together with
#### the instruction screen and a screenshot of the decision table.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper is a generalized e-mail game and has nothing to do with risk
## elicitation; the Holt-Laury menu was a paid side task that followed the
## main game, and the author told us he never used it in the paper. He ran
## 11 sessions at the Veconlab of the University of Virginia between June and
## September 2025 with 116 participants in all; this file carries 10 sessions
## and 106 participants, so one ten-person session is missing from the side
## task export.
##
## One row per subject. chose_risky_1 ... chose_risky_10 are the ten menu rows,
## 0 for the left (safe) lottery and 1 for the right (risky) one. The other
## columns describe the payment draw (which row was selected was not recorded)
## and are not needed here.
df <- read_csv("Data/Wang_2026/original_dataset.csv", show_col_types = FALSE)

b <- as.matrix(select(df, starts_with("choice_list.1.player.chose_risky_")))
stopifnot(ncol(b) == 10, !any(is.na(b)))

## Single crossing was not enforced in the program. Two subjects out of 106
## switch five times (the author independently reports exactly these two).
## Three subjects never switch: two take the risky lottery in every row and one
## takes the safe lottery in every row, including row 10, where 100% of $4.00
## is dominated by 100% of $7.70. The two multiple switchers (dropped before)
## and the all-safe subject (counted before) are, since 29.10.2026, kept for the
## download only, with inconsistent = 1 and one row per switch to the risky
## lottery (Data/inconsistent_rows.R).
switches <- rowSums(b[, -1] != b[, -10])

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(b)), function(i) switch_points(b[i, ])),
         inconsistent = as.numeric(!apply(b, 1, single_switch) | b[, 10] == 0)) %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Wang2026",
            paper = "Wang 2026") %>%
  ## choice = number of risky choices = 11 - the row where they start
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(n_distinct(df$subject[df$inconsistent == 1]) == 3)

## Neither gender nor age was recorded in the side-task export.

## Veconlab, University of Virginia, Charlottesville.
df$country = 'United States'
df$city = 'Charlottesville'
df$lattitude = '38.0336'
df$longitude = '-78.5080'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Wang_2026/formatted_dataset.csv")
