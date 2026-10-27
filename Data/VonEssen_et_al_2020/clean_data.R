#### von Essen, E., Huysentruyt, M. & Miettinen, T. (2020). Exploration in teams
#### and the encouragement effect: Theory and experimental evidence.
#### Management Science (published online 2020).
#### https://doi.org/10.1287/mnsc.2019.3494
#### Data: the journal's replication package (survey.txt, experiment.txt and the
#### authors' do-files), kept in raw_repository/mnsc

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment on team exploration run "at the Cognition and Behavior
## Laboratory (Aarhus University, Denmark), the Aalto Choice Tank (Aalto
## University, Helsinki, Finland), and the Centre for Experimental Studies and
## Research (... Norwegian Business School, Oslo, Norway) during fall 2014 to
## spring 2016". Every subject first took a 10-minute online survey, which
## holds the risk measures.
##
## original_dataset.csv is the paper's sample rebuilt the way the authors'
## do-files build it: the lab participants of experiment.txt, minus the three
## tournaments played by research assistants (2.Data_experiment.do), joined
## with each person's latest survey entry (1.Data_survey.do, 3.Merge.do), with
## the authors' fix for the one duplicated id. That gives 430 participants (280
## Aarhus, 76 Helsinki, 74 Oslo), 413 investment answers and 417 answers to the
## risk question, the counts of Table 3. The participant ids, which look like
## initials plus a birth year, are replaced by row numbers.
##
## Task: the Gneezy and Potters (1997) investment game. 60 ECU, any amount
## invested; "a two-thirds probability of getting nothing and a one-third
## probability of winning two and a half times the amount invested", played out
## publicly in the lab. Read as in Gneezy and Potters, a loss of the amount
## invested or a gain of 2.5 times it (as for Hueber2022); a gross payout of
## 2.5 times would make the bet worth less than its cost, and nobody would
## invest the 33 ECU subjects put in on average. choice = ECU invested, after the
## authors' own fixes of the free-typed answers ("1/3" -> 20, "33%" -> 20,
## "30 ECU" -> 30, 100 and 200 out of 60 -> missing; 1.Data_survey.do).
##
## The survey also asked the general risk question of Dohmen et al. (2011),
## 0 (risk averse) to 10 (risk loving), which goes into soep. Four people
## answered it but not the investment; they are kept as questionnaire-only rows.
##
## gender: 2 = woman and 3 = man, as 3.Merge.do codes female; code 1 (one
## person) is left missing, as the authors do. Age was not asked.
df <- read_csv("Data/VonEssen_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 430, sum(!is.na(df$amount_lottery)) == 413,
          sum(!is.na(df$risk_single_q)) == 417)

df <- df %>%
  filter(!is.na(amount_lottery) | !is.na(risk_single_q)) %>%
  transmute(subject,
            task = if_else(is.na(amount_lottery), "quest_only", "IG"),
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = if_else(is.na(amount_lottery), risk_single_q, amount_lottery),
            soep = if_else(is.na(amount_lottery), NA_real_, risk_single_q),
            gender = case_when(gender == 2 ~ 1, gender == 3 ~ 0, TRUE ~ NA_real_),
            age = NA_real_,
            country = recode(country_code, DK = "Denmark", FI = "Finland", NO = "Norway"),
            city = recode(country_code, DK = "Aarhus", FI = "Helsinki", NO = "Oslo"))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "VonEssen2020",
         paper = "von Essen et al. 2020")

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
df %>% write_csv("Data/VonEssen_et_al_2020/formatted_dataset.csv")
