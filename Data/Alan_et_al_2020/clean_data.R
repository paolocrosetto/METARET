#### Alan, S., Ertac, S., Kubilay, E. & Loranth, G. (2020). Understanding gender
#### differences in leadership. The Economic Journal.
#### https://doi.org/10.1093/ej/uez050
#### Data: the journal's replication files (uez050_replication_files:
#### MainDataset_EJ.dta, SuppDataset_EJ.dta, do-files)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "Two cohorts of students in a number of state-run schools in Istanbul": 4th
## graders (elementary == 1, 769) and 8th graders (middle == 1, 625). The 4th
## graders are the baseline of the large evaluation of randomized educational
## interventions, which Alan2019 (grit, 4th graders in state schools of Istanbul)
## already brings to the site, so they are left out to avoid counting the same
## children twice; only the 8th graders (average age 13) are kept. The small
## supplementary experiment (SuppDataset_EJ.dta) is not used.
##
## Task: Gneezy-Potters, "5 tokens corresponding to gifts from a gift basket,
## which they can allocate between a risky and a riskless option. Tokens placed in
## the risky option ... are either tripled or lost, with 50% chance."
## indrisk = tokens in the risky option (individual decision); 5 of the 625 have
## none.
##
## male: 1 = boy. age_new is age in years; one 8th grader is recorded as 5.4,
## which cannot be right, so ages below 10 are left empty.
df <- read_csv("Data/Alan_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(sum(df$middle == 1) == 625, sum(df$elementary == 1) == 769)

df <- df %>%
  filter(middle == 1, !is.na(indrisk)) %>%
  transmute(subject = studentid,
            task = "IG",
            choice = indrisk,
            age = if_else(age_new >= 10, age_new, NA_real_),
            gender = if_else(male == 1, 0, 1),
            country = "Turkey",
            city = "Istanbul",
            bibkey = "Alan2020",
            paper = "Alan et al. 2020")

## the map is drawn by country; the coordinates are those of the city
df$lattitude = '41.0082'
df$longitude = '28.9784'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Alan_et_al_2020/formatted_dataset.csv")
