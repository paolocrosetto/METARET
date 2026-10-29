#### Campos-Mercade, P., Meier, A. N., Schneider, F. H. & Wengström, E. (2021).
#### Prosociality predicts health behaviors during the COVID-19 pandemic.
#### Journal of Public Economics, 195, 104367.
#### https://doi.org/10.1016/j.jpubeco.2021.104367
#### Data: openICPSR 148881 (replication_data.dta, replication_maintable.do), in
#### raw_repository/; the COVID worry items (q96_*), the subjective life
#### expectancy and the county are removed from the data

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## replication_data.dta: one row per participant, the 967 who "answered all
## questions in both surveys and finished the health behavior survey in more
## than five minutes" (minutes >= 5 for all of them). Online surveys of a
## representative sample of the Swedish population (Enkätfabriken, April 2020).
df <- read_dta("Data/CamposMercade_et_al_2021/original_dataset.dta") %>%
  zap_labels()
stopifnot(nrow(df) == 967, all(df$minutes >= 5))

## Choice 6 of the social preferences survey (Appendix D): "you start with 100
## kr ... You can consider investing 0 kr, 20 kr, 40 kr, 60 kr, 80 kr, or 100
## kr ... There is a 50% chance that the investment will fail ... you will
## receive 2.5 times the amount you invested." Incentivized: 1 in 10
## participants is paid one of the six choices. risktask is the option, 1 = 0
## kr invested ... 6 = 100 kr, so choice = kr invested = 20 * (risktask - 1).
## female: 1 woman.
df <- df %>%
  transmute(subject = row_number(),
            age = age,
            gender = female,
            task = "IG",
            choice = 20 * (risktask - 1))
stopifnot(all(df$choice %in% seq(0, 100, 20)))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "CamposMercade2021",
         paper = "Campos-Mercade et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Online sample of Swedish residents, so no city and no coordinates.
df$country = 'Sweden'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/CamposMercade_et_al_2021/formatted_dataset.csv")
