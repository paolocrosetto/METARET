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
## the first rows and the fixed amount after are kept, and the 1,000 ECU row,
## where the fixed amount is dominated, must show the lottery.
## choice = number of lottery choices. No demographics in the package.
df <- read_csv("Data/Beil_et_al_2026/original_dataset.csv", show_col_types = FALSE)

B <- df %>% select(RiskChoice1:RiskChoice10) %>% as.matrix()
consistent <- apply(B, 1, function(x) all(diff(x) <= 0)) & B[, 1] == 2

df <- df %>%
  filter(consistent) %>%
  transmute(subject,
            task = "CEPL",
            choice = 10 - RiskNumSafe,
            age = NA_real_,
            gender = NA_real_,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Beil2026",
         paper = "Beil et al. 2026")

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
df %>% write_csv("Data/Beil_et_al_2026/formatted_dataset.csv")
