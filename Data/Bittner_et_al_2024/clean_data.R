#### Bittner, A., Haering, A., Heinrich, T. & Mayrhofer, T. (2024).
#### Revalidating a survey instrument for measuring risk preferences.
#### Economics Letters, 242, 111851.
#### https://doi.org/10.1016/j.econlet.2024.111851
#### Data: https://osf.io/3a7td

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 414 subjects from three samples collected for Haering et al. (2020): China
## (140), the United States (129) and Germany (145). The file is one row per
## subject and has no missing values.
##
## The paper asks how well the two survey items of the Global Preferences
## Survey predict experimentally elicited risk aversion, so it carries three
## measures at once:
##  - staircase_risk_fixed, the GPS staircase (taken here as CE_staircase),
##  - risk_01, the general risk question of Dohmen et al. on 0 to 10 (soep),
##  - O2_count, the number of risk-averse choices in seven incentivised lottery
##    pairs.
##
## O2_count is left out on purpose. Those pairs are Eeckhoudt-Schlesinger
## comparisons, which detect whether someone is risk averse at all -- any
## concave utility prefers the less risky side in every pair -- and not how
## risk averse. The count therefore has no CRRA reading, and the paper itself
## uses it only to classify subjects as risk averse or not.
df <- read_dta("Data/Bittner_et_al_2024/original_dataset.dta")

## Country carries Stata value labels, which is where the three samples come
## from; the site stores a country per row, so all three are kept apart.
##
## Neither age nor gender is in the released file.
df <- df %>%
  mutate(cty = as.character(haven::as_factor(Country))) %>%
  arrange(Country, Session, Subject) %>%
  transmute(subject = row_number(),
            task = "CE_staircase",
            choice = as.numeric(staircase_risk_fixed),
            soep = as.numeric(risk_01),
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Bittner2024",
            paper = "Bittner et al. 2024",
            country = case_when(cty == "China" ~ "China",
                                cty == "USA" ~ "United States",
                                cty == "Germany" ~ "Germany",
                                TRUE ~ NA_character_))

df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bittner_et_al_2024/formatted_dataset.csv")
