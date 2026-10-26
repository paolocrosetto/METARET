#### Margalit, Y. & Shayo, M. (2021).
#### How Markets Shape Values and Political Preferences: A Field Experiment.
#### American Journal of Political Science, 65(2), 473-492.
#### https://doi.org/10.1111/ajps.12517
#### Data: https://doi.org/10.7910/DVN/UEARI0

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## A field experiment on a national sample of 2703 residents of England who
## were eligible to vote; 1560 of them were given GBP 50 to invest repeatedly
## in financial assets over six weeks, and their attitudes were tracked before
## and after in a seemingly unrelated survey. The file has one row per person;
## only the four columns used here were copied out.
##
## There is no risk elicitation task -- the investment is the treatment, not an
## elicitation -- so the rows are 'quest_only' and generate_data_for_app.R
## moves `choice` into `soep`.
df <- read_csv("Data/Margalit_Shayo_2021/original_dataset.csv", show_col_types = FALSE)

## The general risk question was asked in two waves. Wave 1 is used because it
## is complete for all 2703, while wave 4 is missing for 350; the two correlate
## at 0.68, so they are the same item asked twice.
##
## Both run 0 to 10. The wave 4 label spells the anchors out -- "Taking risks:
## 0 = not at all willing; 10 = very willing" -- which is the Dohmen wording and
## the site's direction. The wave 1 label says "1-10", but that is a slip: the
## variable has 153 zeros. The data agree on the direction too, men averaging
## 5.14 against women's 4.41.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk_1_w1),
            gender = as.numeric(female_w1),
            age = as.numeric(age_w1),
            bibkey = "Margalit2021",
            paper = "Margalit and Shayo 2021")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## national sample of England
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Margalit_Shayo_2021/formatted_dataset.csv")
