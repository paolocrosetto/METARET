#### Aydogan, I., Berger, L. & Theroude, V. (2024). Pay all subjects or pay only some?
#### An experiment on decision-making under risk and ambiguity.
#### Journal of Economic Psychology, 104, 102757. https://doi.org/10.1016/j.joep.2024.102757
#### Data: https://osf.io/r5ws9/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps id, treatment, the CE of the risky bet, gender and
## age from the authors' final file db.dta (182 students, Lille). Between-subject
## treatments: all subjects paid for one choice (treatment_between = 0) or only
## 10% of them (= 1); the paper finds no difference, so both are kept.
## Only the risk situation is used (CE_R100): a bet paying 20 EUR if the chosen
## colour is drawn from an urn of 100 balls, 50 red and 50 blue, else 0. The CE
## comes from a list of 22 choices between the bet and a sure 0, 0.5, 1.5, 2.5,
## ..., 19.5, 20 EUR. CE_R100 is the midpoint of the switching interval
## (0.25, 1, 2, ..., 19, 19.75); it is missing for the 4 subjects without a
## single switch. choice = number of the CE interval (0 ... 20):
## 0 = [0, 0.5], i = [i - 0.5, i + 0.5], 20 = [19.5, 20].
## The ambiguous and compound-risk bets are not risk tasks for this site.
## Female1Male0: 1 = woman, 0 = man.
df <- read_csv("Data/Aydogan_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(CE_R100)) %>%
  transmute(subject = id,
            task = "CEPL",
            choice = case_when(CE_R100 == 0.25 ~ 0,
                               CE_R100 == 19.75 ~ 20,
                               TRUE ~ CE_R100),
            age = Age,
            gender = Female1Male0,
            country = "France",
            city = "Lille")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Aydogan2024",
         paper = "Aydogan et al. 2024")

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
df %>% write_csv("Data/Aydogan_et_al_2024/formatted_dataset.csv")
