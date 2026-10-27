#### Zhao, S. (2026). Pricing skewed assets in multi-asset experimental markets.
#### Games and Economic Behavior, 155, 107-148.
#### https://doi.org/10.1016/j.geb.2025.10.005
#### Data: GitHub, https://github.com/fenixzhao1/data-salience_market
#### (df_mpl/*.csv, data_survey.csv and, for gender, df_bdm/df_call/df_mkt)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory asset market experiment, 512 subjects in nine market treatments,
## run at Dongbei University of Finance and Economics in Dalian (344) and at
## the University of California, Santa Cruz (168). Before the market, every
## subject did a Holt-Laury price list. original_dataset.csv joins the row by
## row answers from the session files in df_mpl to the location and treatment
## in data_survey.csv; the recomputed number of safe choices matches the
## stored num_safe_choices for all 512.
##
## Task: the Holt-Laury (2002) list of ten rows. The paper does not print the
## menu, but the oTree exports record which row was drawn for payment, the
## option chosen there and the amount paid, and those realisations give option
## A as 2.00 or 1.60 and option B as 3.85 or 0.10 -- the canonical table.
## choice = number of risky choices = 10 - num_safe_choices.
##
## The 74 subjects who went back to the safe option after once taking the risky
## one are dropped, as multiple switchers are elsewhere in this corpus, leaving
## 438. gender: player.gender of the oTree market files (df_bdm, df_call,
## df_mkt), joined on participant.code; all 512 match and no code carries two
## answers. "Female" = 1, "Male" = 0, the 12 "Other" are left missing. The paper
## does not report the split, so it cannot be checked against the text. No age
## was asked.
df <- read_csv("Data/Zhao_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(multiple_switching == 0) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = 10L - num_safe_choices,
            age = NA_real_,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0, TRUE ~ NA_real_),
            china = location == "DUFE")

df <- df %>%
  mutate(country = if_else(china, 'China', 'United States'),
         city = if_else(china, 'Dalian', 'Santa Cruz'),
         lattitude = if_else(china, '38.9140', '36.9741'),
         longitude = if_else(china, '121.6147', '-122.0308')) %>%
  select(-china)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Zhao2026",
         paper = "Zhao 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zhao_2026/formatted_dataset.csv")
