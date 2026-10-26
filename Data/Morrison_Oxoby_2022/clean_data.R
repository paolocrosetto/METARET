#### Morrison, W. G. & Oxoby, R. J. (2022). Asset integration and risk-taking in the
#### laboratory. Canadian Journal of Economics, 55(3), 1460-1479.
#### https://doi.org/10.1111/caje.12615
#### Data: https://doi.org/10.5683/SP3/HHFRH0 (MO Data CJE Sept21.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two-session lab experiment in Canada (z-Tree; the authors are at Calgary and
## Wilfrid Laurier, the lab is not named): 259 participants, 120
## in the control group and 139 in the asset-integration ("returning") group, who
## were paid their quiz earnings in session 1 and brought the cash back to stake
## it in session 2. Everyone earned 20 CAD in the quiz (paper, section 4).
## original_dataset.csv keeps the group and the 20 choices of each participant
## (1 = option B); the file has no demographics.
## Session 1 was a hypothetical Holt-Laury table (200/160 vs 385/10); it is not
## used. The incentivised table of session 2 (paper, Table 2) is used: option A =
## 20 CAD for sure, option B = 35 CAD with probability k/10, else 3.50 CAD (Table 2
## prints the low prize as 10 CAD, but its expected-value column and the
## instructions give 3.50). A sure amount against a lottery whose probability
## moves along the list: a probability-equivalent list, grouped with CEPL (as
## Halim2025). choice = number of B choices.
## Kept: subjects who never go back from B to A and take B in row 10 (35 CAD for
## sure). Dropped: 2 with multiple switches and 2 who took 20 CAD over 35 CAD.
df <- read_csv("Data/Morrison_Oxoby_2022/original_dataset.csv", show_col_types = FALSE)

B <- df %>% select(inc1:inc10) %>% as.matrix()
consistent <- apply(B, 1, function(x) all(diff(x) >= 0)) & B[, 10] == 1

df <- df %>%
  mutate(n_B = rowSums(B)) %>%
  filter(consistent) %>%
  transmute(subject,
            task = "CEPL",
            choice = n_B,
            country = "Canada")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Morrison2022",
         paper = "Morrison and Oxoby 2022")

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
df %>% write_csv("Data/Morrison_Oxoby_2022/formatted_dataset.csv")
