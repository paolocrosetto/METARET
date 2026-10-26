#### Ashraf, S., Brown, A. L., Burris, M. W. & Vitaku, V. (2023).
#### Aggregate and individual effects of information in a coordination
#### (traffic) game.
#### Economic Inquiry, 61(4), 818-850.
#### https://doi.org/10.1111/ecin.13143
#### Data: the replication package distributed with the article
#### Menu: the Wiley supporting information, ecin13143-sup-0002_Appendix.pdf,
#### a copy of which sits in this folder.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Study 2 of the paper: a hundred-period route-choice game played by two
## populations, 184 students at Texas A&M in College Station and 133 regular
## commuters from the Dallas/Fort Worth area who played online. The published
## file is the long panel, 31,665 rows; the survey answers are constant within
## a subject, so one row per subject is kept.
df <- read_csv("Data/Ashraf_et_al_2023/original_dataset.csv", show_col_types = FALSE)
stopifnot(n_distinct(df$id) == 317)
df <- df %>% distinct(id, .keep_all = TRUE)

## THE TASK is the Eckel and Grossman gamble choice, unincentivised, and the
## package's readme says so: risk_total is the "choice in Eckel Grossman
## unincentivised elicitation ... higher number indicates more risk tolerance".
## The menu is in the supporting information and runs 50/50 chances of $10 and
## $10, $18 and $6, $26 and $2, $34 and -$2, $42 and -$6. Two of the five can
## take money off the subject, so the row is EG_loss rather than EG; the shift
## that makes the bounds computable is explained in the Ashraf2023 block of
## generate_r.R.
##
## The readme calls the range 1 to 6; the supporting information shows five
## gambles, and the column indeed never takes the value 6.
##
## 316 of the 317 answered. The paper's Table A13 reports the same: N 316,
## mean 2.835, and gender (male = 1) at 0.483 over 317, both of which the
## columns reproduce. Age was asked in brackets but is not in the published
## file, so it stays missing here.
##
## The direction is the usual one: men average 3.13 against women's 2.56.
df <- df %>%
  filter(!is.na(risk_total)) %>%
  transmute(subject = row_number(),
            task = "EG_loss",
            choice = as.numeric(risk_total),
            gender = 1 - as.numeric(gender),
            age = NA_real_,
            dallas = as.numeric(Dallas),
            bibkey = "Ashraf2023",
            paper = "Ashraf et al. 2023")
stopifnot(nrow(df) == 316)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Two sites in one study: the students sat in the laboratory at Texas A&M in
## College Station, the commuters took part online from the Dallas/Fort Worth
## area, and the Dallas column tells them apart.
df <- df %>%
  mutate(country = 'United States',
         city = if_else(dallas == 1, 'Dallas', 'College Station'),
         lattitude = if_else(dallas == 1, '32.7767', '30.6280'),
         longitude = if_else(dallas == 1, '-96.7970', '-96.3344')) %>%
  select(-dallas)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Ashraf_et_al_2023/formatted_dataset.csv")
