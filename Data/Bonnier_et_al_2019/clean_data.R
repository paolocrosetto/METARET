#### Bonnier, E., Dreber, A., Hederos, K. & Sandberg, A. (2019). Exposure to
#### half-dressed women and economic behavior. Journal of Economic Behavior and
#### Organization, 168, 393-407. https://doi.org/10.1016/j.jebo.2019.10.017
#### Data: OSF, https://osf.io/xpm2r/ (data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment on whether advertising images of half-dressed women change
## risk taking, competitiveness and math performance. Run at the Center for
## Experimental Economics (CEE), University of Copenhagen, in 2016 and 2017, and
## at LINEEX, University of Valencia, in 2017; 651 subjects in the file, 648 in
## the paper. Mean age 24.67, which the file reproduces exactly.
##
## Risk task: two incentivized price lists of ten rows each, both between two
## coin-flip lotteries, preceded by one worked example. The do-file states the
## coding: risk_decision1 is the example, risk_decision2-11 the first list,
## risk_decision12-21 the second, 1 = safe (left), 2 = risky (right). One of the
## twenty rows was drawn and played for money.
##
## Only the FIRST list is used. The site holds one coefficient per subject per
## task and the two lists are different menus, so they cannot be pooled into one
## switching point. The second list's row 1 (25 or 45 against 2 or 40) is
## dominated by the safe side; it reads as a built-in dominance check rather than
## a typo (32 subjects took the risky side there, about as many as in rows 2 and
## 3). It would add little: of the 113 subjects dropped from the first list only
## 48 answer the second one cleanly, and among those clean on both the two counts
## correlate at 0.64. So the first list is kept alone; its menu is in the
## Bonnier2019 block of generate_r.R.
## Kept: the 538 subjects whose ten answers switch at most once; 113 switch more
## often, so their count is not a switching point.
## choice = number of risky choices.
## gender: the authors' free-text field, "Female"/"F" = 1, "Male"/"M" = 0.
## age = year of the session minus year of birth; country from the site, which
## the do-file reads off the session name (the 1705 sessions are Valencia).
df <- read_csv("Data/Bonnier_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 651)
rd <- df %>% select(risk_decision2:risk_decision11) %>% as.matrix()
stopifnot(all(rd %in% c(1, 2)))
switches <- rowSums(rd[, -1] != rd[, -10])

df <- df %>%
  mutate(switches = switches, n_risky = rowSums(rd == 2)) %>%
  filter(switches <= 1) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = n_risky,
            age = session_year - byear,
            gender = case_when(gender %in% c("Female", "F") ~ 1,
                               gender %in% c("Male", "M") ~ 0,
                               TRUE ~ NA_real_),
            country = if_else(site == "Valencia", "Spain", "Denmark"),
            city = site)
stopifnot(nrow(df) == 538)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Bonnier2019",
         paper = "Bonnier et al. 2019")

## two labs, so coordinates per city
df <- df %>%
  mutate(lattitude = if_else(city == "Valencia", "39.4699", "55.6761"),
         longitude = if_else(city == "Valencia", "-0.3763", "12.5683"))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bonnier_et_al_2019/formatted_dataset.csv")
