#### Filippin, A. & Pace, N. (2025).
#### The effect of social distancing on trust and solidarity.
#### Journal of Behavioral and Experimental Economics, 119, 102402.
#### https://doi.org/10.1016/j.socec.2025.102402
#### Data: replicationdata.dta and replication.do, sent by Antonio Filippin on
#### 30.10.2026 on request (the paper: "Data will be made available on
#### request"). original_dataset.csv keeps only the first-wave rows and the
#### state, in-group treatment, BRET choice, age and sex; the Prolific ids and
#### the trust, solidarity and social-contact answers are not copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online study on Prolific in the US: "In the first wave we administer
## incentivized tasks to respondents in Phoenix and Tucson, Arizona, on the
## same day (31th March 2020) in which a stay-at-home order was going to take
## effect, as well as in New York City where a stay-at-home policy had been
## already in place for two weeks. We then re-tested the same respondents on
## the 15th of April". Only the first wave (wave == 0, 266 respondents: 147 New
## York, 119 Arizona) is used: in the second "we remind participants the number
## of steps chosen in the first wave", so it is not an independent measurement.
df <- read_csv("Data/Filippin_Pace_2025/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 266, sum(df$state == 1) == 119)

## The task: "a simplified version of the static Bomb Risk Elicitation Task
## (BRET, Crosetto & Filippin, 2013) ... a winding road in which they earn $0.1
## for every step taken ... a time bomb is hidden behind one (and only one) of
## the 100 steps"; "The BRET is paid only once, randomly drawing the relevant
## wave". bomb = steps taken. male: 1 = male, flipped to the site's 1 = female.
df <- df %>%
  transmute(subject = row_number(),
            task = "BRET",
            choice = bomb,
            age = as.numeric(age),
            gender = 1 - male,
            treatment = if_else(state == 1, "Arizona", "New York"),
            arizona = state == 1)
stopifnot(all(df$choice %in% 0:100))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Filippin2025",
         paper = "Filippin and Pace 2025")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## New York City; Phoenix and Tucson in Arizona (the coordinates are Phoenix's).
df <- df %>%
  mutate(country = 'United States',
         city = if_else(arizona, 'Phoenix and Tucson', 'New York'),
         lattitude = if_else(arizona, '33.4484', '40.7128'),
         longitude = if_else(arizona, '-112.0740', '-74.0060')) %>%
  select(-arizona)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Filippin_Pace_2025/formatted_dataset.csv")
