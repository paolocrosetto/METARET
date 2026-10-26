#### Cox, C. A., de Oliveira, A. & Stoddard, B. (2026). Public information and
#### coordination with a divided majority.
#### Experimental Economics, 28, 1300-1320.
#### https://doi.org/10.1017/eec.2026.10051
#### Data: https://osf.io/8aey9

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Divided-majority voting game run in z-Tree: "All sessions were run at the
## University of Massachusetts Amherst in the Fall of 2021 with 128 subjects",
## recruited through ORSEE. The voting game is not a risk elicitation, so the
## rows are 'quest_only' and generate_data_for_app.R moves `choice` into
## `soep`.
##
## The closing survey carried the general risk item: "Participants also
## completed a demographic survey, the cognitive reflection test (Frederick,
## 2005), and a risk attitude questionnaire (Dohmen et al., 2011)." In the data
## it is self_risk, which the package's own readme describes as "Response to
## question about willingness to take risks (1-10)".
##
## THE SCALE IS 1 TO 10, not the 0 to 10 of the original SOEP item, and the
## readme says so outright, so this is not a case of an unused bottom category.
## It is rescaled linearly onto 0 to 10, the same treatment given to the 1 to
## 10 answers of Drouvelis and Qiu and the 1 to 7 item of Seifert et al. 2026.
##
## risk90, risk70, risk50 and risk0 look like a lottery series but are zero for
## 96 of the 128 subjects, so they are left alone.
##
## original_dataset.csv is AllData.csv collapsed to one row per subject: the
## file holds 5,120 rows, 40 per person.
df <- read_csv("Data/Cox_et_al_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 128, all(df$self_risk >= 1 & df$self_risk <= 10))

## gender: male_d is the authors' male dummy, so it is flipped to the site's
## 1 = female; three subjects have it blank, from free-text answers that did
## not map onto either category.
df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = (as.numeric(self_risk) - 1) * 10 / 9,
            gender = if_else(is.na(male_d), NA_real_, 1 - as.numeric(male_d)),
            age = as.numeric(age),
            bibkey = "Cox2026",
            paper = "Cox et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## University of Massachusetts Amherst
df$country = 'United States'
df$city = 'Amherst'
df$lattitude = '42.3868'
df$longitude = '-72.5301'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Cox_et_al_2026/formatted_dataset.csv")
