#### Halim, E., Riyanto, Y. E., Roy, N. & Wang, Y. (2025). How dark trading harms
#### financial markets. The Economic Journal, 135, 1711-1733.
#### https://doi.org/10.1093/ej/ueaf007
#### Data: https://doi.org/10.5281/zenodo.14671457 (Datasets/processed data/subjects.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps one row per participant: 192 students at Nanyang
## Technological University, Singapore, 16 z-Tree sessions of 12 (paid in SGD).
## The z-Tree user ids are dropped; subjects are row numbers, sessions 1-16.
## The paper calls the risk task Holt-Laury, but the z-Tree program shows a
## probability-equivalent list: in rows 1-10, option A pays 1 SGD for sure and
## option B pays 3 SGD with probability 0, 0.1, ..., 0.9 (else 0). It pitches a
## sure amount against a lottery, so it is grouped with the CEPL tasks.
## The file keeps only the switching point the program recorded (RiskAversion):
## 1 = B already in row 1, k = 2..10 = A in row k - 1 and B in row k, 11 = A in
## all rows. choice = switching point. Row-by-row choices are not saved, so
## multiple switchers cannot be found (the program takes the first switch from A
## to B). The 3 subjects with 1 chose B at probability 0, a dominated choice, and
## are kept for the download only,
## with inconsistent = 1 (Data/inconsistent_rows.R).
## female: 1 = female, 0 = male (the authors' gender is 1 = male).
df <- read_csv("Data/Halim_et_al_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(sum(df$switch_point == 1) == 3)
df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = switch_point,
            inconsistent = as.numeric(switch_point == 1),
            age,
            gender = female,
            country = "Singapore")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Halim2025",
         paper = "Halim et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Halim_et_al_2025/formatted_dataset.csv")
