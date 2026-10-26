#### Burro, G., Castagnetti, A., Cillo, A. & Crespi, G. P. (2026). A walk down memory
#### lane: How memories influence stock investment and information processing.
#### Journal of Economic Behavior and Organization, 250, 107760.
#### https://doi.org/10.1016/j.jebo.2026.107760
#### Data: Mendeley Data https://doi.org/10.17632/h3x27cbjfh.1
#### (memory_data_with_liwc.xlsx; the paper says "available on request")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two online experiments on Prolific (early 2023, paid in GBP), 295 participants
## in the authors' cleaned file. original_dataset.csv keeps the information
## treatment flag, the risk answer, sex, the age-bracket midpoint and the amount
## invested; the free-text memories and the text-analysis scores are dropped and
## subjects are row numbers.
## The investment task (GBP 3, the invested part returns 2.5 times if a real stock
## goes up, else is lost) is not used as IG: the probability is not given -- it
## depends on a real stock -- and the treatments are designed to move beliefs
## about it.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (Dohmen et al. 2011), 0-10
## (Risk_seeking). female: 1 = woman, 0 = man. Age was asked in brackets; the file
## gives the bracket midpoints (21, 29.5, ..., 69.5). The paper does not report
## the participants' country, so it is left empty.
df <- read_csv("Data/Burro_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age = age_midpoint,
            gender = female,
            choice = risk_0to10,
            task = "quest_only",
            country = NA_character_)

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Burro2026",
         paper = "Burro et al. 2026")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Burro_et_al_2026/formatted_dataset.csv")
