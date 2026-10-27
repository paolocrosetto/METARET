#### Agranov, M. & Buyalskaya, A. (2022). Deterrence Effects of Enforcement
#### Schemes: An Experimental Study. Management Science, 68, 3573-3589.
#### https://doi.org/10.1287/mnsc.2021.4036
#### Data: Management Science data appendix (Data/main.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 424 students at the UCSD Experimental Economics Laboratory, March-June 2019.
## Risk attitudes come from two investment tasks with 200 points (USD 2): in the
## first the risky project succeeds with probability 0.5 and pays 2.5 points per
## point invested, in the second it succeeds with probability 0.4 and pays 3.
## Only the first, the standard Gneezy-Potters version, is used; risk2 is kept
## in original_dataset.csv. The session and participant codes are dropped and
## subjects are row numbers. choice = points invested in task 1 (0-200).
## The package has no age or sex.
df <- read_csv("Data/Agranov_Buyalskaya_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = risk1,
            age = NA_real_,
            gender = NA_real_,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Agranov2022",
         paper = "Agranov and Buyalskaya 2022")

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
df %>% write_csv("Data/Agranov_Buyalskaya_2022/formatted_dataset.csv")
