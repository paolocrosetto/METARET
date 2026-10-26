#### Andersen, S., Harrison, G. W., Lau, M. I. & Rutström, E. E. (2014).
#### Discounting behavior: A reconsideration. European Economic Review, 71, 15-33.
#### https://doi.org/10.1016/j.euroecorev.2014.06.009
#### Data: CEAR replication archive (Glenn Harrison agreed to the inclusion in METARET,
#### e-mail to Paolo Crosetto, 20.10.2026). The same 2009 field sample is used in
#### Andersen et al., "Multiattribute utility theory, intertemporal utility and
#### correlation aversion" (International Economic Review, 2018); it is added once, here.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Data.dta, one row per subject and decision: 413 adults from a nationally
## representative Danish field experiment (phase 1, Sep-Oct 2009) and 88
## students in a lab session in Copenhagen (phase 3, May 2010).
## Each subject answered four Holt-Laury type lists with different prizes; only
## the list with the original Holt-Laury prizes times 1000 (A 2000/1600, B 3850/100
## DKK, probability of the high prize 0.1 ... 1.0) is used, so the standard
## bounds apply. choicea: 1 = A (safe). choice = number of B choices.
## The other three lists (skewed prizes) and the discounting tasks are not used.
## The 2003 Danish field sample (Andersen et al. 2008) is already in METARET
## (Harrison2008) and is not part of this file.
## Age is missing for the lab students (also in the authors' Data.dta).
##
## As for the other lists on the site, only subjects who switched once from A
## to B are kept: 87 of the 501 switched more than once (81 field, 6 lab), and
## 15 chose A in all ten rows, including the last, where B pays 3850 DKK for
## sure (all in the field). 399 remain: 317 from the field, 82 from the lab.
df <- read_csv("Data/Andersen_et_al_2014/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 5010, n_distinct(df$userid) == 501)

df <- df %>%
  arrange(userid, rowproba) %>%
  group_by(userid) %>%
  filter(str_detect(paste(choicea, collapse = ""), "^1*0*$"), sum(choicea == 0) >= 1) %>%
  ungroup()

stopifnot(n_distinct(df$userid) == 399)

df <- df %>% 
  group_by(userid) %>% 
  summarise(choice = sum(choicea == 0),
            phase = first(phase),
            age = first(age),
            gender = first(female),
            .groups = "drop") %>% 
  transmute(subject = row_number(),
            task = "HL",
            choice,
            age = as.numeric(age),
            gender = as.numeric(gender),
            country = "Denmark",
            city = if_else(phase == 3, "Copenhagen", ""))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Andersen2014",
         paper = "Andersen et al. 2014")

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
df %>% write_csv("Data/Andersen_et_al_2014/formatted_dataset.csv")
