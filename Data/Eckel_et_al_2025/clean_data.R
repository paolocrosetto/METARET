#### Eckel, C., Wilson, R. & Yang, N. (2025).
#### The evolution of risk attitudes: A panel study of the university years.
#### Journal of Risk and Uncertainty, 70, 225-248. https://doi.org/10.1007/s11166-025-09457-7
#### Data: https://doi.org/10.17605/OSF.IO/W9ZVC

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## JRU_CE_March_4_2025.csv from OSF: Rice University students (several cohorts),
## one row per subject x wave, 2016-2021.
df <- read_csv("Data/Eckel_et_al_2025/original_dataset.csv", show_col_types = FALSE)

## Eckel-Grossman task as in Dave et al. (2010), Figure B2 of the supplementary
## information: six 50/50 options, in dollars,
##   1) 10/10  2) 8/14  3) 6/18  4) 4/22  5) 2/26  6) 0/28
## eckel = chosen option (1 = safest). SOEP_risk = SOEP general risk item (0-10).
## Subjects repeat the task in several waves. To keep one observation per subject,
## as for the other panels, we keep each subject's first wave with a lottery choice
## (wave codes are year + letter, so alphabetical order is chronological).
df <- df %>% 
  filter(!is.na(eckel)) %>% 
  arrange(id, wave) %>% 
  distinct(id, .keep_all = TRUE) %>% 
  transmute(subject = as.numeric(id),
            choice = as.numeric(eckel),
            soep = as.numeric(SOEP_risk),
            ## 1 - female, 0 - male
            gender = case_when(sex == "Female" ~ 1,
                               sex == "Male" ~ 0,
                               TRUE ~ NA_real_))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "EG",
         bibkey = "Eckel2025",
         paper = "Eckel et al. 2025")

## Rice University, Houston
df$country = 'United States'
df$city = 'Houston'
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
df %>% write_csv("Data/Eckel_et_al_2025/formatted_dataset.csv")
