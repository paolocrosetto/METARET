#### Cust, H., Lépine, A., Treibich, C., Powell-Jackson, T., Radice, R. &
#### Tidiane Ndour, C. (2024).
#### Trading HIV for sheep: Risky sexual behavior and the response of female sex
#### workers to Tabaski in Senegal.
#### Health Economics, 33(1), 153-193. https://doi.org/10.1002/hec.4756
#### Data: wave 3 (June-August 2020) of the Dakar cohort of female sex workers,
#### deposited by Lépine as "PrEP randomised controlled trial among female sex
#### workers, Senegal", UCL Research Data Repository,
#### https://doi.org/10.5522/04/28882685 (CC0). The full file is kept outside
#### the app in repository_data/Lepine_Senegal_FSW_panel/; it is a survey of a
#### vulnerable population (sex work, HIV, policing), so original_dataset.csv
#### keeps only a row number, age, whether the woman is still a sex worker, the
#### investment game and the two general risk questions.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 604 women interviewed in the third wave of the cohort ("a survey conducted
## between June and August 2020 in Dakar, Senegal. The survey was the third wave
## (after waves in 2015 and 2017)", PLoS Med 2025 on the same data). The paper
## analyses the 514 who were still active sex workers ("we drop those tracked
## but are no longer active sex workers N = 92"); everyone played the risk game,
## so all 604 are kept and still_sex_worker separates the two.
df <- read_csv("Data/Cust_et_al_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 604, sum(df$still_sex_worker == 1) == 514)

## The risk game: "Gneezy-Potter is an investment game to determine the risk
## aversion of individuals" (Table 1 note; the paper uses it as a control, coded
## 0-2). The raw answers are in the file: jeu2_choix is the amount invested in
## the paid round (0, 500, ..., 3000 FCFA). The payouts in jeu2_gain give the
## rule: 3000 FCFA endowment, the invested amount is lost (jeu2_pile_choix 1) or
## returned 2.5 times (2), i.e. 3000 - x or 3000 + 1.5x - the Gneezy-Potters /
## Charness-Gneezy investment task with a 50/50 coin.
## m4_q01 and m4_q02: "Preference for risk: in general" and "in financial
## matters", 0-10 - the site's SOEP general and financial items.
## All respondents are women.
df <- df %>%
  transmute(subject = row_number(),
            age = age,
            gender = 1,
            task = "IG",
            choice = jeu2_choix,
            soep = m4_q01,
            soep_financial = m4_q02,
            treatment = if_else(still_sex_worker == 1, "active sex worker", "left sex work"))
stopifnot(all(df$choice %in% seq(0, 3000, 500)))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Cust2024",
         paper = "Cust et al. 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Dakar.
df$country = 'Senegal'
df$city = 'Dakar'
df$lattitude = '14.7167'
df$longitude = '-17.4677'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, soep, soep_financial, everything())

# Writing to file
df %>% write_csv("Data/Cust_et_al_2024/formatted_dataset.csv")
