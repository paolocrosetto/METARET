#### Greiner, B., Grünwald, P., Lindner, T., Lintner, G. & Wiernsperger, M. (2025).
#### Incentives, Framing, and Reliance on Algorithmic Advice: An Experimental
#### Study. Management Science. https://doi.org/10.1287/mnsc.2022.02777
#### Data: Management Science replication package (data_1_experiment_raw_dataset.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment with 1,489 participants from the subject pools of three
## public universities in Austria. No risk task; the questionnaire asked the
## willingness to take risks on 0-10 (paper, Table 2). original_dataset.csv keeps
## subject pool, condition, age, sex and the answer; subjects are row numbers.
## choice = willingness to take risks. female: 1 = woman, 0 = man.
df <- read_csv("Data/Greiner_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk_taking,
            task = "quest_only",
            country = "Austria")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Greiner2025",
         paper = "Greiner et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Greiner_et_al_2025/formatted_dataset.csv")
