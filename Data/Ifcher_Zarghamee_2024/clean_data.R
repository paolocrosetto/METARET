#### Ifcher, J. & Zarghamee, H. (2024). Does Decision Making for Others Close the
#### Gender Gap in Competition? Management Science, 70.
#### https://doi.org/10.1287/mnsc.2023.4861
#### Data: Management Science replication package (analytical_dataset.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 324 students at Columbia University and Santa Clara University, fall 2019.
## Task 5 (paper, section 3.7): a fixed payment of USD 0, 1, ..., 10 against a
## lottery paying 10 or 0 with probability 1/2. The authors' file holds IP
## addresses and MTurk fields; original_dataset.csv keeps only session,
## treatment, age, sex and one 0/1 column per row (1 = fixed payment chosen), and
## the authors' file is not copied to raw_repository. Subjects are row numbers.
## As in the authors' do-file, subjects who take USD 0 for sure, take the lottery
## against USD 10 (both dominated), or go back from the fixed payment to the
## lottery are out of the statistics; they are kept for the download only, with
## inconsistent = 1 and one row per switch to the fixed payment
## (Data/inconsistent_rows.R; 11 if it was never taken).
## choice = the first fixed payment taken (1-10): the certainty equivalent lies
## between choice - 1 and choice.
df <- read_csv("Data/Ifcher_Zarghamee_2024/original_dataset.csv", show_col_types = FALSE)

Fx <- df %>% select(fixed_0:fixed_10) %>% as.matrix()
consistent <- apply(Fx, 1, function(x) all(diff(x) >= 0)) & Fx[, 1] == 0 & Fx[, 11] == 1

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(Fx)), function(i) switch_points(Fx[i, ])),
         inconsistent = as.numeric(!consistent)) %>%
  transmute(subject,
            task = "CEPL",
            points, inconsistent,
            age,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            country = "United States") %>%
  ## column k is a fixed payment of k - 1 USD
  expand_switches(function(k) if_else(is.na(k), 11, k - 1))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Ifcher2024",
         paper = "Ifcher and Zarghamee 2024")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Ifcher_Zarghamee_2024/formatted_dataset.csv")
