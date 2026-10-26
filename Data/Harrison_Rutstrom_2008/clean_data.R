#### Harrison, G. W. & Rutström, E. E. (2008). Risk aversion in the laboratory.
#### In J. C. Cox & G. W. Harrison (eds.), Risk Aversion in Experiments,
#### Research in Experimental Economics 12, 41-196. https://doi.org/10.1016/S0193-2306(08)00003-3
#### Data: CEAR, https://cear.gsu.edu/files/2016/07/Risk-Aversion-in-the-Laboratory.zip
#### (Glenn Harrison agreed to the inclusion in METARET, e-mail to Paolo Crosetto, 20.10.2026)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The zip collects data of several studies, one folder each. Two are the
## chapter's own experiments, both with UCF students (Orlando, US); the other
## folders hold data of separately published papers (Holt and Laury 2002 is
## already in METARET; Gneezy and Potters 1997, Haigh and List 2005, Holt and
## Laury 2005 are handled on their own).
##  - Methods (HLdata.dta): 53 subjects, each doing a Holt-Laury list and a
##    Binswanger choice (order randomised, hl_first).
##     HL: Holt-Laury list times 10 (A 20/16, B 38.50/1 dollars).
##     Binswanger (Binswanger Replication Instructions.pdf): one of eight 50/50
##     options a-h: 10/10, 19/9, 24/8, 25/7, 30/6, 32/4, 38/2, 40/0 dollars.
##     choice = 1 (a) ... 8 (h).
##     Sex and age are not in HLdata.dta but in HOdata.dta of the same folder,
##     under the same ids -- the authors' Analysis.do merges them that way. All
##     53 match; Female is 1 for sex == 2 (22 women).
##  - FP_Auction_Bidding (ucfFP.dta): section 3.6 of the chapter, first-price
##    auctions preceded by "the Holt and Laury (2002) design ... scaled ... up by
##    a factor of 2" (largest prize 7.70, smallest 0.20 dollars). 108 subjects
##    in 5 sessions with sex and age (the chapter describes 58 of them in three
##    sessions; the risk task came first in every session, so all are kept).
##    row1 ... row10 are A or B; the authors' crraLO/crraHI are the standard
##    Holt-Laury intervals, so the shared bounds apply.
## original_dataset.csv (one row per subject, decision_x 1 = safe A) is built
## from the two files; numB = number of risky choices.
##
## HL, as for the other lists on the site: subjects who switched more than once
## are dropped (2 in Methods, 17 in the auction sessions), and so are those who
## chose A even in the last row, where B pays the high prize for sure (2 and 3).
## The Binswanger choice of all 53 Methods subjects is kept.
df <- read_csv("Data/Harrison_Rutstrom_2008/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 161, sum(df$sample == "methods") == 53)

pattern <- apply(df %>% select(decision_1:decision_10), 1, paste, collapse = "")
df <- df %>%
  mutate(hl_ok = str_detect(pattern, "^1*0*$") & numB >= 1)

stopifnot(sum(df$hl_ok & df$sample == "methods") == 49,
          sum(df$hl_ok & df$sample == "fp_auction") == 88)

df <- df %>%
  transmute(subject = row_number(),
            HL = if_else(hl_ok, numB, NA_real_),
            EG = match(binswanger, letters[1:8]),
            gender = female,
            age,
            country = "United States",
            city = "Orlando") %>%
  pivot_longer(c(HL, EG), names_to = "task", values_to = "choice") %>%
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "HarrisonRutstrom2008",
         paper = "Harrison and Rutström 2008")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Harrison_Rutstrom_2008/formatted_dataset.csv")
