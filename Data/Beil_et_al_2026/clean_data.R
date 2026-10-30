#### Beil, D., Duenyas, I., Leider, S., Li, J. & Qi, A. (2026). Human Decision
#### Making in Dynamic Resource Allocation. Management Science, 72.
#### https://doi.org/10.1287/mnsc.2021.01097
#### Data: Management Science replication package (diagnostic-task files, z-Tree)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online z-Tree sessions with students of a large public university in the US
## Midwest. The paper calls the risk task Holt-Laury, but the z-Tree programs
## show a certainty-equivalent list: in decision k a fixed 500 + 500k ECU against
## a lottery paying 6,000 or 1,000 ECU with probability 1/2 (k = 1 ... 10, the
## same in all five treatments). It is filed as CEPL.
## original_dataset.csv keeps the treatment and the ten choices (1 = fixed,
## 2 = lottery) with the authors' safe count; subject and session ids are
## dropped and subjects are row numbers. Only subjects who take the lottery in
## the first rows and the fixed amount after enter the statistics, and the
## 1,000 ECU row, where the fixed amount is dominated, must show the lottery.
## choice = number of lottery choices, i.e. the row where the fixed amount
## starts minus 1 (10 - the authors' safe count). No demographics in the package.
## The others are kept for the download only with inconsistent = 1, one row per
## switch to the fixed amount (Data/inconsistent_rows.R).
df <- read_csv("Data/Beil_et_al_2026/original_dataset.csv", show_col_types = FALSE)

B <- df %>% select(RiskChoice1:RiskChoice10) %>% as.matrix()
consistent <- apply(B, 1, function(x) all(diff(x) <= 0)) & B[, 1] == 2
stopifnot(all(rowSums(B[consistent, ] == 2) == 10 - df$RiskNumSafe[consistent]))

source("Data/inconsistent_rows.R")
fixed <- (B == 1) * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(fixed)), function(i) switch_points(fixed[i, ])),
         inconsistent = as.numeric(!consistent)) %>%
  transmute(subject,
            task = "CEPL",
            points, inconsistent,
            age = NA_real_,
            gender = NA_real_,
            country = "United States") %>%
  expand_switches(function(k) if_else(is.na(k), 10, k - 1))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Beil2026",
         paper = "Beil et al. 2026")

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
df %>% write_csv("Data/Beil_et_al_2026/formatted_dataset.csv")
