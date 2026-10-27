#### Woerner, A., Romagnoli, G., Probst, B. M., Bartmann, N., Cloughesy, J. N. &
#### Lindemans, J. W. (2025). Should Individuals Choose Their Own Incentives?
#### Evidence from a Mindfulness Meditation Intervention. Management Science, 71,
#### 7056-7070. https://doi.org/10.1287/mnsc.2021.04157
#### Data: Management Science replication package (Replication Package/Code_and_Data)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Field experiment with students of the University of Amsterdam, two waves
## (end of 2019, start of 2020). The risk measure is in the baseline survey:
## Gneezy-Potters investment, EUR 40, the invested amount is lost or returned
## 2.5 times with equal chances; three randomly drawn participants were paid
## (instructions, page 14). original_dataset.csv keeps the 509 participants who
## finished the baseline survey and gave an investment; the authors' ids are
## dropped and subjects are row numbers. choice = euros invested (0-40).
## female: 1 = woman, 0 = man. dutch = Dutch nationality (most, not all, are).
df <- read_csv("Data/Woerner_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = investment,
            age,
            gender = female,
            country = "Netherlands")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Woerner2025",
         paper = "Woerner et al. 2025")

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
df %>% write_csv("Data/Woerner_et_al_2025/formatted_dataset.csv")
