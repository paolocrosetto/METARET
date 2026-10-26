#### Buso, I. M., Ferrari, L., Güth, W., Lorè, L. & Spadoni, L. (2024).
#### Testing isomorphic invariance across social dilemma games.
#### Journal of Economic Behavior and Organization, 222, 108-122.
#### https://doi.org/10.1016/j.jebo.2024.04.024
#### Data: https://osf.io/juysc

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 384 participants in 16 sessions at the Luiss CESARE Lab in Rome, each
## playing two rounds of a prisoner's dilemma or a linear public good with the
## same payoffs, so the file has 768 rows. Everything used here is constant
## within id.
##
## The file in the OSF archive is called "dataset" with no extension; it is a
## Stata file and is stored here as original_dataset.dta.
##
## There is no risk elicitation task: `choice` is the cooperative choice in the
## dilemma, not a lottery. What the paper does contribute is the general risk
## question, which it describes as non-incentivised and cites to Dohmen et al.
## (2011); the variable label says so too, "self reported risk, Dohmen et al.
## (2011), ranging from 1 to 10". The rows are therefore 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## The answers run 1 to 10 rather than the usual 0 to 10, so they are rescaled
## linearly over the same range, exactly as Drouvelis and Qiu's are.
##
## male is a dummy with female = 0, so gender is its complement.
df <- read_dta("Data/Buso_et_al_2024/original_dataset.dta") %>%
  distinct(id, .keep_all = TRUE) %>%
  arrange(id) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = (as.numeric(risk) - 1) * 10 / 9,
            gender = 1 - as.numeric(male),
            age = as.numeric(age),
            bibkey = "Buso2024",
            paper = "Buso et al. 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Luiss CESARE Lab, Rome.
df$country = 'Italy'
df$city = 'Rome'
df$lattitude = '41.9028'
df$longitude = '12.4964'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buso_et_al_2024/formatted_dataset.csv")
