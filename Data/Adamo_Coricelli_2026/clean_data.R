#### Adamo, T. & Coricelli, G. (2026).
#### Deliberate stochastic choice: A mouse-tracking experiment.
#### Journal of Economic Behavior and Organization, 248, 107632. https://doi.org/10.1016/j.jebo.2026.107632

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Data.dta from the replication package, one row per subject (49 students,
## lab, University of Southern California, Nov-Dec 2023). Only the subject id,
## the two investment decisions, age and gender were copied here (nationality
## and the mouse-tracking variables were left out).
## Phase II is a Gneezy-Potters / Charness-Gneezy task: 100 tokens, invest x,
## with 50% the investment pays 2.5 times x, with 50% it is lost.
## risk = tokens invested. The second version (compound) reaches the 50%
## through a compound lottery and is not used.
## Note: the payment description of the paper mentions only draws from phases
## I, III and IV, so this task may not have been paid.
## gender: 1 = female (25 females in the paper and 25 ones in the data), 2 = male.
df <- read_dta("Data/Adamo_Coricelli_2026/original_dataset.dta")

df <- df %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = as.numeric(risk),
            age = as.numeric(age),
            gender = case_when(gender == 1 ~ 1, gender == 2 ~ 0, TRUE ~ NA_real_),
            country = "United States",
            city = "Los Angeles")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Adamo2026",
         paper = "Adamo and Coricelli 2026")

## no lab coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Adamo_Coricelli_2026/formatted_dataset.csv")
