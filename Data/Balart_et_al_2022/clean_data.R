#### Balart, P., Ezquerra, L. & Hernandez-Arenaz, I. (2022).
#### Framing effects on risk-taking behavior: evidence from a field experiment
#### in multiple-choice tests. Experimental Economics, 25, 1268-1297.
#### https://doi.org/10.1007/s10683-022-09748-9
#### Data: https://doi.org/10.17605/OSF.IO/JX2DN

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## One row per student per exam, so a student who sat more than one exam appears
## more than once. The file carries no student identifier, but the risk measures
## were collected once per student in a separate questionnaire, so the rows of a
## repeated student are identical on all of them. Collapsing on the full vector
## of risk measures plus sex and academic record takes 217 rows with risk data
## down to 206 distinct students; `bomb` alone has 65 distinct values, so an
## accidental tie across all six variables is implausible.
df <- read_dta("Data/Balart_et_al_2022/original_dataset.dta") %>%
  filter(!is.na(bomb)) %>%
  distinct(bomb, SOEP, Eckel_Gross, loss_Eckel_Gross, Gacht_lambda, female, MITCMP) %>%
  arrange(Eckel_Gross, bomb, SOEP, female) %>%
  mutate(subject = row_number())

## Every risk measure in the file is stored negated -- the README says each one is
## "reversed to increase in risk aversion". Undoing that gives the raw answers:
##   Eckel_Gross  -6..-1  -> option 1..6 of the ordered lottery selection
##   bomb       -100..-1  -> 1..100 boxes collected in the bomb risk task
##   SOEP        -10..0   -> the usual 0-10 willingness to take risks scale
## Two students have half-integer values (Eckel_Gross -1.5, SOEP -6.5); these are
## not valid options, so they are dropped for the task and kept as NA for SOEP.
df <- df %>%
  mutate(eg    = -Eckel_Gross,
         boxes = -bomb,
         soep  = if_else(SOEP %% 1 == 0, -SOEP, NA_real_),
         ## 1 - female, 0 - male
         gender = as.numeric(female))

## The ordered lottery selection (questionnaire page 1): six 50/50 options added
## to a 120 euro base -- 28/28, 24/34, 20/40, 16/46, 12/52 and 2/62 euros.
## Options 5 and 6 have the same expected value, the Dave et al. (2010) structure
## already used for Razen et al. 2021 and Eckel et al. 2025 on this site.
eg_df <- df %>% filter(eg %% 1 == 0, eg >= 1, eg <= 6) %>%
  transmute(subject, choice = eg, soep, gender, task = "EG")

## Bomb risk elicitation task with 100 boxes, scored as boxes collected.
bret_df <- df %>% filter(boxes >= 1, boxes <= 100) %>%
  transmute(subject, choice = boxes, soep, gender, task = "BRET")

df <- bind_rows(eg_df, bret_df) %>%
  mutate(bibkey = "Balart2022",
         paper = "Balart et al. 2022",
         age = NA_real_)

## Field experiment at the University of the Balearic Islands, Palma de Mallorca.
df$country = 'Spain'
df$city = 'Palma'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Balart_et_al_2022/formatted_dataset.csv")
