#### Finger, R., Wuepper, D. & McCallum, C. (2023). The (in)stability of farmer
#### risk preferences.
#### Journal of Agricultural Economics, 74(1), 155-167. https://doi.org/10.1111/1477-9552.12496
#### Data: ETH Research Collection, https://www.research-collection.ethz.ch/handle/20.500.11850/588689
#### (grapedata, downloaded by hand; it was saved as RTF and converted back to CSV)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv holds the 210 Swiss grape growers who answered all ten
## rows of the Holt-Laury list in the 2018 online survey (grapedata.csv, year
## 2018), with canton, gender and year of birth. The fruit growers of the paper
## are in a separate dataset, not used here.
## Holt-Laury list, framed as a choice between two insecticides (Knapp et al.
## 2019, Data in Brief 24, 103920, figure 1): in scenario k insecticide A pays
## 105 or 84 CHF and B pays 200 or 6 CHF, the high return with probability k/10.
## 10% of participants were paid one random scenario. scenario_k: "A1" = A,
## "A2" = B; choice = number of B choices.
## The paper (footnote 5) removes subjects with multiple switches or no switch:
## 23 switch more than once and 26 never switch (13 always A, 13 always B),
## leaving 161 single switchers (the paper reports 17 removals for its pooled
## fruit and grape sample). The site's rule since 29.10.2026 differs only for
## the 13 always-B growers: B in row 1 is not dominated, so they enter the
## statistics with choice 10 (174 in all). The 23 multiple switchers and the 13
## always-A (A in row 10, where B pays 200 for sure, is dominated) are kept for
## the download only, with inconsistent = 1 and one row per switch to B
## (Data/inconsistent_rows.R).
## gender: "F" = 1, "M" = 0. Age = 2018 - year of birth (implausible years set
## to NA).
df <- read_csv("Data/Finger_et_al_2023/original_dataset.csv", show_col_types = FALSE)

b <- as.matrix(select(df, starts_with("scenario_"))) == "A2"
switches <- rowSums(b[, -1] != b[, -10])

stopifnot(sum(switches == 1) == 161)
source("Data/inconsistent_rows.R")
B <- b * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age = if_else(year_b >= 1920 & year_b <= 2000, 2018 - year_b, NA_real_),
            gender = case_when(gender == "F" ~ 1, gender == "M" ~ 0, TRUE ~ NA_real_),
            country = "Switzerland")
stopifnot(sum(df$inconsistent == 0) == 174, sum(df$inconsistent) == 36)
df <- df %>% expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Finger2023",
         paper = "Finger et al. 2023")

## online survey, and the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Finger_et_al_2023/formatted_dataset.csv")
