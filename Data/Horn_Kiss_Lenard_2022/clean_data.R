#### Horn, D., Kiss, H. J. & Lenard, T. (2022). Gender differences in preferences of
#### adolescents: Evidence from a large-scale classroom experiment.
#### Journal of Economic Behavior and Organization, 194, 478-522.
#### https://doi.org/10.1016/j.jebo.2021.12.015
#### Data: https://data.mendeley.com/datasets/96jt894stz (Horn-Kiss-Lenard2021.dta);
#### the same data are used by Lenard, Horn & Kiss (2024), J. Econ. Psychology 102746.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps class, school, track, the risk task, gender and age
## from the authors' file (one row per student): 1108 Hungarian secondary-school
## students (53 classes in 9 schools), z-Tree classroom experiment, paid in HUF
## (one task drawn for payment). No names; the anonymous student ids are replaced
## by row numbers.
## Risk task 4 is the bomb risk elicitation task (Crosetto and Filippin 2013) with
## 100 boxes: risk = number of boxes collected. The authors set the 8 choices of
## 100 boxes (a sure zero) to missing; those rows are dropped.
## female: 1 = girl, 0 = boy; age is given in months and is turned into years.
df <- read_csv("Data/Horn_Kiss_Lenard_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject,
            task = "BRET",
            choice = risk,
            age = round(age_months / 12, 1),
            gender = female,
            country = "Hungary")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Horn2022",
         paper = "Horn et al. 2022")

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
df %>% write_csv("Data/Horn_Kiss_Lenard_2022/formatted_dataset.csv")
