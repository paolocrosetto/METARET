#### Van Landuyt, B. W. & White, B. J. (2025). The Effect of Uncertainty About
#### Future Accounting Standards on Financial Reporting Quality. Management Science.
#### https://doi.org/10.1287/mnsc.2023.01469
#### Data: Management Science replication package (VW Primary Experiment Dataset.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 121 participants of the primary experiment, run with funding from the
## University of Arizona, the University of Texas at Austin and Cornell (US).
## The post-experimental questionnaire asked "How likely are you to take risks,
## in general?" on 1 (not at all likely) to 7 (very likely) (materials, p. 19);
## the authors' column is called RiskAversion but higher means more willing.
## original_dataset.csv keeps one row per participant; subjects are row numbers.
## choice = the answer rescaled to 0-10, (x - 1) / 6 * 10. No age or sex in the
## package.
df <- read_csv("Data/VanLanduyt_White_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age = NA_real_,
            gender = NA_real_,
            choice = (risk_1to7 - 1) / 6 * 10,
            task = "quest_only",
            country = "United States")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "VanLanduyt2025",
         paper = "Van Landuyt and White 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/VanLanduyt_White_2025/formatted_dataset.csv")
