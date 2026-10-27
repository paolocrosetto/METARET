#### Crosetto, P. & Gaudeul, A. (2024). Fast Then Slow: Choice Revisions Drive a
#### Decline in the Attraction Effect. Management Science, 70.
#### https://doi.org/10.1287/mnsc.2023.4874
#### Data: Management Science replication package (Data and Analysis/Descriptive
#### analysis/Data/alldata_exp1.csv, alldata_exp2.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two lab experiments in Grenoble, France: 111 participants in July 2017 and
## 198 others (no students) in September 2021. The final questionnaire asked the
## SOEP general risk question, 0-10. original_dataset.csv keeps one row per
## person with the experiment, sex, age and the answer; subjects are row numbers.
## gender: f = female, h = male.
df <- read_csv("Data/Crosetto_Gaudeul_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = case_when(gender == "f" ~ 1, gender == "h" ~ 0),
            choice = soep,
            task = "quest_only",
            country = "France")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "CrosettoGaudeul2024",
         paper = "Crosetto and Gaudeul 2024")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crosetto_Gaudeul_2024/formatted_dataset.csv")
