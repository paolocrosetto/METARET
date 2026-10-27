#### Balafoutas, L., Batsaikhan, M. & Sutter, M. (2024). Competitiveness of
#### Entrepreneurs and Salaried Workers. Management Science, 70.
#### https://doi.org/10.1287/mnsc.2023.4838
#### Data: Management Science replication package (data_final_cleaned.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment in Vietnam with business owners and salaried
## workers (two waves, 2019). After the competition task subjects played the
## Gneezy-Potters investment game: 100 experimental units (1 unit = 1,500 dong),
## the invested part returns three times its amount with probability 1/2, else
## is lost (paper, section 2.2). original_dataset.csv keeps one row per subject
## with the job type, the investment, age and sex; the authors' subject ids are
## dropped and subjects are row numbers. choice = units invested (0-100).
## female: 1 = woman, 0 = man. One subject has no investment and is dropped.
df <- read_csv("Data/Balafoutas_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(investment_point)) %>%
  transmute(subject,
            task = "IG",
            choice = investment_point,
            age,
            gender = female,
            country = "Vietnam")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Balafoutas2024",
         paper = "Balafoutas et al. 2024")

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
df %>% write_csv("Data/Balafoutas_et_al_2024/formatted_dataset.csv")
