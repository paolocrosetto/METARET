#### Uğur, Z. B. & Doğanay, S. (2024).
#### Risk and time preferences following war: evidence from Syrian children.
#### Journal of Behavioral and Experimental Economics, 112, 102242.
#### https://doi.org/10.1016/j.socec.2024.102242
#### Data: OSF db7qz, view-only link and password given in the paper's data
#### statement ("Data is available at the following link ... with the
#### following password"); no licence stated. The spreadsheet is
#### password-protected; Liza opened it and saved a plain CSV.
#### raw_repository/ holds the authors' do-file; original_dataset.csv keeps only
#### the id, city, ethnicity, exposure to the conflict, years since migration,
#### age, sex and the risk choice. The (empty) parent and child name columns,
#### the free-text notes, height, weight and the IQ-test answers are not copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "In the spring of 2019, we conducted experiments with a total of 547
## children, including 340 children from public schools in Ankara and 207
## children from public schools in Gaziantep", aged 5 to 14 (one is 15): Syrian
## refugee children (and three Turkmen) and Turkish children from the same
## neighbourhoods. "not all children participated in both games": 99 have no
## risk choice and are left out.
df <- read_csv("Data/Ugur_Doganay_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 547)
df <- df %>% filter(!is.na(risk))
stopifnot(nrow(df) == 448, all(df$risk %in% 0:10))

## The risk game (section 3.2): "each child was given 10 pieces of chocolate ...
## dividing the 10 chocolates between a risky and a riskless option ... The
## chocolates placed in the risky option had a 50/50 chance of resulting in
## three times the amount invested or losing everything. The results were
## determined through a coin toss in front of the participants." A
## Gneezy-Potters investment task with chocolates (about 1 TL each) instead of
## money; risk = chocolates put in the risky option. The r rule depends only on
## the share invested and the multiplier.
## treatment: exposed to the war as in the authors' do-file (Syrian or Turkmen
## children, except those who moved before the war or were born in Turkey,
## conflict == "No") or not (Turkish children).
df <- df %>%
  transmute(subject = row_number(),
            age = as.numeric(age),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            task = "IG",
            choice = risk,
            treatment = if_else(ethnicity %in% c("Syrian", "Turkmen") & coalesce(conflict, "") != "No",
                                "exposed to the war", "not exposed"),
            city = city)

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Ugur2024",
         paper = "Ugur and Doganay 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Public schools in the suburbs of Ankara and Gaziantep; city coordinates.
df <- df %>%
  mutate(country = "Turkey",
         lattitude = if_else(city == "Ankara", "39.9334", "37.0662"),
         longitude = if_else(city == "Ankara", "32.8597", "37.3833"))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, treatment,
         country, city, lattitude, longitude)

# Writing to file
df %>% write_csv("Data/Ugur_Doganay_2024/formatted_dataset.csv")
