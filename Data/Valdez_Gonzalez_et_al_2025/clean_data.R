#### Valdez Gonzalez, N. I., Brown, A. L. & Palma, M. A. (2025). Social-benefits
#### stigma and subsequent competitiveness.
#### Economic Inquiry, 63, 903-925. https://doi.org/10.1111/ecin.13293
#### Data: openICPSR, https://doi.org/10.3886/E217164V2 (downloaded by hand; the
#### 5 GB of facial-expression sensor recordings in the package are not needed)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' full_sample.dta (oTree export,
## one row per subject): 276 students, 31 sessions in Fall 2019 at the Human
## Behavior Lab, Texas A&M University. Only the session (renumbered), sex, study
## year and the ten Holt-Laury answers were kept; participant codes, labels and
## IP addresses were dropped.
## Holt-Laury list (oTree app "mpl", config.py): the standard table, A = 2.00 / 1.60,
## B = 3.85 / 0.10, one row per page; hl_k = "A" or "B". choice = number of B
## choices (11 - the row where B starts). Check: the mean number of safe
## choices is 5.14, as in the paper. Inconsistent (counted until 29.10.2026):
## 76 subjects switch more than once and some keep A in row 10, where B pays
## 3.85 for sure, 81 in all; kept for the download only, with inconsistent = 1
## and one row per switch to B (Data/inconsistent_rows.R).
## sex: "F" = 1, "M" = 0. Age was not asked (only the year of study).
df <- read_csv("Data/Valdez_Gonzalez_et_al_2025/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
B <- (as.matrix(select(df, starts_with("hl_"))) == "B") * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            gender = case_when(sex == "F" ~ 1, sex == "M" ~ 0, TRUE ~ NA_real_),
            country = "United States",
            city = "College Station") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(n_distinct(df$subject[df$inconsistent == 1]) == 81)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "ValdezGonzalez2025",
         paper = "Valdez Gonzalez et al. 2025")

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
df %>% write_csv("Data/Valdez_Gonzalez_et_al_2025/formatted_dataset.csv")
