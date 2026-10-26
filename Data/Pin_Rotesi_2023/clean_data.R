#### Pin, P. & Rotesi, T. (2023).
#### App-based experiments.
#### Journal of Economic Psychology, 99, 102666.
#### https://doi.org/10.1016/j.joep.2023.102666
#### Data: https://doi.org/10.17632/grw74bp3p3.1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## The paper compares a laboratory session with the same tasks run through a
## phone app, so each of the 232 participants went through the whole battery.
## Three of those tasks are risk elicitation tasks in the sense of this
## repository and all three are kept, which makes this one of the few papers
## with several tasks on the same people. 110 subjects sat in the BELSS Lab at
## Bocconi and 122 answered remotely; both groups come from the same pool and
## did identical tasks, so they are pooled.
##
## The exact lotteries are only in the online supplementary material, which is
## kept next to this file as Online_Supplementary_Material.pdf.
main <- read_dta("Data/Pin_Rotesi_2023/original_main.dta")
prelim <- read_dta("Data/Pin_Rotesi_2023/original_preliminary.dta")

## Gender is collected in the recruitment survey and joined on participant_code.
## Its Stata label reads "Gender (1=Female)", which is already this site's
## convention. A handful of codes repeat in the recruitment file, so it is made
## unique first. Age was never asked.
prelim <- prelim %>% distinct(participant_code, .keep_all = TRUE) %>%
  transmute(participant_code, gender = as.numeric(gender))

base <- main %>%
  left_join(prelim, by = "participant_code") %>%
  mutate(subject = row_number())

## Task "Risky Project 50%": endowment of 400 cents, any amount may be invested,
## the project succeeds with probability 1/2 and pays 2.5 times the amount
## invested, otherwise the investment is lost. That is the original
## Gneezy-Potters task and it is the one kept as IG here.
##
## The battery also holds a second investment task ("Risky Project 35%": 350
## cents, success with probability 0.35, paying three times the investment).
## Both were played by the same people, so emitting both as IG would put every
## subject into that cell twice; it is left out rather than double counted. The
## column is still in original_main.dta as task2_choice for anyone who wants it.
ig <- base %>% transmute(subject, task = "IG", choice = as.numeric(task1_choice), gender)

## Task "Gamble Choice": one of six 50/50 gambles, 4.65/4.65, 4/6, 3.4/7.2,
## 2.7/8.6, 2/10 and 0.5/11.5 euros. Expected values 4.65, 5, 5.3, 5.65, 6, 6 --
## the last two are equal, the Dave et al. (2010) structure.
eg <- base %>% transmute(subject, task = "EG", choice = as.numeric(task3_gamblechoice), gender)

## Task "Safe Gambles": nine rows of a Holt and Laury list, the safe gamble
## paying 4 or 5 euros and the risky one 0.25 or 9.6, with the probability of
## the high outcome rising from 0.1 to 0.9. task4_Achoices counts the safe
## choices, so the number of risky ones -- the convention used for HL on this
## site -- is 9 minus that.
hl <- base %>% transmute(subject, task = "HL", choice = 9 - as.numeric(task4_Achoices), gender)

df <- bind_rows(ig, eg, hl) %>%
  mutate(age = NA_real_,
         bibkey = "Pin2023",
         paper = "Pin and Rotesi 2023")

## BELSS Lab, Bocconi University, Milan; the app group answered remotely but was
## recruited from the same subject pool.
df$country = 'Italy'
df$city = 'Milan'
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
df %>% write_csv("Data/Pin_Rotesi_2023/formatted_dataset.csv")
