#### Dong, Y., Dreber, A., Johannesson, M. & Kilicgedik, G. (2026).
#### Incidental emotions and financial risk-taking.
#### Journal of Economic Behavior and Organization, 246, 107556. https://doi.org/10.1016/j.jebo.2026.107556

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Main study, Prolific (UK and US residents), Feb-Apr 2025, 7 conditions of
## about 1,000 each: five movie-clip emotion inductions, a control without a
## clip, and a manipulation check without the risk task.
## Source: "Emotion - 2.17_April 21, 2025_05.34.xlsx" (already without Prolific
## ids, IP addresses and locations). Only the columns needed here were copied:
## Finished, whether a clip page was shown, whether the control emotion rating
## was answered, the six risk choices and gender. (The file "Cleaned data.dta"
## in the package belongs to a later study and is not used.)
## Risk task (CEPL): six choices, in random order, between a sure GBP 1, 1.5,
## 1.75, 2, 2.25, 2.75 and a 50% chance of GBP 4; one paid. RMx: 1 = sure,
## 2 = gamble. choice = number of gambles taken. Inconsistent (counted until
## 29.10.2026): the 136 whose answers are not monotone in the sure amount
## (RM1-RM6 run from GBP 1 to 2.75), i.e. who take the gamble against a higher
## sure amount after taking a lower one. The six choices came in random order,
## so there is no list switching point; they keep one row each with their
## count, for the download only, with inconsistent = 1 (Data/inconsistent_rows.R,
## as for Vieider2024).
## Only the control condition is kept (no clip shown, control emotion rating
## present), as in the authors' do-file. The authors also dropped some test and
## unmatched Prolific ids, which cannot be identified in the anonymised file:
## 1,037 finished controls here vs 1,031 in the paper.
## Gender: 2 = female, 1 = male (as in the do-file); 3-4 -> NA. No age; the
## country (UK or US) is not in the file.
df <- read_csv("Data/Dong_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(Finished == 1, film_shown == 0, emotion_rating_control == 1) %>% 
  transmute(subject = row_number(),
            task = "CEPL",
            choice = (RM1 == 2) + (RM2 == 2) + (RM3 == 2) + (RM4 == 2) + (RM5 == 2) + (RM6 == 2),
            inconsistent = as.numeric(!apply(cbind(RM1, RM2, RM3, RM4, RM5, RM6) == 2, 1,
                                             function(a) all(diff(a) <= 0))),
            age = NA_real_,
            gender = case_when(Gender == 2 ~ 1, Gender == 1 ~ 0, TRUE ~ NA_real_),
            country = NA_character_,
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Dong2026",
         paper = "Dong et al. 2026")

## online experiment, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Dong_et_al_2026/formatted_dataset.csv")
