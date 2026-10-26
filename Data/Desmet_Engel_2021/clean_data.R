#### Desmet, P. T. M. & Engel, C. (2021).
#### People are conditional rule followers.
#### Journal of Economic Psychology, 85, 102384.
#### https://doi.org/10.1016/j.joep.2021.102384
#### Data: https://osf.io/d5an9

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 120 students of Hamburg University, mean age 25.69 and 40.83% female, as the
## paper reports and the file reproduces. The main experiment is about rule
## following; a Holt and Laury list was run afterwards, among several other
## post-experimental measures. The file is long, one row per participant per
## problem (4800 rows), and everything used here is constant within uid.
df <- read_dta("Data/Desmet_Engel_2021/original_dataset.dta") %>%
  distinct(uid, .keep_all = TRUE)

## The number of safe choices was not released. What the file gives is `rra`,
## the relative risk aversion the authors read off the list, and it takes
## exactly the nine Holt and Laury interval bounds: -1.71, -0.95, -0.49, -0.14,
## 0.15, 0.41, 0.68, 0.97 and 1.37. On this site's scale, r = 1 - RRA, those are
## the nine canonical HL bounds 2.71, 1.95, 1.49, 1.14, 0.85, 0.59, 0.32, 0.03
## and -0.37 -- the same numbers the HL blocks of generate_r.R use.
##
## Because only the bound is released and not the count, there is no way to tell
## whether the authors took the lower or the upper end of each participant's
## interval, and guessing would move everyone by one category, about 0.3 in r.
## So nothing is guessed: r is taken straight from their measure as 1 - rra, a
## point rather than a draw from an interval, and `choice` holds `rra` itself,
## which is the response as released. generate_r.R is therefore not sourced,
## as for Crosetto and Filippin 2013 and Gnambs et al. 2015, which also compute
## r in this file.
##
## sex carries Stata value labels male = 0, female = 1, so it is already this
## site's convention; the resulting 40.8% matches the paper.
df <- df %>%
  filter(!is.na(rra)) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = as.numeric(rra),
            r = 1 - as.numeric(rra),
            gender = as.numeric(sex),
            age = as.numeric(age),
            bibkey = "Desmet2021",
            paper = "Desmet and Engel 2021")

## University of Hamburg.
df$country = 'Germany'
df$city = 'Hamburg'
df$lattitude = '53.5653'
df$longitude = '9.9847'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Desmet_Engel_2021/formatted_dataset.csv")
