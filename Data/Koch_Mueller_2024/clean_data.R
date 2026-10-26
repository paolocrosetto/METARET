#### Koch, C. & Mueller, C. (2024). Tax amnesties and the insurance effect: An
#### experimental study. Journal of Behavioral and Experimental Economics, 108,
#### 102130. https://doi.org/10.1016/j.socec.2023.102130
#### Data: Tax_Amnesty_data.dta and Replication_File.do of the replication material

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Tax declaration game, "120 subjects participated in the experiment which took
## place at the mLab at Mannheim University", 12 sessions (z-Tree, ORSEE); the
## session codes date them 17-24 October 2013. "After the experiment, measures
## of risk aversion were collected, as in Holt and Laury (2002)": risk_aversion,
## "ranging from 0 to 10", is the number of safe choices (mean 5.79 in the
## paper's summary table, as in the data).
##
## The file holds the count only, so multiple switchers cannot be told apart.
## The 3 subjects with 10 safe choices chose A even in the last row, where B
## pays 3.85 for sure, and are dropped. choice = number of B choices = 10 -
## safe choices, the convention of the shared standard-HL block of generate_r.R.
## gender: male 1 flipped to the site's female 1.
df <- read_csv("Data/Koch_Mueller_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 120, all(df$n_safe %in% 0:10))

df <- df %>%
  filter(n_safe <= 9)

stopifnot(nrow(df) == 117)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = 10 - n_safe,
            gender = 1 - male,
            age,
            bibkey = "Koch2024",
            paper = "Koch and Muller 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## mLab, University of Mannheim; the map shows only the country
df$country = 'Germany'
df$city = 'Mannheim'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Koch_Mueller_2024/formatted_dataset.csv")
