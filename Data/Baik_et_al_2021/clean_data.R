#### Baik, K. H., Chowdhury, S. M. & Ramalingam, A. (2021). Group size and
#### matching protocol in contests. Canadian Journal of Economics, 54(4).
#### https://doi.org/10.1111/caje.12557
#### Data: Borealis 10.5683/SP3/LA0YBJ (PS-final.dta); also on Harvard Dataverse
#### 10.7910/DVN/UMH86H

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 180 students of the University of East Anglia, Norwich, 10 sessions of 18,
## recruited through ORSEE. Before 25 periods of a contest they made one choice
## in the Eckel and Grossman (2008) risk task, revealed at the end: "six options
## (1 to 6) in increasing order of risk" (paper, section on regressions), so
## choice = egchoice with 1 = the safe option. The gambles are printed in the
## Appendix (Instructions - Part 1) of the accepted manuscript (White Rose eprint
## 192123), not in the package: 20/20, 16/28, 12/36, 8/44, 4/52, -2/58 tokens,
## 50/50, 1 token = 3 pence. That is not the Eckel-Grossman (2008) table but the
## table shifted down by 8 tokens, and the last gamble can lose, so the task is
## EG_loss with its own bounds (Baik2021 block of generate_r.R). Corrected on
## 28.10.2026; it had been given the Charness2019 bounds.
## One subject gave age 100, which is set to missing.
## The file has one row per subject and period; original_dataset.csv keeps one
## row per subject: session, treatment, the EG choice, female and age; subjects
## are row numbers.
df <- read_csv("Data/Baik_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 180, all(df$egchoice %in% 1:6))

df <- df %>%
  transmute(subject,
            task = "EG_loss",
            choice = egchoice,
            age = if_else(age > 90, NA_real_, age),
            gender = female,
            country = "United Kingdom",
            city = "Norwich",
            bibkey = "Baik2021",
            paper = "Baik et al. 2021")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '52.6309'
df$longitude = '1.2974'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Baik_et_al_2021/formatted_dataset.csv")
