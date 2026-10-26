#### Belot, M., Kircher, P. & Muller, P. (2025). Eliciting time preferences when
#### income and consumption vary: Theory, validation, and application to job
#### search. American Economic Journal: Microeconomics, 17(1), 130-170.
#### https://doi.org/10.1257/mic.20220118
#### Data: openICPSR, https://doi.org/10.3886/E198281
#### (JobseekerStudy/original_datasets)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper is about time preferences, but the job seeker study it builds on
## ran a separate risk elicitation in its survey: unemployed job seekers in
## Edinburgh picked one of six coin-flip options. The levels of the authors'
## risk_preference variable spell the menu out, in pounds:
##   "I keep 2.80", then "1 - Tails: 2.40 / Heads: 3.60",
##   "2 - Tails: 2.00 / Heads: 4.40", "3 - Tails: 1.60 / Heads: 5.20",
##   "4 - Tails: 1.20 / Heads: 6.00", "5 - Tails: 0.20 / Heads: 7.00".
## Expected values run 2.80, 3.00, 3.20, 3.40, 3.60, 3.60 - rising and then
## flat, which is the Eckel-Grossman shape, so the task is labelled EG and the
## bounds are in the Belot2025 block of generate_r.R.
## choice = 1 for the sure amount up to 6 for the widest spread; all 299
## respondents answered.
##
## original_dataset.csv keeps that answer plus gender and age, which are not in
## the preferences file and were taken from weekly_panel_jobsearch.dta by
## username (295 of the 299 match). The time preference items in the same file
## and the separate validation experiment are not used.
## gender: the authors' coding is male = 0, female = 1, which already matches
## the site.
df <- read_csv("Data/Belot_et_al_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 299)

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = case_when(risk_preference == "I keep 2.80"                   ~ 1,
                               risk_preference == "1 - Tails: 2.40 / Heads: 3.60" ~ 2,
                               risk_preference == "2 - Tails: 2.00 / Heads: 4.40" ~ 3,
                               risk_preference == "3 - Tails: 1.60 / Heads: 5.20" ~ 4,
                               risk_preference == "4 - Tails: 1.20 / Heads: 6.00" ~ 5,
                               risk_preference == "5 - Tails: 0.20 / Heads: 7.00" ~ 6),
            age,
            gender,
            country = "United Kingdom")
stopifnot(!any(is.na(df$choice)))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Belot2025",
         paper = "Belot et al. 2025")

## the study ran with job seekers in Edinburgh
df$city = 'Edinburgh'
df$lattitude = '55.9533'
df$longitude = '-3.1883'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Belot_et_al_2025/formatted_dataset.csv")
