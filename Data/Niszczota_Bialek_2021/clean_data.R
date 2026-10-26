#### Niszczota, P. & Bialek, M. (2021). Women oppose sin stocks more than men do.
#### Finance Research Letters, 41, 101803.
#### https://doi.org/10.1016/j.frl.2020.101803
#### Data: OSF, https://osf.io/74j39 (Data.xlsx, sheet "Data")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Pre-registered online survey (AsPredicted #30599) run on Amazon Mechanical
## Turk until 364 participants were collected, on how people judge investing in
## "sin" industries. 335 of the 364 answered the attention check correctly and
## are the sample the paper analyses; those are kept here.
##
## No incentivized task, so this is a quest_only paper. The questionnaire has
## the general risk item of Dohmen et al. (the SOEP wording), quoted verbatim in
## the authors' "Experimental materials" file: "How do you see yourself: are you
## generally a person who is fully prepared to take risks or do you try to avoid
## taking risks? Choose the appropriate number on a scale of 0 to 10, where
## 0 = not at all willing to take risks, 10 = very willing to take risks."
## That is the soep slot; generate_data_for_app.R moves choice into it.
##
## original_dataset.csv keeps the attention check, this item, age and sex; the
## moral judgments, comfort ratings and the investment knowledge test are
## dropped. gender: "F" = 1, "M" = 0.
df <- read_csv("Data/Niszczota_Bialek_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 364, all(df$risk >= 0 & df$risk <= 10))

df <- df %>%
  filter(attention == 1) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk),
            age = as.numeric(age),
            gender = case_when(sex == "F" ~ 1, sex == "M" ~ 0, TRUE ~ NA_real_),
            bibkey = "Niszczota2021",
            paper = "Niszczota and Bialek 2021")
stopifnot(nrow(df) == 335)

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## an online panel of Mechanical Turk workers; the map shows only the country
df$country = 'United States'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Niszczota_Bialek_2021/formatted_dataset.csv")
