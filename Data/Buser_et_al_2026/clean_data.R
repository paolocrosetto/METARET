#### Buser, T., Niederle, M. & Oosterbeek, H. (2026). Can competitiveness predict
#### education and labor market outcomes? Evidence from incentivized choice and
#### survey measures. Review of Economics and Statistics, 108(3), 755-773.
#### https://doi.org/10.1162/rest_a_01439
#### Data: Harvard Dataverse https://doi.org/10.7910/DVN/IPWCES (L_compete_5p.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The authors' own questionnaire in the Dutch LISS panel (a probability sample of
## the Dutch population): 5,268 respondents. original_dataset.csv keeps the risk
## answer, sex and age; the encrypted LISS member ids are dropped and subjects are
## row numbers. The 2,098 respondents of the authors' incentivised experiment are
## a subset of these and are not added twice.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item (v4) is the SOEP general risk question, 0 = "not at all willing to
## take risks" to 10 = "very willing"; 16 missing answers stay missing.
## female: geslacht 2 ("Vrouw") = 1, 1 ("Man") = 0.
df <- read_csv("Data/Buser_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk_0to10,
            task = "quest_only",
            country = "Netherlands")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Buser2026",
         paper = "Buser et al. 2026")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_et_al_2026/formatted_dataset.csv")
