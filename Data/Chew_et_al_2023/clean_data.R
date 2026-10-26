#### Chew, S. H., Miao, B. & Zhong, S. (2023). Ellsberg meets Keynes at an urn.
#### Quantitative Economics, 14(3), 1133-1162.
#### https://doi.org/10.3982/QE2253
#### Data: supplementary replication files of the article
#### (QE2253_code_and_data.rar, folder "Replication Files")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Experiment 1 of the paper: undergraduates answered sixteen ten-row choice
## lists, each pitting a bet that wins with probability one half against a
## column of sure amounts. The lists differ in WHERE the half chance comes
## from -- a known urn, an urn of unknown composition, a compound lottery, or
## the parity of a city temperature -- and the paper is about the gap between
## them, that is about ambiguity.
##
## Only the first list is a risk elicitation, and it is a textbook one.
## Decision Sheet A1 of the printed instructions reads: Option A is "50% of
## receiving $60, 50% of receiving $0", Option B is "Receiving $15 for sure",
## then 19, 23, 25, 27, 29, 30, 31, 33 and 35. a1 is the number of rows in
## which the subject took the lottery, so the certainty equivalent sits between
## two of those amounts; the inversion is in the Chew2023 block of
## generate_r.R. The ambiguity columns a6 to a13 are not used.
##
## Two samples. The paper runs on "more than 2000 undergraduate subjects in
## Singapore" -- 2,066 students of the National University of Singapore, 53.0%
## female -- and replicates on "more than 1000 undergraduate subjects in
## Beijing". city = 1 is the Singapore sample (2,081 rows, 53.2% sex == 2,
## which is how sex = 2 was identified as female) and city = 0 the Beijing one
## (1,189 rows). A further 679 rows have no city, no sex, no age and no answer
## to any list; they are dropped.
##
## original_dataset.csv is experiment1_data.dta reduced to the columns used.
df <- read_csv("Data/Chew_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 3949)

df <- df %>%
  filter(!is.na(a1), !is.na(city)) %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = as.numeric(a1),
            ## sex: 2 = female, 1 = male
            gender = case_when(sex == 2 ~ 1, sex == 1 ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            country = if_else(city == 1, "Singapore", "China"),
            city_name = if_else(city == 1, "Singapore", "Beijing"))

## the two campuses: the National University of Singapore and Beijing
df <- df %>%
  mutate(lattitude = if_else(city_name == "Singapore", "1.2966", "39.9042"),
         longitude = if_else(city_name == "Singapore", "103.7764", "116.4074")) %>%
  rename(city = city_name)

stopifnot(nrow(df) == 2992, sum(df$country == "Singapore") == 1956)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chew2023",
         paper = "Chew et al. 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chew_et_al_2023/formatted_dataset.csv")
