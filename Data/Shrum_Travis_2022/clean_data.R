#### Shrum, T. R. & Travis, W. R. (2022). Experiments in ranching: Rain-index
#### insurance and investment in production and drought risk management. Applied
#### Economic Perspectives and Policy, 44(3), 1513-1533.
#### https://doi.org/10.1002/aepp.13304
#### Data: github.com/tshrum/rain-index-insurance-simulation, branch master
#### (the default branch, main, holds only the licence)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two online studies with a ranch simulation followed by the Holt-Laury list
## (2.00 / 1.60 against 3.85 / 0.10 USD), paid: ten randomly chosen
## participants had one randomly chosen row played out.
##  - MTurk, October 2017: US workers, main Qualtrics export (608 rows; the
##    paper reports 610 recruited and 540 completing). The two pilot exports
##    (Beta, Small Launch) used other exchange rates for the game and are not
##    used;
##  - Ranchers, July 2018: professional ranchers, half of them in Colorado
##    (109 rows).
## Only nine rows were asked, 10% ... 90%: the 100% row, where B dominates, was
## left out. A subject with k B choices in the nine rows therefore has k + 1 in
## the standard ten-row coding, and choice = k + 1 (all A in the nine rows is
## a switch at the tenth row, choice 1).
## The authors' own coefficient (risk in mturkers.csv / ranchers.csv) gives a
## subject who switches at row j the interval for j safe choices instead of
## j - 1, and is not used.
## The raw exports hold IP addresses, geolocation, MTurk worker ids and the
## ranchers' e-mail addresses, so they are not copied; original_dataset.csv
## keeps the sample, the nine choices, sex and age, and subjects are row
## numbers. As for the other lists on the site, only subjects who answer all
## nine rows and switch once from A to B are kept: 466 MTurk workers (96 of
## them chose A in all nine rows) and 99 ranchers. 97 MTurk workers and 8
## ranchers left the list blank; 45 and 2 switched more than once (the paper
## reports 47 and 0). The 47 are kept for the download only, with
## inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R);
## a switch at row k of the nine is coded 11 - k, like a single switch there.
## Both samples are spread over the US, so no city and no coordinates.
df <- read_csv("Data/Shrum_Travis_2022/original_dataset.csv", show_col_types = FALSE,
               col_types = cols(.default = "c", subject = "i"))

stopifnot(nrow(df) == 717)

hl <- df %>% select(hl_1:hl_9) %>% as.matrix()
pattern <- apply(hl, 1, function(x) if (any(is.na(x))) NA_character_ else paste(x, collapse = ""))
single <- !is.na(pattern) & str_detect(pattern, "^A*B*$")

source("Data/inconsistent_rows.R")
complete <- !is.na(pattern)
df <- df %>%
  mutate(points = lapply(seq_len(nrow(hl)), function(i)
           if (complete[i]) switch_points(as.numeric(hl[i, ] == "B")) else integer(0)),
         inconsistent = as.numeric(complete & !single)) %>%
  filter(complete) %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age = suppressWarnings(as.numeric(age)),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            country = "United States",
            bibkey = "Shrum2022",
            paper = "Shrum and Travis 2022") %>%
  ## number of B choices in the standard ten-row list: nB + 1 = 11 - k
  expand_switches(function(k) if_else(is.na(k), 1, 11 - k))

stopifnot(sum(df$inconsistent == 0) == 565, n_distinct(df$subject[df$inconsistent == 1]) == 47)

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Shrum_Travis_2022/formatted_dataset.csv")
