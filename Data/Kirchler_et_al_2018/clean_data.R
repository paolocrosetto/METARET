#### Kirchler, M., Lindner, F. & Weitzel, U. (2018). Rankings and risk-taking in
#### the finance industry. The Journal of Finance.
#### https://doi.org/10.1111/jofi.12701
#### Data: the journal's supporting information (Data_Code_Software: the
#### lab-in-the-field and online data, do-file, z-Tree files; the Internet
#### Appendix with the instructions), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper runs lab-in-the-field experiments with 657 financial professionals
## and a lab experiment, STUD, with "432 students ... at the University of
## Innsbruck (Austria)" in the Innsbruck EconLab. The lab-in-the-field file holds
## only STUD (prof = 0, prof_word = "Students"), one row per subject and period
## of the investment game; original_dataset.csv keeps one row per subject
## (subjectid). The online file (PROF ONLINE) has no risk measure.
##
## Task: Part 2, Section 1, "7 decisions ... OPTION A: A payment with 100%
## probability ... OPTION B: either 0 euro with 50% probability or 24 euro with
## 50% probability", the sure amounts 3, 6, ..., 21 euro (3_Experiment_AddTasks
## _PROF_engl.ztt); "Instructions for the STUD experiment were identical except for
## the stake sizes which were one-third", so 1, 2, ..., 7 euro against 0 or 8.
## One section of Part 2 and one decision in it were paid. RA, the authors'
## RISK_TOLERANCE, is the share of the 7 decisions in which the lottery was
## taken; choice = 7 RA, the number of sure amounts against which the lottery was
## taken (0 ... 7), filed as CEPL like Mahmoud2022.
##
## The general risk question was asked on a 1-7 scale (risiko), not the 0-10
## scale of the soep column, so it is not used.
##
## female: 1 = woman; alter = age in years.
df <- read_csv("Data/Kirchler_et_al_2018/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 432, all(round(7 * df$RA, 6) %in% 0:7))

df <- df %>%
  transmute(subject = subjectid,
            task = "CEPL",
            choice = round(7 * RA),
            age = alter,
            gender = female,
            country = "Austria",
            city = "Innsbruck",
            bibkey = "Kirchler2018",
            paper = "Kirchler et al. 2018")

## the map is drawn by country; the coordinates are those of the university
df$lattitude = '47.2632'
df$longitude = '11.3845'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kirchler_et_al_2018/formatted_dataset.csv")
