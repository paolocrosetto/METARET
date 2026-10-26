#### Fonseca, M. A. & McCrea, A. (2025). The role of experience in shifting gender
#### beliefs on performance: Experimental evidence.
#### Journal of Economic Behavior and Organization, 237, 107115.
#### https://doi.org/10.1016/j.jebo.2025.107115
#### Data: https://osf.io/8n5sq (replication_package/temp_data/NONstacked.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps the treatment, the risk task, age, sex and country of
## residence from the authors' cleaned file (one row per participant): 600
## Prolific participants, online oTree experiment, paid in GBP. The Prolific ids,
## oTree labels and completion codes are removed; subjects are row numbers.
## After six rounds of the main task everyone did the bomb risk elicitation task
## (Crosetto and Filippin 2013) with 100 boxes, paid 0.03 GBP per box opened:
## choice = number of boxes opened. All six treatments are kept -- the task is the
## same in all of them, including OB-SS, which the paper drops from its main
## analysis for reasons unrelated to risk. 13 participants opened all 100 boxes.
## female: 1 = female, 0 = male (one sex and one country are "DATA_EXPIRED" on
## Prolific and are missing).
df <- read_csv("Data/Fonseca_McCrea_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = boxes_opened,
            age,
            gender = female,
            country)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Fonseca2025",
         paper = "Fonseca & McCrea 2025")

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
df %>% write_csv("Data/Fonseca_McCrea_2025/formatted_dataset.csv")
