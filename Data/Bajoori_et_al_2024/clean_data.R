#### Bajoori, E., Peeters, R. & Wolk, L. (2024).
#### Security auctions with cash- and equity-bids: An experimental study.
#### European Economic Review, 163, 104702.
#### https://doi.org/10.1016/j.euroecorev.2024.104702
#### Data: https://osf.io/tpmzr

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The auction itself is not a risk elicitation task, but every participant also
## did a bomb risk elicitation task afterwards, and that is what is kept here.
## The package ships one file per treatment. The four main treatments (FPC, SPC,
## FPE, SPE) hold the 248 participants of Table 4; FPC+ and FPE+ are the two
## additional treatments of Section 4.2, run with 89 *different* participants who
## went through ten practice auction rounds first. The BRET is identical in all
## six and comes after the auction, and the difference in boxes collected between
## the two pools is not significant (30.1 vs 26.6, t-test p = 0.13), so all 337
## are kept.
##
## Checked against the paper: mean boxes over the four main treatments is 30.15,
## exactly Table 4; mean age 26.74 and mean self-reported risk 6.32 likewise.
read_one <- function(f) read_csv(file.path("Data/Bajoori_et_al_2024", f), show_col_types = FALSE)
df <- bind_rows(lapply(c("original_fpc.csv", "original_fpe.csv", "original_spc.csv",
                         "original_spe.csv", "original_fpc_practice.csv",
                         "original_fpe_practice.csv"), read_one))

## Dynamic bomb risk elicitation task of Crosetto and Filippin (2013) on a 10-by-10
## field: boxes are collected one at a time until the participant stops, one point
## each, and one of the hundred boxes hides a bomb. choice = boxes collected,
## 0-100, with 50 the expected-payoff maximising number. Eight participants
## collected all 100; the authors keep them and so do we, at the corner value.
##
## gender: 2 is female -- confirmed against Table 4, where the share of gender == 2
## reproduces the reported percentage of women in each of the four main treatments
## (55.38, 63.79, 50.79, 58.33). Codes 3 and 4 are "gender diverse" and "prefer not
## to say" and become NA. One participant entered an age of 8, which the authors
## treat as a typo and exclude; it becomes NA here.
## risk is the Dohmen et al. (2011) willingness to take risks on a 0-10 scale.
df <- df %>%
  transmute(subject = row_number(),
            choice = as.numeric(boxes_collected),
            age = if_else(age >= 18, as.numeric(age), NA_real_),
            ## 1 - female, 0 - male
            gender = case_when(gender == 2 ~ 1,
                               gender == 1 ~ 0,
                               TRUE ~ NA_real_),
            soep = as.numeric(risk))

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "BRET",
         bibkey = "Bajoori2024",
         paper = "Bajoori et al. 2024")

## Online, recruited through Prolific. The paper restricts the pool to ages 18-65
## and fluency in English but states no country, so none is recorded; payment was
## in GBP, which is suggestive but not a stated restriction.
df$country = ''
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bajoori_et_al_2024/formatted_dataset.csv")
