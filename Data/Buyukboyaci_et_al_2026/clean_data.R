#### Büyükboyacı, M., Gunay, H. & İntişah, M. (2026).
#### Bidding into bankruptcy: How auction order affects overbidding and losses.
#### Journal of Economic Behavior and Organization, 246, 107561. https://doi.org/10.1016/j.jebo.2026.107561
#### Data: https://osf.io/3wzpv/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## AuctionwEqData (2).dta from OSF: one row per subject x auction period,
## Middle East Technical University (Ankara), 2024. The risk task is the same in
## every row of a subject, so one row per subject is kept (session x subject).
df <- read_dta("Data/Buyukboyaci_et_al_2026/original_dataset.dta", encoding = "latin1")

## Holt and Laury (2002) list in ECU: A = 10 / 8, B = 19.25 / 0.50, i.e. the standard
## list x 5. choice1-choice10: 1 = A, 2 = B; choice = number of B choices
## (equals 11 - lineswitched for every subject).
## gender: "E" (erkek) = male, "K" (kadin) = female, as in the authors' do-file.
df <- df %>% 
  distinct(session, subject, .keep_all = TRUE) %>% 
  transmute(subject = row_number(),
            choice = rowSums(across(num_range("choice", 1:10)) == 2),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = case_when(gender == "K" ~ 1,
                               gender == "E" ~ 0,
                               TRUE ~ NA_real_))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "HL",
         bibkey = "Buyukboyaci2026",
         paper = "Büyükboyacı et al. 2026")

## Middle East Technical University, Ankara
df$country = 'Turkey'
df$city = 'Ankara'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buyukboyaci_et_al_2026/formatted_dataset.csv")
