#### Lambrecht, M., Proto, E., Rustichini, A. & Sofianos, A. (2024).
#### Intelligence Disclosure and Cooperation in Repeated Interactions.
#### American Economic Journal: Microeconomics, 16(3), 199-231.
#### https://doi.org/10.1257/mic.20220245
#### Data: openICPSR 10.3886/E183801V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## disclosure.dta is the long panel of the repeated games, 39,560 rows; the
## survey and lottery answers repeat for every round, so one row per subject
## was copied here. That gives 430, the number the paper states: "A total of
## 430 subjects participated in the experimental sessions."
df <- read_csv("Data/Lambrecht_et_al_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 430)

## THE TASK, which the paper introduces plainly: "For risk attitude
## elicitation, subjects complete an incentivised Holt-Laury task (Holt and
## Laury, 2002)." lottery1 ... lottery10 are the ten rows, 1 for the safe
## option and 2 for the risky one. The amounts and why they are not quite the
## canonical ones are set out in the Lambrecht2024 block of generate_r.R.
##
## choice is the number of risky choices.
##
## INCONSISTENT. Single crossing was not enforced: 362 subjects switch once
## and 9 sit at a corner, but 59 switch more than once and cannot be given a
## switching point. Of the 9 corners, 5 take the safe option in every row --
## including row 10, where the safe option is dominated -- and 4 take the risky
## one throughout. Since 29.10.2026 the 59 (dropped before) and the 5 (counted
## before) are out of the statistics and kept for the download only, with
## inconsistent = 1 and one row per switch to the risky option
## (Data/inconsistent_rows.R); so is anyone who switches once the wrong way,
## risky first and safe after.
L <- paste0("lottery", 1:10)
b <- as.matrix(df[, L]) == 2
switches <- rowSums(b[, -1] != b[, -10])
stopifnot(sum(switches <= 1) == 371)

source("Data/inconsistent_rows.R")
B <- b * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0))

## gender is unlabelled in the file, but the task settles it: the group coded
## 0 takes the risky side 4.58 times on average against 4.02 for the group
## coded 1, so 1 is women, as the site expects. Age runs 17 to 57.
df <- df %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            gender = as.numeric(gender),
            age = as.numeric(age),
            frankfurt = as.numeric(frankfurt),
            bibkey = "Lambrecht2024",
            paper = "Lambrecht et al. 2024") %>%
  ## choice = number of risky choices = 11 - the row where they start
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Two labs: the Alfred-Weber-Institute lab in Heidelberg and the Frankfurt
## Laboratory for Experimental Economic Research, which the frankfurt column
## tells apart. The paper explains the split: some sessions moved to Frankfurt
## because the Heidelberg pool was not large enough.
df <- df %>%
  mutate(country = 'Germany',
         city = if_else(frankfurt == 1, 'Frankfurt', 'Heidelberg'),
         lattitude = if_else(frankfurt == 1, '50.1270', '49.4094'),
         longitude = if_else(frankfurt == 1, '8.6694', '8.6946')) %>%
  select(-frankfurt)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Lambrecht_et_al_2024/formatted_dataset.csv")
