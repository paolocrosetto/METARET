#### Siddique, A. & Vlassopoulos, M. (2020). Competitive preferences and
#### ethnicity: Experimental evidence from Bangladesh. The Economic Journal.
#### https://doi.org/10.1093/ej/uez063
#### Data: the journal's replication files (uez063_replication_files:
#### Main_data.dta / .csv, do-files, Readme), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment "in the summer of 2016 in six different
## multi-ethnic villages in the Rajshahi district of rural Bangladesh", with "252
## male adults of equal proportion" Bengali and Santal; one row each (id).
##
## Task: Gneezy and Potters (1997), right after the competition game: "bet a
## proportion [0, 100] of their endowment of 100 units, or 20 Taka, into a
## lottery ... fifty-fifty chance ... Subjects received six times the amount
## invested if there was a head but lost the bet money if there was a tail."
## risk_m = taka invested (2 ... 20; 183 of 252 bet everything).
##
## All participants are men. age in years.
df <- read_csv("Data/Siddique_Vlassopoulos_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 252, all(df$risk_m >= 0 & df$risk_m <= 20))

df <- df %>%
  transmute(subject = id,
            task = "IG",
            choice = risk_m,
            age,
            gender = 0,
            country = "Bangladesh",
            city = "Rajshahi",
            bibkey = "Siddique2020",
            paper = "Siddique and Vlassopoulos 2020")

## the map is drawn by country; the coordinates are those of the district town
## (the villages are not named)
df$lattitude = '24.3745'
df$longitude = '88.6042'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Siddique_Vlassopoulos_2020/formatted_dataset.csv")
