#### Baier, A., Davis, B. & Jaber-Lopez, T. (2024). Gender, choice of task, and
#### the effect of feedback on competition: An experiment. Journal of Economic
#### Psychology, 103, 102743. https://doi.org/10.1016/j.joep.2024.102743
#### Data: OSF, https://osf.io/gzynj (Replication material/Raw Data/*.xls)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## z-Tree experiment in the EconLab of the University of Innsbruck, October and
## November 2017, 360 students recruited through HROOT (180 men and 180 women;
## mean age 23.0, sd 3.81). Three between-subject feedback treatments.
## original_dataset.csv is built from the 30 session files in Raw Data, keeping
## the session and subject numbers, the treatment, the bomb task answer, the
## questionnaire gender and age.
##
## Task (stage 6): the bomb risk elicitation task of Crosetto and Filippin
## (2013). The subject picks how many of 100 boxes to collect; one box hides a
## bomb that destroys everything collected. choice = number of boxes.
##
## gender follows the authors' codebook: 1 = male becomes 0, 2 = female becomes
## 1, and the 6 subjects who gave neither answer are left missing.
df <- read_csv("Data/Baier_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "BRET",
            choice = bomb,
            age,
            gender = case_when(gender == 1 ~ 0, gender == 2 ~ 1, TRUE ~ NA_real_),
            country = "Austria",
            city = "Innsbruck")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Baier2024",
         paper = "Baier et al. 2024")

df$lattitude = '47.2654'
df$longitude = '11.3927'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Baier_et_al_2024/formatted_dataset.csv")
