#### Riley, E. (2024). Resisting social pressure in the household using mobile
#### money: Experimental evidence on microenterprise investment in Uganda.
#### American Economic Review, 114(5), 1415-1447.
#### https://doi.org/10.1257/aer.20220717
#### Data: openICPSR, https://doi.org/10.3886/E194886
#### (baseline_disbursement_cleaned.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Randomized controlled trial with 3,000 female microenterprise owners who were
## clients of BRAC Uganda in the Kampala and Entebbe areas and were applying for
## a new loan. The treatments changed how the loan was disbursed (cash, a mobile
## account, or disbursement onto it); the baseline survey ran before any of that.
## The randomized sample in this file is 2,959 women, on average 35 years old.
##
## The baseline survey included a Gneezy-Potters investment task, worded in the
## project's own questionnaire (questionnaires/baseline.xlsx) as: "You have USH
## 8000 to invest or keep. If you invest an amount, with probably 1/2 the amount
## will be multiplied by 4 and with probability 1/2 you will get nothing." The
## parameters are in the Riley2024 block of generate_r.R.
## The same question appears twice in the instrument, as risk1 and risk2, placed
## at two randomly assigned points in the survey (the c_risk variable splits the
## sample); risk_base is the two put together and is complete for all 2,959.
##
## The BASELINE measurement is used, since it was taken before the loan was
## disbursed and so cannot carry any treatment effect. The endline survey
## repeated the task eight months later and is left aside.
## gender: the study population is female microfinance clients only, so every
## subject is coded 1. age: the authors' respondent_age, missing for 5 women.
## Note that the switch_1 ... switch_8 variables in this package are NOT a risk
## list; they are the "hiding money" game about sharing with a spouse.
df <- read_csv("Data/Riley_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 2959, all(df$risk >= 0 & df$risk <= 8000), !any(is.na(df$risk)))

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = risk,
            age,
            gender = 1,
            country = "Uganda")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Riley2024",
         paper = "Riley 2024")

## six BRAC branches in the Kampala and Entebbe areas
df$city = 'Kampala'
df$lattitude = '0.3476'
df$longitude = '32.5825'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Riley_2024/formatted_dataset.csv")
