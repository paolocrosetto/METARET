#### Ranehill, E. & Weber, R. A. (2022). Gender preference gaps and voting for redistribution.
#### Experimental Economics, 25, 845-875. https://doi.org/10.1007/s10683-021-09741-8
#### Data: https://doi.org/10.17605/OSF.IO/YNZ8X

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Data_Ranehill_Weber_2021.dta, one row per subject and period; one row per
## subject kept: 415 students of the University of Zurich and ETH, lab
## experiment in Zurich, 2015. Only the variables used below were copied.
## In Part 1, before any treatment, subjects invested part of 100 ECU in a risky
## investment that returned 2.5 times the amount with 50% and was lost
## otherwise (Gneezy-Potters / Charness-Gneezy). riskyinvestment = ECU invested.
## surveyrisk = general willingness to take risks (Dohmen et al., 0-10) = SOEP.
## female: 1 = female.
df <- read_csv("Data/Ranehill_Weber_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = riskyinvestment,
            soep = surveyrisk,
            age = age,
            gender = female,
            country = "Switzerland",
            city = "Zurich")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Ranehill2022",
         paper = "Ranehill and Weber 2022")

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
df %>% write_csv("Data/Ranehill_Weber_2022/formatted_dataset.csv")
