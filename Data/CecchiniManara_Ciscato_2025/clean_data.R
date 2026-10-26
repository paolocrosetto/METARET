#### Cecchini Manara, V., Ciscato, E., Guarnieri, P. & Spadoni, L. (2025). Back to
#### the future: An experiment on ecological restoration.
#### Ecological Economics, 227, 108386. https://doi.org/10.1016/j.ecolecon.2024.108386
#### Data: https://osf.io/g82fs (Dataset and replication files/restoration_data_osf.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps the condition, the risk answer, sex and age from the
## authors' file (one row per subject): 810 UK residents aged 18-40, recruited on
## Prolific, online oTree experiment (April 2023). The file has no Prolific ids;
## subjects keep the authors' running index. Sex and age are missing for the
## subjects who revoked consent on Prolific (4).
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (Dohmen et al. 2011), 0-10,
## higher = more willing (women 5.04, men 5.80). female: 1 = woman, 0 = man.
df <- read_csv("Data/CecchiniManara_Ciscato_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = self_risk,
            task = "quest_only",
            country = "United Kingdom")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "CecchiniManara2025",
         paper = "Cecchini Manara et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/CecchiniManara_Ciscato_2025/formatted_dataset.csv")
