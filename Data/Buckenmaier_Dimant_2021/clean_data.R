#### Buckenmaier, J. & Dimant, E. (2021).
#### The experience is (not) everything: Sequential outcomes and social
#### decision-making.
#### Economics Letters, 205, 109916.
#### https://doi.org/10.1016/j.econlet.2021.109916
#### Data: https://osf.io/n9w3c

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 1200 subjects in five pre-registered online experiments on Prolific, one row
## each; the paper reports the same 1200 and the same 564 women. The social
## decision tasks are a dictator game, a trust game and a public good, none of
## which is a risk elicitation, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
df <- read_csv("Data/Buckenmaier_Dimant_2021/original_dataset.csv", show_col_types = FALSE)

## The codebook kept next to this file describes the item only as "risk, 0 to
## 10", and the screenshots are images, so the wording could not be read off
## the package. The scale is the one Dohmen et al. use, and the direction is
## the usual one: men average 5.45 against women's 4.75.
df <- df %>%
  arrange(subject) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk),
            gender = as.numeric(female),
            age = as.numeric(age),
            bibkey = "Buckenmaier2021",
            paper = "Buckenmaier and Dimant 2021")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online on Prolific; the package does not record where subjects lived
df$country = NA_character_
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buckenmaier_Dimant_2021/formatted_dataset.csv")
