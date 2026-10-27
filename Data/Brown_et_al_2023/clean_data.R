#### Brown, J. L., Martin, P. R., Sprinkle, G. B. & Way, D. (2023). How Return on
#### Investment and Residual Income Performance Measures and Risk Preferences
#### Affect Risk-Taking. Management Science, 69.
#### https://doi.org/10.1287/mnsc.2022.4398
#### Data: Management Science replication package (BMSW_Flat.txt)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 100 Amazon Mechanical Turk workers (US). After the project choices they
## answered the Dohmen et al. question "In general, would you consider yourself
## someone who is fully prepared to take risks, or do you try to avoid taking
## risks?" on 0-10 (paper, footnote 15). original_dataset.csv keeps condition and
## the answer; worker ids are dropped and subjects are row numbers.
## The package has no age or sex.
df <- read_csv("Data/Brown_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age = NA_real_,
            gender = NA_real_,
            choice = peq_risk_attitude,
            task = "quest_only",
            country = "United States")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Brown2023",
         paper = "Brown et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Brown_et_al_2023/formatted_dataset.csv")
