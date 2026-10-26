#### Büyükboyacı, M., Karagözoğlu, E. & Küçükşenel, S. (2025).
#### Earned entitlements and risky investments in bargaining: an experiment.
#### Experimental Economics, 28, 1041-1063. https://doi.org/10.1017/eec.2026.10047
#### Data: https://doi.org/10.17605/OSF.IO/5YMKP (OSF registration)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## gen_data/risksharing_raw_appended.dta (z-Tree, all 18 sessions appended), one
## row per subject: 216 students, Middle East Technical University (Ankara), March 2022.
## Only session, subject, treatment, the ten HL choices, age and gender were copied.
## Stage 4 is a Holt-Laury list: A 80/64, B 154/4 ECU (the standard list x 40,
## read from the paid lotteries l1/l2), so the standard bounds apply.
## choice1-choice10: 1 = A, 2 = B; choice = number of B choices (= 11 - lineswitched).
## The three bargaining treatments come before the risk task; all are kept.
## gender: "K" (kadin) = female, "E" (erkek) = male.
## Note: Buyukboyaci2026 (auctions, JEBO) uses the same lab in 2024; the samples
## cannot be matched, so some students may be in both.
df <- read_csv("Data/Buyukboyaci_et_al_2025_eec/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "HL",
            choice = rowSums(across(num_range("choice", 1:10)) == 2),
            age = age,
            gender = case_when(gender == "K" ~ 1, gender == "E" ~ 0, TRUE ~ NA_real_),
            country = "Turkey",
            city = "Ankara")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Buyukboyaci2025",
         paper = "Büyükboyacı et al. 2025")

## no coordinates added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buyukboyaci_et_al_2025_eec/formatted_dataset.csv")
