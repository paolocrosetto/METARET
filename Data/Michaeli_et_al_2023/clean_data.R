#### Michaeli, M., Casari, M., Ichino, A., De Paola, M., Marandola, G. & Scoppa, V.
#### (2023). Civicness drain. The Economic Journal, 133, 323-354.
#### https://doi.org/10.1093/ej/ueac068
#### Data: https://doi.org/10.5281/zenodo.6940446 (Data/raw_data/CSV/
#### raw_civicness_calabria.csv and raw_civicness_romagna.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps the region, the risk answer and sex of every
## student: 671 senior high-school students in 33 classes of 11 schools in
## Calabria and 394 in 23 classes of 12 schools in Emilia-Romagna (Italy),
## lab-in-the-field experiment. School, class and student ids, school names and
## cities are dropped; subjects are row numbers. Age is not in the files (all are
## in their final school year).
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item (quest14, "propensione al rischio") is a non-incentivised SOEP-type
## question from 0 = no willingness to 10 = full willingness to take risks (paper,
## section 1). The authors impute the 14 missing answers with the mean; here they
## stay missing.
## female: 1 = woman, 0 = man, from quest2; the three missing values the authors
## fill in by hand in create_civicness_all.do were filled in the same way.
df <- read_csv("Data/Michaeli_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age = NA_real_,
            gender = female,
            choice = risk_0to10,
            task = "quest_only",
            country = "Italy")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Michaeli2023",
         paper = "Michaeli et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Michaeli_et_al_2023/formatted_dataset.csv")
