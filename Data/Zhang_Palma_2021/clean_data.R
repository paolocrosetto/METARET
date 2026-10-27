#### Zhang, P. & Palma, M. A. (2021). Compulsory versus voluntary insurance:
#### An online experiment.
#### American Journal of Agricultural Economics, 103(1), 106-125.
#### https://doi.org/10.1111/ajae.12120
#### Data: supplementary files of the article (ajae12120-sup-0002)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment on Amazon MTurk, 299 subjects, three insurance regimes
## (compulsory, mixed, voluntary). The main task is a thirty-balloon BART with
## insurance offered on some balloons.
##
## BART: subjects state in advance how many pumps they want on each balloon
## (up to 128, one cent a pump, "it will surely pop at 128th pump"), and the
## explosion point is drawn on the spot. Insurance was offered or imposed only
## on the FIRST and LAST balloon, in all three regimes: "For the other 28
## balloons, they played BART without the insurance option", and the paper
## calls them "the measurement of risk taking by BART". The authors' own
## averagewantedp229 is the mean of balloons 2-29 (checked against the thirty
## per-balloon columns); it is kept as average_wantedpumps_2_29 and used as
## choice, coded with the 128-pump rule of Frey2017 in generate_r.R.
##
## The DOSPERT battery, asked after the task, sits on the same row (as in
## Michael2020). The file holds
## sums, not item means: dospertall runs 30 to 187 over thirty items, doethics
## and dohealth and dorecreational and dosocial over six items each, dogamble
## and doinvest over three each. The site stores DOSPERT as the mean per item
## on the 1 to 7 scale, so every sum is divided by its own item count.
##
## The sensation-seeking scale in the same file is NOT used: its subscales run
## 0 to 10 and the total 1 to 38, which is not the 8-item 1-to-5 scoring the
## site's BSSS column holds (14 to 40), and the two cannot be mixed.
df <- read_csv("Data/Zhang_Palma_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 299)

df <- df %>%
  transmute(subject,
            task = "BART",
            choice = average_wantedpumps_2_29,
            doall   = as.numeric(dospertall) / 30,
            doethic = as.numeric(doethics) / 6,
            dogamble = as.numeric(dogamble) / 3,
            doinvest = as.numeric(doinvest) / 3,
            dohealth = as.numeric(dohealth) / 6,
            dorecre = as.numeric(dorecreational) / 6,
            dosocial = as.numeric(dosocial) / 6,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Zhang2021",
            paper = "Zhang and Palma 2021")

stopifnot(all(df$doall >= 1 & df$doall <= 7))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## country: NOT SET. An MTurk study with no residence requirement stated in the
## paper, the same treatment as the Prolific studies here.
df$country = NA_character_
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zhang_Palma_2021/formatted_dataset.csv")
