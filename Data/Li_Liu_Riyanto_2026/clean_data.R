#### Li, J., Liu, F. & Riyanto, Y. E. (2026). Cash versus contactless mobile
#### payment: The effect of payment modes on donation behaviors. Economic
#### Inquiry, 64(2), 454-467. https://doi.org/10.1111/ecin.70047
#### Data: openICPSR 239721 (Raw data/FullDATA.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 181 undergraduates in the Behavioral and Experimental Economics Lab at
## Nanyang Technological University, Singapore: 4 sessions on 12-13 February
## 2020 and 6 sessions on 7-8 October 2020. Besides a donation decision, each
## subject played one Gneezy-Potters round (Stage 2): 5 SGD handed over in
## cash or by mobile payment, any whole number of dollars bet, lost with
## probability 2/3, returned 2.5 times with probability 1/3, paid. choice =
## SGD bet. As in the authors' CleanDATA.do, the subject who withdrew from the
## experiment (Id 74333) is dropped before the file is written.
## Age was asked only in bands (below 20, 20 to 24, 25 to 29), so it is left
## empty. original_dataset.csv keeps session date, treatment, payment mode, the
## endowment, the bet, sex, age band and nationality; the payment ids are
## dropped and subjects are row numbers.
df <- read_csv("Data/Li_Liu_Riyanto_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 181, all(df$endowment == 5), all(df$investment %in% 0:5))

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = investment,
            age = NA_real_,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            country = "Singapore",
            city = "Singapore",
            bibkey = "Li2026",
            paper = "Li et al. 2026")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '1.3483'
df$longitude = '103.6831'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Li_Liu_Riyanto_2026/formatted_dataset.csv")
