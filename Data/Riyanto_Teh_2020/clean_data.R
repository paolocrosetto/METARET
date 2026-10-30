#### Riyanto, Y. E. & Teh, T.-H. (2020). Highly flexible neighborhood promotes
#### efficient coordination: Experimental evidence. European Economic Review, 129,
#### 103521. https://doi.org/10.1016/j.euroecorev.2020.103521
#### Data: the journal's supplementary zip (Data - Individual Effort Choice.dta,
#### code_Experiment.ztt, do-files) and Mendeley Data 10.17632/hjmjwjyzsh, kept in
#### raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 240 undergraduates of Nanyang Technological University, Singapore: 120 in June
## 2016 and 120 in March 2020 (Appendix C). The individual data has one row per
## subject and period; original_dataset.csv keeps one row per subject.
##
## Task, read off the z-Tree program (code_Experiment.ztt, "Stage 3 Risk
## elicitation"): ten rows, "Option A: You get a reward of 20 with certainty" or
## "Option B: ... 60 with a p% chance and a reward of 0" otherwise, p = 0, 10, ...,
## 90 down the rows; only one switch from A to B is allowed and one row is paid.
## So it is a probability-equivalent list, filed as CEPL like Halim2019.
## RiskPref (0-10) is the authors' count; neither the paper nor the files say of
## which option. It is read as the number of B (risky) choices: then only 2 of 240
## took B even at a 0% chance (the dominated choice), against 8 with the other
## reading, and the name is a preference for risk. Those 2 are kept for the
## download only, with inconsistent = 1 (Data/inconsistent_rows.R).
## Rechecked 28.10.2026: the z-Tree program stores only Choice[1..10] (1 = A,
## 2 = B) and computes no count; the line choices are published nowhere (the
## Mendeley file's Risk column equals RiskPref for all 200 matched subjects).
## RiskPref correlates weakly positively with choosing stag, the risky action of
## the coordination game (Spearman 0.05, p = 0.43), the sign the B reading
## predicts. Not proven, so the authors are asked to confirm.
## choice = RiskPref; the number of A choices is 10 - choice.
##
## Gender: 1 = woman (105 of 240, the paper's "around 44%"); Age in years.
df <- read_csv("Data/Riyanto_Teh_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 240, all(df$RiskPref %in% 0:10), sum(df$Gender == 1) == 105)

stopifnot(sum(df$RiskPref == 10) == 2)
df <- df %>%
  transmute(subject = SubjectID,
            task = "CEPL",
            choice = RiskPref,
            inconsistent = as.numeric(RiskPref == 10),
            age = Age,
            gender = Gender,
            country = "Singapore",
            city = "Singapore",
            bibkey = "Riyanto2020",
            paper = "Riyanto and Teh 2020")

## the map is drawn by country; the coordinates are those of the university
df$lattitude = '1.3483'
df$longitude = '103.6831'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Riyanto_Teh_2020/formatted_dataset.csv")
