#### Chakraborty, A. & Kendall, C. (2026). Noisy Foresight.
#### Journal of the European Economic Association, advance article.
#### https://doi.org/10.1093/jeea/jvag013
#### Data: replication package ChakrabortyKendallNoisyForesightReplication1
#### (Data folder, README.pdf)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment on Prolific, United States population (README, section 7).
## The 2P treatment ran in April 2022 (249 subjects, two runs); the three
## diagnostic versions of it, COGNITIVE UNCERTAINTY, BELIEFS and STRATEGY, ran
## in April-May 2024 with 251 each. No Prolific id appears in more than one of
## these files. original_dataset.csv keeps one row per subject of the four
## treatments; IP addresses, locations and Prolific ids are left out.
##
## After the two-period decision problems every subject did five "lottery
## tasks", the same five in all four treatments. Each starts with $1.00; the
## slider picks the amount withdrawn, which pays R1 per dollar, and the rest
## stays invested and pays R+ with probability p or RO = 1 otherwise (Table 1;
## parsedata.m: "data is withdrawal", investment = 1 - slider):
##   lottery 1: p 0.5, R1 1.5, R+ 2.2      lottery 4: p 0.2, R1 1.5, R+ 3
##   lottery 2: p 0.2, R1 1.5, R+ 4        lottery 5: p 0.3, R1 1,   R+ 3
##   lottery 3: p 0.3, R1 1.5, R+ 3
## Lottery 5 is dominated by full investment and lottery 4 has an expected
## value below the safe return, so neither measures risk aversion in the
## site's sense. Lottery 1 is the 50/50 version of the Gneezy-Potters asset and
## is used: choice = cents invested (0-100). The 2P decision problems themselves
## are the paper's treatment and are not used, nor are the 3P treatment's
## compound lotteries.
##
## The authors keep every subject in their main analysis (filterdominance = 0
## in parsedata.m), and so does the site: the lottery task has no dominated
## choice. The files hold no age or sex, only education.
df <- read_csv("Data/Chakraborty_Kendall_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 1002, !anyNA(df$withdraw_lottery1),
          all(df$withdraw_lottery1 >= 0 & df$withdraw_lottery1 <= 1))

df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = round(100 * (1 - withdraw_lottery1)),
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Chakraborty2026",
            paper = "Chakraborty and Kendall 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Prolific, United States; no place more precise than the country
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chakraborty_Kendall_2026/formatted_dataset.csv")
