#### Tatarnikova, O., Duchene, S., Sentis, P. & Willinger, M. (2026). Portfolio
#### instability with SRI assets and investors' ranking feedback.
#### Quarterly Review of Economics and Finance, 110, 102208.
#### https://doi.org/10.1016/j.qref.2026.102208
#### Data: Mendeley Data https://doi.org/10.17632/tkrmcyhcrn.1
#### (Brown ranking 171224.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 306 students from the subject pool of the Experimental Economics Laboratory of
## the University of Montpellier (oTree): 129 in the baseline and 104 in the green
## ranking treatment (online, July 2020) and 73 in the brown ranking treatment
## (laboratory, March 2022). The 233 baseline and green students are the student
## sample of Tatarnikova et al. (2023, J. Econ. Dyn. Control 153, 104702); that
## paper's 153 financial professionals are not in this file and are not added.
## original_dataset.csv keeps treatment, boxes collected, sex and age; oTree
## participant numbers are dropped and subjects are row numbers.
## Risk task: bomb risk elicitation task (Crosetto and Filippin 2013) with 100
## boxes; choice = boxes collected (mean 39, as in the paper; one subject took all
## 100).
## gender: the file's gender is 0 for 167 subjects (55%), matching the paper's 55%
## women, so female = 1 - gender. Age = year of the session (2020 or 2022) minus
## year of birth (mean 24.4; the paper reports 26).
df <- read_csv("Data/Tatarnikova_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = boxes,
            age,
            gender = female,
            country = "France")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Tatarnikova2026",
         paper = "Tatarnikova et al. 2026")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Tatarnikova_et_al_2026/formatted_dataset.csv")
