#### Bellemare, M. F., Lee, Y. N. & Just, D. R. (2020). Producer attitudes
#### toward output price risk: Experimental evidence from the lab and from the
#### field. American Journal of Agricultural Economics, 102(3), 806-825.
#### https://doi.org/10.1002/ajae.12004
#### Data: replication package BellemareLeeJustAJAEPriceRisk (risk_Jan2017.dta,
#### PriceRiskCodeSeptember2019.do)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Price-risk production game played by US college students in labs at Cornell
## (December 2014 and March 2015) and Minnesota (the "october" sessions), and
## in the field by farmers in Peru's Lima province. Along with the game subjects
## did the Holt and Laury (2002) list, with monotonic switching enforced:
## "Once a subject switches to B, the game ends."
##
## risk_Jan2017.dta is one row per subject and round; original_dataset.csv
## keeps one row per subject (134). `switch` is the row at which the subject
## switched to B: the do-file gives switch 1 the most risk-loving value and
## leaves out switch == 0, which the paper calls a switch point "mistakenly
## entered as zero -- an impossible value". Those 2 subjects are dropped; 132
## remain. With the first B in row s the subject made 11 - s B choices, the
## convention of the shared standard-HL block of generate_r.R.
##
## gender: the Cornell and Minnesota files store female (1 = woman), the Peru
## file stores male coded 1 = Male, 2 = Female; both become female 1. Age is
## recorded for the Peruvian farmers only.
df <- read_csv("Data/Bellemare_Lee_Just_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 134, all(df$switch_row %in% 0:10))

df <- df %>%
  filter(switch_row >= 1)

stopifnot(nrow(df) == 132)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = 11 - switch_row,
            gender = coalesce(female, male_code - 1),
            age,
            country = if_else(site == "Peru", "Peru", "United States"),
            city = '',
            bibkey = "BellemareLeeJust2020",
            paper = "Bellemare et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bellemare_Lee_Just_2020/formatted_dataset.csv")
