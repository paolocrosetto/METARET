#### Niszczota, P. & Błaszczyński, J. (2024).
#### Hard to digest investments: People oppose investment in both conventional
#### and cultured meat producers.
#### Ecological Economics, 216, 108094.
#### https://doi.org/10.1016/j.ecolecon.2023.108094
#### Data: https://osf.io/2gr9a

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two studies on US residents -- the first on Amazon Mechanical Turk (661
## recruited), the second on Prolific (800) -- about willingness to invest in
## meat producers. The shared workbook has six sheets; the pooled one carries
## both studies, and only the six columns used here were copied out of it.
##
## There is no risk elicitation task: the investment question is about meat
## stocks, a domain attitude, not a lottery. So the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
df <- read_csv("Data/Niszczota_Blaszczynski_2024/original_dataset.csv", show_col_types = FALSE)

## The workbook's own Descriptions sheet says attentionOK is "=1 if passed
## attention check (used in paper)", and the analysis script subsets on it
## throughout, so the 160 who failed are dropped. That leaves 1301, which is
## exactly the N the paper reports for the two studies together.
##
## The same sheet describes the item as "Risk tolerance [0-10]", the Dohmen
## scale. The direction is the usual one: men average 5.30 against women's 4.48.
##
## gender is text. The workbook also has a `female` column, but it was saved as
## an unevaluated Excel formula, so the text column is used instead; the 32
## subjects who answered "nb" or preferred not to say are left missing.
df <- df %>%
  filter(attentionOK == 1) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk),
            gender = case_when(gender == "f" ~ 1, gender == "m" ~ 0, TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Niszczota2024",
            paper = "Niszczota and Błaszczyński 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online; both samples were restricted to residents of the United States
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Niszczota_Blaszczynski_2024/formatted_dataset.csv")
