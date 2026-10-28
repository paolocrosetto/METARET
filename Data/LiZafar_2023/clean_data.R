#### Li, C. H. & Zafar, B. (2023). Ask and you shall receive? Gender differences
#### in regrades in college. American Economic Journal: Economic Policy.
#### https://doi.org/10.1257/pol.20210053
#### Data: the AEA replication package (DataCode: experiment.dta, the authors'
#### do-files), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "563 CSU undergraduate students participated in the online experiment during
## April-May 2019" (oTree; Colorado State University, Fort Collins), one row each
## in experiment.dta.
##
## Task 1: "Following Eckel and Grossman (2008), we ask participants to choose
## their most favorable option from the following five lottery choices: 50%
## chance of $2 and 50% chance of $2; $3 / $1.50; $4 / $1; $5 / $0.5; $6 / $0
## ... participants are paid according to their lottery choice." The file keeps
## only the authors' CRRA midpoint, riskaversion = 2, 1.335, 0.525, 0.29, 0.2 for
## options 1 to 5 (rho > 2, 0.67-2, 0.38-0.67, 0.2-0.38, < 0.2), which gives the
## option back exactly; eg_choice. The menu is the five-option Eckel-Grossman one
## of Crosetto2016, so the same bounds apply.
##
## std_female: 1 = woman. Age is not in the file.
df <- read_csv("Data/LiZafar_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 563, all(df$eg_choice %in% 1:5))

df <- df %>%
  transmute(subject = row,
            task = "EG",
            choice = eg_choice,
            age = NA_real_,
            gender = std_female,
            country = "United States",
            city = "Fort Collins",
            bibkey = "LiZafar2023",
            paper = "Li and Zafar 2023")

## the map is drawn by country; the coordinates are those of the university's city
df$lattitude = '40.5853'
df$longitude = '-105.0844'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/LiZafar_2023/formatted_dataset.csv")
