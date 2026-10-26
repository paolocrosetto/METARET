#### Aassve, A., Capezzone, T., Cavalli, N., Conzo, P. & Peng, C. (2024).
#### Social and political trust diverge during a crisis.
#### Scientific Reports, 14, 331.
#### https://doi.org/10.1038/s41598-023-50898-4
#### Data: https://osf.io/mxgzr

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## A three-wave MTurk panel of United States respondents run through the first
## year of the pandemic, with a survey experiment embedded in the last wave.
##
## The package has two files. 3Wworkingdata2.dta is the panel, 21,418 rows over
## 976 respondents, and it carries the risk question for 595 of them, repeated
## unchanged in all three waves. experiment_v2.dta is the experiment, one row
## per participant, 988 of them, and it carries the same question for 986.
## Matching on the respondent id shows the second file contains the first:
## all 595 panel respondents with an answer appear in it, each exactly once,
## alongside 393 further participants who have no panel id. So the experiment
## file is the one used here -- it is the wider sample and counts nobody twice.
df <- read_csv("Data/Aassve_et_al_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 988)

## WHY quest_only: the study is about social and political trust during the
## crisis and contains no incentivised choice over lotteries.
##
## The item is the general willingness-to-take-risks question of Falk et al.,
## quoted verbatim from the questionnaires in the package (Trust_Third_Wave.pdf
## and Trust_Experiment_Beefing.pdf): "We now ask you for your willingness to
## act in a certain way. Please again indicate your answer on a scale from 0 to
## 10 [completely unwilling to do so ... very willing to do so]: Take risks".
## The column name, riskpercep, is misleading -- the variable label in the file
## is simply "Take risks", and the wording above is the one subjects saw.
## 986 of the 988 answered, and all eleven points are used.
##
## female is already 1 for women. The direction is the usual one: men average
## 4.90 against women's 3.86.
##
## Two ages are birth years, 1957 and 1990, and are set missing; the rest run
## 18 to 83 with a mean of 39.0.
df <- df %>%
  filter(!is.na(riskpercep)) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(riskpercep),
            gender = as.numeric(female),
            age = if_else(age >= 18 & age <= 100, as.numeric(age), NA_real_),
            bibkey = "Aassve2024",
            paper = "Aassve et al. 2024")
stopifnot(nrow(df) == 986)

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## An online panel of United States residents recruited on Mechanical Turk;
## no city is recorded.
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Aassve_et_al_2024/formatted_dataset.csv")
