#### Alfonso, A., Branas-Garza, P., Jorrat, D., Prisse, B. & Vazquez-De Francisco, M. J.
#### (2025). The baking of preferences throughout the
#### high school. Journal of Behavioral and Experimental Economics, 118, 102396.
#### https://doi.org/10.1016/j.socec.2025.102396
#### Data: TeensLab dataset, https://github.com/teenslab/datateenslab
#### (BBDD_20240314.dta; also Zenodo https://doi.org/10.5281/zenodo.13720111)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## TeensLab lab-in-the-field experiment run as a class activity in Spanish schools
## (2021-2023). The paper uses the high-school (ESO, grades 7-10) students of 22
## schools; in the dataset these are stage == 2 (22 schools, 5,003 students), of
## whom 4,816 answered the whole risk task (the paper reports 4,830 participants).
## Students from elementary school, sixth form and vocational training in the same
## dataset are not part of the paper and are not added. original_dataset.csv keeps
## grade, year, the six risk choices, the authors' consistency flag, sex and age;
## user, school and class ids are dropped and subjects are row numbers.
##
## Risk task ("gumball machine", Holt-Laury in six rows, HYPOTHETICAL payments
## because the participants are minors): option A pays 10 or 8 EUR, option B 20 or
## 2 EUR, the high prize with probability 0, 0.2, ..., 1 in rows 1-6 (screenshots
## in the repository). prob_k = 1 for option B.
## In the statistics: the 3,834 students the authors flag as consistent
## (cns_risk == 1: A in row 1, B in row 6, no switching back); choice = number
## of B choices (1 to 5), i.e. 7 - the row where B starts. The other 982 (B in
## row 1, where it pays 2 EUR for sure against 8, A in row 6, where it pays 10
## for sure against 20, or switching back) are kept for the download only with
## inconsistent = 1, one row per switch to B (Data/inconsistent_rows.R); the
## same rule rebuilt here gives the authors' flag for all 4,816.
## female: the authors' variable (gender 'other' or missing = NA).
df <- read_csv("Data/Alfonso_et_al_2025/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
B <- as.matrix(df[paste0("prob", 1:6)])
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 1] == 1 | B[, 6] == 0))
stopifnot(all(df$inconsistent == 1 - df$cns_risk))

df <- df %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age,
            gender = female,
            country = "Spain") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 7 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Alfonso2025",
         paper = "Alfonso et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Alfonso_et_al_2025/formatted_dataset.csv")
