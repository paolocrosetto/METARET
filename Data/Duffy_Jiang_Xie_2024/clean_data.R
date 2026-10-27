#### Duffy, J., Jiang, J. H. & Xie, H. (2024). Pricing Indefinitely Lived Assets:
#### Experimental Evidence. Management Science, 70.
#### https://doi.org/10.1287/mnsc.2021.03059
#### Data: Management Science replication package (MatlabPrograms/DJX_HL.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Asset-market sessions at the CIRANO lab, Montreal, with university students.
## Before trading, subjects did a Holt-Laury list at twice the original stakes:
## A pays USD 4 or 3.20, B pays 7.70 or 0.20, the high prize with probability
## k/10 in row k (instructions, Part I). original_dataset.csv is the authors' HL
## sheet: session, the safe-choice count, their violation flag and the ten
## choices (1 = A); subjects are row numbers. The 64 subjects the authors flag
## as switching more than once or choosing A in row 10 are dropped.
## choice = number of B choices (10 - Safe). No demographics in the package.
df <- read_csv("Data/Duffy_Jiang_Xie_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(Violate == 0) %>%
  transmute(subject,
            task = "HL",
            choice = 10 - Safe,
            age = NA_real_,
            gender = NA_real_,
            country = "Canada")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Duffy2024",
         paper = "Duffy et al. 2024")

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
df %>% write_csv("Data/Duffy_Jiang_Xie_2024/formatted_dataset.csv")
