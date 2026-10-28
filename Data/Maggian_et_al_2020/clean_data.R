#### Maggian, V., Montinari, N. & Nicolò, A. (2020). Do quotas help women to
#### climb the career ladder? A laboratory experiment. European Economic Review,
#### 123, 103390. https://doi.org/10.1016/j.euroecorev.2020.103390
#### Data: Mendeley Data 10.17632/2hwv33vw5h (DataExperimentGenderCareerLadder.xls)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 384 undergraduates (192 women) at GATE-LAB, Lyon, 16 sessions in
## September-December 2016. In stage 5 they played the bomb risk elicitation
## task (Crosetto and Filippin 2013) with 100 boxes. The file is an unlabelled
## z-Tree export with one row per subject and period; the BRET answer
## (choice...103, boxes collected) is the same in all five periods, so period 1
## is kept. The coding was checked against the paper: Gender 0 gives the
## women's BRET means by treatment in Table A2 (42.90, 43.94, 38.83, 44.81), so
## 0 = female; Year is the year of birth and age is 2016 - Year.
## original_dataset.csv keeps session, treatment, boxes, whether the bomb was
## collected, the gender code and the year of birth; subjects are row numbers.
df <- read_csv("Data/Maggian_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 384, sum(df$gender_code == 0) == 192,
          abs(mean(df$boxes[df$gender_code == 0]) - 42.620) < 0.01)

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = boxes,
            age = 2016 - birth_year,
            gender = if_else(gender_code == 0, 1, 0),
            country = "France",
            city = "Lyon",
            bibkey = "Maggian2020",
            paper = "Maggian et al. 2020")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '45.7640'
df$longitude = '4.8357'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Maggian_et_al_2020/formatted_dataset.csv")
