#### Chapman, J., Snowberg, E., Wang, S. W. & Camerer, C. (2025). Looming large or
#### seeming small? Attitudes towards losses in a representative sample.
#### Review of Economic Studies, 92, 2893-2922. https://doi.org/10.1093/restud/rdae093
#### Data: Zenodo, https://doi.org/10.5281/zenodo.11100753 (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv stacks two of the authors' original datasets, without case
## ids: the Main Sample (mainGenpopSample.dta, 1000 people, YouGov, representative
## of the US population) and the second student sample (studentSample2021.dta,
## 437 University of Pittsburgh undergraduates). Both were incentivized online
## surveys paid in points.
## Risk task: the first gain multiple price list (riskGainMPL1), sure amounts of
## points against a 50/50 lottery paying 5000 or 0 points. riskGainMPL1FirstRHSRow
## is the first row in which the sure amount was taken (2 ... 19), and the
## authors' riskGainMPLMin1 / Max1 give the CE interval of that row (steps of 250
## or 500 points). choice = that row. Row 2 is [-500, 0] (the lottery was refused
## even against nothing) and row 19 is [5000, 5500] (taken even against 5000 for
## sure). Both are dominated choices (0 for sure taken over a lottery of 5000 or
## 0, and that lottery kept against 5000 for sure), so since 29.10.2026 the 35 in
## row 2 and the 60 in row 19 are kept for the download only, with
## inconsistent = 1 (one row each, the list allows a single switch). The second gain list (4000/1000), the mixed and loss lists and the DOSE
## binary choices (loss aversion) are not used. The 32 main-sample respondents who
## failed an attention check are kept, as in the paper.
## gender (main sample only): male = 1 -> 0, male = 0 -> 1. The student file has
## no demographics.
df <- read_csv("Data/Chapman_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = row,
            inconsistent = as.numeric(row %in% c(2, 19)),
            switch_no = if_else(inconsistent == 1, 1, NA_real_),
            age,
            gender = 1 - male,
            country = "United States",
            city = if_else(sample == "students2021", "Pittsburgh", NA_character_))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chapman2025",
         paper = "Chapman et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)
stopifnot(sum(df$inconsistent) == 95)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chapman_et_al_2025/formatted_dataset.csv")
