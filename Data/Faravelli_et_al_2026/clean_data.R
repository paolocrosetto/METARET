#### Faravelli, M., Gordon, B., Huisman, J. & te Velde, V. L. (2026).
#### What drives voter turnout? Experimental insights on collectivism and
#### probability weighting.
#### Theory and Decision, 100, 427-449.
#### https://doi.org/10.1007/s11238-025-10079-3
#### Data: replication file of the paper

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 800 participants recruited on Amazon Mechanical Turk, restricted to the USA,
## run through Qualtrics. The experiment is about voter turnout; the risk
## elicitation is one of the side measures, used in the paper as a control when
## studying probability weighting.
df <- read_dta("Data/Faravelli_et_al_2026/original_dataset.dta")

## Task: ten rows, each a choice between a 50-50 lottery paying 49 or 70 cents
## and a 50-50 lottery paying 12 or X cents, with X running 70, 80, ... 160.
## The authors call this the Holt and Laury (2002) measure and it is a price
## list with a single switch point, but it varies the spread of the payoffs
## rather than the probability. That is the payoff-varying design this site
## files under PV, next to the Drichoutis-Lusk list, not under HL, and the
## canonical HL bounds do not apply; generate_r.R works them out from this menu.
##
## The lotteries are in neither the paper nor the replication file; they are in
## the online appendix (kept next to this file as Online_Appendix.pdf),
## section B.
##
## safechoices counts the rows where the safer lottery was taken, so the number
## of risky choices -- the convention this site uses for list tasks -- is 10
## minus that.
##
## The first row, X = 70, is an attention check: the safe lottery first-order
## stochastically dominates there, since it pays 49 rather than 12 on the low
## draw and 70 on the high draw either way. dropfromriskaversionanalysis flags
## the subjects who took the risky side anyway, and it is exactly the 14 people
## with no safe choice at all. They are dropped, as the authors drop them,
## because a dominated choice says nothing about r.
##
## male is 1 for men, so gender is its complement; one subject left it blank.
## age is the 2019 survey year minus the year of birth and has no gaps.
df <- df %>%
  filter(dropfromriskaversionanalysis == 0) %>%
  mutate(subject = row_number()) %>%
  transmute(subject,
            task = "PV",
            choice = 10 - as.numeric(safechoices),
            gender = 1 - as.numeric(male),
            age = as.numeric(age),
            bibkey = "Faravelli2026",
            paper = "Faravelli et al. 2026")

## Online on Mechanical Turk, with access restricted to users in the USA.
df$country = 'United States'
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
df %>% write_csv("Data/Faravelli_et_al_2026/formatted_dataset.csv")
