#### Engel, C., Mittone, L. & Morreale, A. (2024). Outcomes or participation?
#### Experimentally testing competing sources of legitimacy for taxation.
#### Economic Inquiry, 62(2), 563-583. https://doi.org/10.1111/ecin.13188
#### Data: openICPSR, https://doi.org/10.3886/E193522V4 (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' Raw.xlsx (oTree export, one row
## per subject): 98 students in Trento, oTree. Only the session (renumbered), the
## ten Holt-Laury answers, sex and age were kept; participant codes and labels
## were dropped. This is a different experiment from Engel2020.
## Holt-Laury list (oTree code in Engel_Mit_Morr.zip): the standard table x 10,
## option A 20 or 16, option B 38.5 or 1 (points), the high outcome with
## probability k/10 in row k. HL_k: 1 = A, 2 = B (set_payoff_HL pays f1/f2 for 1).
## choice = number of B choices. The authors' variable `risk` counts A choices.
## sex: "Femminile" = 1, "Maschile" = 0.
df <- read_csv("Data/Engel_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = (HL_1 == 2) + (HL_2 == 2) + (HL_3 == 2) + (HL_4 == 2) + (HL_5 == 2) +
                     (HL_6 == 2) + (HL_7 == 2) + (HL_8 == 2) + (HL_9 == 2) + (HL_10 == 2),
            age,
            gender = case_when(sex == "Femminile" ~ 1, sex == "Maschile" ~ 0, TRUE ~ NA_real_),
            country = "Italy",
            city = "Trento")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Engel2024",
         paper = "Engel et al. 2024")

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
df %>% write_csv("Data/Engel_et_al_2024/formatted_dataset.csv")
