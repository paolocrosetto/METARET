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
## as switching more than once or choosing A in row 10 are out of the
## statistics and kept for the download only, with inconsistent = 1 and one row
## per switch to B (Data/inconsistent_rows.R). Rebuilt from the ten choices,
## the rule also catches 7 subjects the authors' flag misses: they took A in
## all ten rows, including row 10, where B pays 7.70 for sure (counted until
## 29.10.2026). 71 in all.
## choice = number of B choices (10 - Safe = 11 - the row where B starts). No
## demographics in the package.
df <- read_csv("Data/Duffy_Jiang_Xie_2024/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
B <- 1 - as.matrix(select(df, Choice1:Choice10))
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0))
stopifnot(all(df$inconsistent[df$Violate == 1] == 1), sum(df$inconsistent) == 71)
df <- df %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age = NA_real_,
            gender = NA_real_,
            country = "Canada") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Duffy2024",
         paper = "Duffy et al. 2024")

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
df %>% write_csv("Data/Duffy_Jiang_Xie_2024/formatted_dataset.csv")
