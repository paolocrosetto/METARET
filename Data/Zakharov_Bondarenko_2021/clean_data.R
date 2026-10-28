#### Zakharov, A. & Bondarenko, O. (2021).
#### Social status and social learning.
#### Journal of Behavioral and Experimental Economics, 90, 101647.
#### https://doi.org/10.1016/j.socec.2020.101647
#### Data: https://github.com/morhellis/Status-information
#### (the whole repository, with the rar archives unpacked, is in raw_repository/)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## replication_dataset_2019.dta from the replication package: 184 subjects
## (14 sessions) x 10 periods of the social-learning game. The risk task and
## the survey were done once, so one row per subject is kept.
df <- read_dta("Data/Zakharov_Bondarenko_2021/original_dataset.dta") %>%
  zap_labels() %>%
  distinct(sess_id, subj_id, .keep_all = TRUE)
stopifnot(nrow(df) == 184)

## The risk task: "each subject had to make 10 decisions ... between a safe
## lottery that offered 50 RUR with some probability p and 40 RUR with
## probability 1 - p, and a risky lottery that offered 96.25 RUR with
## probability p, and 2.5 RUR with probability 1 - p. The values of p varied
## from 0.1 to 1 in 0.1 increments" -- the Holt-Laury table times 12.5.
## risk1 ... risk10 are the ten rows, 1 = the risky lottery B (M6_risk.ztt:
## '0 = "A: 10% 50.00 ...', '1 = "B: 10% 96.25 ...'), so choice = number of
## risky choices. The authors' own `safe` is 1 - choice/10. Subjects who
## switched more than once are kept, as the authors do.
## include_data == 0 (4 subjects) only drops them from the social-learning
## regressions, so they are kept here.
df <- df %>%
  mutate(choice = risk1 + risk2 + risk3 + risk4 + risk5 +
                  risk6 + risk7 + risk8 + risk9 + risk10)
stopifnot(all(abs(df$safe - (1 - df$choice / 10)) < 1e-6))

## gender1 is "Male"; on this site gender is 1 for women.
df <- df %>%
  transmute(subject = row_number(),
            age = age,
            gender = 1 - gender1,
            task = "HL",
            choice = choice)

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Zakharov2021",
         paper = "Zakharov and Bondarenko 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "14 experimental sessions with a total of 184 participants at the
## Laboratory for Experimental and Behavioral Economics of the Higher School
## of Economics in Moscow, Russia."
df$country = 'Russia'
df$city = 'Moscow'
df$lattitude = '55.7614'
df$longitude = '37.6336'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zakharov_Bondarenko_2021/formatted_dataset.csv")
