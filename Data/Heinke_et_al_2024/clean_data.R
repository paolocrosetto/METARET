#### Heinke, S., Olschewski, S. & Rieskamp, J. (2024).
#### Experiences, demand for risky investments, and implications for price dynamics.
#### Journal of Behavioral and Experimental Finance, 43, 100939. https://doi.org/10.1016/j.jbef.2024.100939

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Data_all_paper.csv from the replication package is one row per subject and
## trading period; only one row per subject with the individual measures was
## copied here (no IP addresses, which are in the raw oTree files).
## 128 students, WISO lab, University of Hamburg, 2019.
## Before the trading task subjects answered four multiple price lists
## (Online Supplementary Material, S.2); MPL_x = number of risky options chosen.
##  - MPL 1: 50% 500 ECU or 0  vs  a sure -50, 0, 50, ..., 550 ECU (13 rows)
##  - MPL 2: 50% 400 ECU or 0  vs  a sure -50, 0, 50, ..., 450 ECU (11 rows)
##  - MPL 3 and 4: two 50/50 lotteries (Andersson et al. 2016 style), no
##    METARET category.
## MPL 1 is used as the CEPL measure (one CEPL per subject; MPL 2 is the same
## format and is not added to avoid two CEPL rows per subject).
## female: 1 = female, 0 = male, NA = other (2 subjects).
## SOEP_general and SOEP_finance are on 0-10.
df <- read_csv("Data/Heinke_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "CEPL",
            choice = MPL_1,
            soep = SOEP_general,
            soep_financial = SOEP_finance,
            age = as.numeric(Age),
            gender = as.numeric(female),
            country = "Germany",
            city = "Hamburg")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Heinke2024",
         paper = "Heinke et al. 2024")

## lab coordinates not added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Heinke_et_al_2024/formatted_dataset.csv")
