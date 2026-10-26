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
## THE BART IS NOT USED. The balloon task is the outcome the paper is about:
## insurance is offered or imposed on part of the balloons, so the number of
## pumps is a treatment response, not a clean risk measure. The file carries
## only two averages, over all thirty balloons and over balloons 2 to 29, and
## neither separates the insured balloons from the rest. Which balloons carried
## no insurance in each regime would settle it -- a question for the authors.
## The balloon itself is the standard 128-pump one ("each balloon can be pumped
## up to 128 times (it will surely pop at 128th pump)", one cent a pump), so
## the site could code it the moment the uninsured balloons are identified.
##
## What is used is the DOSPERT battery, asked after the task. The file holds
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
            task = "quest_only",
            ## no general risk item in this study, so `choice` -- which
            ## generate_data_for_app.R turns into soep -- stays empty
            choice = NA_real_,
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

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

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
