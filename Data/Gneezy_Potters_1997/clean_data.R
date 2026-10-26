#### Gneezy, U. & Potters, J. (1997). An experiment on risk taking and evaluation periods.
#### Quarterly Journal of Economics, 112(2), 631-645. https://doi.org/10.1162/003355397555217
#### Data: from the collection of Harrison and Rutström (2008), "Risk Aversion in the
#### Laboratory" (CEAR, https://cear.gsu.edu/files/2016/07/Risk-Aversion-in-the-Laboratory.zip)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## GPdata.dta, one row per subject (83 students, CREED lab, Amsterdam).
## Nine rounds; in each round 200 cents are given and x cents are bet: with
## probability 1/3 the bet gains 2.5 times x, with 2/3 it is lost.
## freq: 1 = high frequency (H: decide and see the outcome every round),
##       3 = low frequency (L: one bet for three rounds at a time).
## Only H, round 1 (x1, before any feedback) is kept: a single
## Gneezy-Potters gamble, as for Schwaiger2025 and Hueber2022.
## No demographics in the file.
df <- read_csv("Data/Gneezy_Potters_1997/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(freq == 1) %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = x1,
            country = "Netherlands",
            city = "Amsterdam")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Gneezy1997",
         paper = "Gneezy and Potters 1997")

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
df %>% write_csv("Data/Gneezy_Potters_1997/formatted_dataset.csv")
