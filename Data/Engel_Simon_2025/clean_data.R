#### Engel, C. & Simon, D. (2025). Sabotaging competitors, both real and illusory.
#### Judgment and Decision Making, 20, e29. https://doi.org/10.1017/jdm.2025.10005
#### Data: https://osf.io/adeh5/ (Study 1); https://osf.io/wrfn6/ (Study 2)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## simon240724.csv, the authors' prepared file of Study 1 (one row per subject):
## 560 participants from the joint subject pool of the Bonn Max Planck Institute
## and the Econ Lab of Bonn University, online lab experiment (oTree).
## After the main task everyone answered a standard Holt-Laury list
## (2.00/1.60 vs 3.85/0.10 EUR, checked against the payments in the raw file).
## hl = 10 - number of risky choices (authors' code), so choice = 10 - hl.
## The Study 2 replication (56 people) is not added: its HL columns are empty
## in the published raw file.
## gender: "female" = 1, "male" = 0, "divers" = NA.
df <- read_csv("Data/Engel_Simon_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "HL",
            choice = 10 - hl,
            age = as.numeric(age),
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0, TRUE ~ NA_real_),
            country = "Germany",
            city = "Bonn")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Engel2025",
         paper = "Engel and Simon 2025")

## online experiment, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Engel_Simon_2025/formatted_dataset.csv")
