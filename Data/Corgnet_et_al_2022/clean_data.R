#### Corgnet, B., Deck, C., DeSantis, M. & Porter, D. (2022). Forecasting Skills
#### in Experimental Markets: Illusion or Reality? Management Science, 68,
#### 5216-5232. https://doi.org/10.1287/mnsc.2021.4160
#### Data: Management Science replication package (data_forecasting_skills.xlsx,
#### sheets Bret and DATA)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 125 participants at the Economic Science Institute, Chapman University,
## recruited among people who had traded in experimental asset markets before.
## BRET with 49 boxes (7 x 7 grid), USD 0.10 per box, one bomb (paper, section
## 3); subjects typed the number of boxes. original_dataset.csv keeps the
## session, the boxes collected, whether the bomb was hit and the sex from the
## DATA sheet (it matches the Bret sheet for every subject); the oTree session and
## player codes are dropped and subjects are row numbers. choice = boxes (1-49).
df <- read_csv("Data/Corgnet_et_al_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = boxes,
            age = NA_real_,
            gender = case_when(gender_raw == "Female" ~ 1, gender_raw == "Male" ~ 0),
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Corgnet2022",
         paper = "Corgnet et al. 2022")

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
df %>% write_csv("Data/Corgnet_et_al_2022/formatted_dataset.csv")
