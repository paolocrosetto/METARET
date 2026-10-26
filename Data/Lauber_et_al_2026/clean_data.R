#### Lauber, A., March, C. & Sahm, M. (2026). Three-player round-robin tournaments in the
#### lab: Lottery contests vs. all-pay auctions.
#### Journal of Behavioral and Experimental Economics, 124, 102605. https://doi.org/10.1016/j.socec.2026.102605
#### Data: https://data.mendeley.com/datasets/j6wjzgd8sr/1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## LauberMarchSahm_RRT-LCvsAPA_Data.xlsx (sheet Dataset) is one row per subject and
## period; one row per subject was kept (138 students, BLER lab, University of
## Bamberg, 2016-2017, two treatments of 69).
## Part 1 risk task (footnote 6): ten rows, a sure 180 points against a lottery
## paying 400 points with probability 0.1, 0.2, ..., 1.0, otherwise 0; one row paid.
## riskDecisions[k]: 1 = safe, 2 = risky. As for Chlass2026 (sure amount against
## a lottery with a rising probability), this is coded as CEPL;
## choice = number of risky choices = 10 - SafeChoices.
## The self-assessed risk question is on a 1-7 scale (not SOEP) and is not used.
df <- read_csv("Data/Lauber_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "CEPL",
            choice = 10 - SafeChoices,
            age = as.numeric(Age),
            gender = as.numeric(Female),
            country = "Germany",
            city = "Bamberg")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Lauber2026",
         paper = "Lauber et al. 2026")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Lauber_et_al_2026/formatted_dataset.csv")
