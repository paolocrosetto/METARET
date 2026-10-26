#### Seifert, M., Palan, S., Ropret Homar, A., Spitzer, F., Kirchler, E. &
#### Gangl, K. (2026). Sustainable finance literacy predicts investment
#### behavior beyond general financial literacy: Evidence from two
#### representative samples.
#### Journal of Behavioral and Experimental Finance, 52, 101262.
#### https://doi.org/10.1016/j.jbef.2026.101262
#### Data: https://doi.org/10.7910/DVN/U6THKG

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two representative samples of the Austrian population on sustainable finance
## literacy. The second study (2835 respondents) is the one with a risk item;
## only the four columns needed were copied out of its raw file.
##
## Study 1 is not used. Its one risk-looking variable, FKbRisk, is a financial
## literacy question, not an attitude: the authors' data_management.R scores it
## as FL_b_Risk_correct <- ifelse(FKbRisk == 2, 1, 0).
df <- read_csv("Data/Seifert_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## The item is the financial-domain risk question, worded in the paper as "How
## willing are you to take risks in financial matters (1 = not at all willing,
## 7 = very willing to take risks)". It is therefore soep_financial and not the
## general soep item, which the study does not ask. Only 1515 of the 2835
## respondents answered it.
##
## The scale runs 1 to 7 instead of 0 to 10, so it is rescaled linearly over the
## same range, as Drouvelis and Qiu's 1 to 10 answers are. The direction is the
## one the anchors state, and the data agree: men average 3.62 against women's
## 2.74.
##
## gender is 1 = male, 2 = female (the authors recode 1 to 0 and 2 to 1 for
## their female dummy); the few answers of 3 are left missing. A handful of ages
## are impossible (2, 1995), so anything outside 15 to 100 is dropped.
df <- df %>%
  filter(!is.na(risktaking)) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            ## no general risk item in this study, so `choice` -- which
            ## generate_data_for_app.R turns into soep -- stays empty
            choice = NA_real_,
            soep_financial = (as.numeric(risktaking) - 1) * 10 / 6,
            gender = case_when(gender == 2 ~ 1, gender == 1 ~ 0, TRUE ~ NA_real_),
            age = if_else(age >= 15 & age <= 100, as.numeric(age), NA_real_),
            bibkey = "Seifert2026",
            paper = "Seifert et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online representative sample of Austria
df$country = 'Austria'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Seifert_et_al_2026/formatted_dataset.csv")
