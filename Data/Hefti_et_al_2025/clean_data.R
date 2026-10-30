#### Hefti, A., Heinke, S. & Schneider, F. (2025). Mental capabilities,
#### heterogeneous trading behaviour and performance in an experimental asset market.
#### The Economic Journal, 135, 2161-2191. https://doi.org/10.1093/ej/ueaf003
#### Data: https://doi.org/10.5281/zenodo.14604968 (Data/datacomplete_ej.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps one row per participant from the authors' panel:
## 672 students in Zurich, 42 asset markets of 16 traders (z-Tree, paid in CHF).
## The session names (dates and times) are replaced by market numbers 1-42 and the
## subjects by row numbers; mother tongue and nationality are not kept.
## Risk task (Online Appendix, decision screen): 20 rows, a sure amount of
## 0, 1, ..., 19 CHF (row k pays k - 1) against a coin flip paying 0 or 30 CHF.
## L1-L20 = 1 if the lottery was chosen in that row. A consistent subject takes the
## lottery in the first n rows and the sure amount after, so the certainty
## equivalent lies in [n - 1, n] CHF; choice = n.
## As the authors' LotteryIncons flag, subjects who switch more than once (38) are
## out of the statistics, and so are the 8 who took the sure 0 CHF over the
## lottery in row 1 (dominated). They are kept for the download only, with
## inconsistent = 1 and one row per switch to the sure amount
## (Data/inconsistent_rows.R); choice = that row minus 1.
## female: 1 = female, 0 = male.
df <- read_csv("Data/Hefti_et_al_2025/original_dataset.csv", show_col_types = FALSE)

L <- df %>% select(L1:L20) %>% as.matrix()
consistent <- apply(L, 1, function(x) all(diff(x) <= 0))

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(L)), function(i) switch_points(1 - L[i, ])),
         inconsistent = as.numeric(!(consistent & rowSums(L) > 0))) %>%
  transmute(subject,
            task = "CEPL",
            points, inconsistent,
            age,
            gender = female,
            country = "Switzerland") %>%
  expand_switches(function(k) if_else(is.na(k), 20, k - 1))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Hefti2025",
         paper = "Hefti et al. 2025")

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
df %>% write_csv("Data/Hefti_et_al_2025/formatted_dataset.csv")
