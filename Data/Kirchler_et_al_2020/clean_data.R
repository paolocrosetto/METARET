#### Kirchler, M., Lindner, F. & Weitzel, U. (2020).
#### Delegated investment decisions and rankings.
#### Journal of Banking and Finance, 120, 105952.
#### https://doi.org/10.1016/j.jbankfin.2020.105952
#### Data: https://osf.io/6fjg7

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## The paper has three parts: an online experiment with 805 financial
## professionals, a lab-in-the-field experiment with another 160, and the
## online survey used here, with 1349 respondents -- 1000 from a representative
## sample of the general population, 125 financial professionals, 120
## professional athletes and 104 academics, which is exactly what the file
## holds.
##
## Only the survey is used. Neither experiment can contribute a task:
##  - the lab-in-the-field file releases `bomb`, which the z-Tree code shows to
##    be the random position of the bomb (bomb = roundup(random()*row*column,1)),
##    not the number of boxes collected; the collected count was not released.
##    Four checks confirm it is noise: no clustering on round numbers (16 of 160
##    are multiples of ten against 16 expected), no correlation with self-rated
##    financial risk (rho = 0.007), no gender difference, and a
##    Kolmogorov-Smirnov test against the uniform that does not reject.
##  - the online experiment records only a binary choice between a risk-free
##    and a risky asset (`lottery`), which bounds r on one side only.
df <- read_dta("Data/Kirchler_et_al_2020/original_survey.dta")

## The survey asks the general risk question of Dohmen et al. (2011) word for
## word (Survey_general_english.pdf, kept next to this file): "How do you see
## yourself: Are you generally a person who is fully prepared to take risks or
## do you try to avoid taking risks?", anchored "not at all willing to take
## risks" to "very willing to take risks". It is coded 1 to 11 rather than the
## usual 0 to 10, so one is subtracted; the number of steps is the same, so no
## rescaling is needed.
##
## The direction is confirmed by the data: financial professionals average 7.13
## and athletes 7.12 against 5.96 for academics and 6.05 for the general
## population, which is the ordering the paper reports.
##
## risk_fin is the same question asked about financial matters and goes into
## soep_financial. risk_trust is about trusting strangers and is left out.
##
## There is no incentivised task here, so the rows are marked 'quest_only';
## generate_data_for_app.R moves `choice` into `soep`.
df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk) - 1,
            soep_financial = as.numeric(risk_fin) - 1,
            gender = as.numeric(female),
            ## the survey ran in 2019 (the paper was submitted that September),
            ## so the age is accurate to about a year
            age = 2019 - as.numeric(born),
            bibkey = "Kirchler2020",
            paper = "Kirchler et al. 2020")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online survey; the main text does not say where the respondents lived
df$country = NA_character_
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kirchler_et_al_2020/formatted_dataset.csv")
