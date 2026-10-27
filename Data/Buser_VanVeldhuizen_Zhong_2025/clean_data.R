#### Buser, T., Van Veldhuizen, R. & Zhong, Y. (2025). Time pressure preferences.
#### Management Science 71(3), 1909-1924. https://doi.org/10.1287/mnsc.2023.02078
#### Data: the journal's replication package (data_analysis/raw_data and
#### clean_data, the authors' do-files, the oTree program without its venv),
#### kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Three samples, all in the Netherlands:
## 1. Online experiment "conducted online in June 2021 using the subject pool of
##    ... CREED of the University of Amsterdam": 211 participants (data_lab.xlsx,
##    one row per participant and round; original_dataset.csv keeps one row each).
## 2. Survey of "a cohort of first-year economics and business bachelor's degree
##    students ... at the University of Amsterdam" (studentsurveydata.dta, 1,312
##    rows): the risk-taking item on a 0-10 scale (Q1RiskPreferences; three
##    answers are 6.5 or 8.5 and are kept as given). No age.
## 3. The LISS panel (5,041 respondents) is not taken: it is the authors' own
##    LISS questionnaire, the one that already gives Buser2026 its 5,268 LISS
##    respondents (same risk item, same competitiveness item), so the people
##    would be counted twice.
##
## Task (lab): "a price list containing 11 choices between a sure amount of EUR 4
## and a random lottery between EUR 2 and EUR 6", the chance of EUR 6 rising from
## 0% to 100% in steps of 10 points. risky_choices = rows where the lottery was
## taken, counted from lottery1-lottery11 (2 = lottery, 4 = sure amount), the
## authors' choice_lottery. Every participant switched once. 0 (the sure EUR 4
## even against a sure EUR 6) and 11 (the lottery even when it pays EUR 2 for
## sure) choose a dominated option; those two participants are dropped.
## The lab's own risk item is on a 1-7 scale and is not used.
##
## sex in the lab data: 1 = male, 2 = female (the authors' female).
df <- read_csv("Data/Buser_VanVeldhuizen_Zhong_2025/original_dataset.csv",
               show_col_types = FALSE, col_types = cols(age = col_character()))

stopifnot(sum(df$sample == "lab") == 211, sum(df$sample == "student_survey") == 1312)

lab <- df %>%
  filter(sample == "lab", risky_choices %in% 1:10) %>%
  transmute(subject = participant,
            task = "CEPL",
            choice = risky_choices,
            gender = female,
            age = suppressWarnings(as.numeric(age)),
            city = "Amsterdam")

students <- df %>%
  filter(sample == "student_survey", !is.na(risk_0to10)) %>%
  ## numbered from 10001 so they do not clash with the lab ids (1-211)
  transmute(subject = 10000 + participant,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = risk_0to10,
            gender = female,
            age = NA_real_,
            city = "Amsterdam")

df <- bind_rows(lab, students) %>%
  mutate(country = "Netherlands")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "BuserVanVeldhuizen2025",
         paper = "Buser et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## (the questionnaire-only rows have no task, so no r)
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), function(b, t, c)
  if (t == "quest_only") NA_real_ else get_r(b, t, c)))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_VanVeldhuizen_Zhong_2025/formatted_dataset.csv")
