#### Seifert, M., Spitzer, F., Haeckl, S., Gaudeul, A., Kirchler, E., Palan, S.
#### & Gangl, K. (2024). Can information provision and preference elicitation
#### promote ESG investments? Evidence from a large, incentivized online
#### experiment. Journal of Banking & Finance.
#### https://doi.org/10.1016/j.jbankfin.2024.107114
#### Data: replication package (data_replication_15.11.2022_sustainable_investment.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Incentivized online experiment on what makes people invest in ESG products,
## run in Austria in two waves: 871 retail investors (October-November 2021) and
## 1,383 respondents quota-matched to the Austrian population on age and gender
## (February 2022, through the agency Talk Online Panel). 2,254 in all, 56.7%
## men, mean age 48.2.
##
## There is NO risk elicitation task, so this is a quest_only paper. The
## questionnaire carries the financial-domain Dohmen item, quoted in Section K
## of the appendix: "How would you rate your risk preference in terms of
## financial investments? 0 = totally not risk taking to 10 = totally risk
## taking; Dohmen et al. (2011)". Being the financial version, it fills
## soep_financial and not the general soep slot.
##
## SCALE MISMATCH, RESOLVED THE WAY THE PROJECT ALREADY DOES IT. The appendix
## says 0 to 10, but the data hold exactly ten values, 1 to 10, with no zero at
## all. The package cannot settle whether the survey showed 1 to 10 or whether
## the export shifted the answers by one. The observed 1-10 range is rescaled
## linearly onto 0-10, the same treatment given to the 1-7 item of Seifert et
## al. 2026 and the 1-10 answers of Drouvelis and Qiu. Worth asking the authors.
##
## The published file is multiply imputed: .imp runs 0 to 10 over 24,794 rows.
## Only .imp == 0 is kept, the original data before imputation; none of the
## columns used here has a missing value in it.
## gender: the authors' own script labels the factor levels "gender2" =
## "Gender: male" and "gender3" = "Gender: non-binary", so with level 1 as the
## reference the coding is 1 = female, 2 = male, 3 = non-binary. That gives
## 1,278 men, 56.7% of the sample, exactly the share the paper reports. The
## four non-binary answers are left missing.
df <- read_csv("Data/Seifert_et_al_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 2254,
          all(df$risk_preference >= 1 & df$risk_preference <= 10))

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = NA_real_,
            soep_financial = (as.numeric(risk_preference) - 1) / 9 * 10,
            age = if_else(age >= 15 & age <= 100, as.numeric(age), NA_real_),
            gender = case_when(gender == 1 ~ 1, gender == 2 ~ 0, TRUE ~ NA_real_),
            bibkey = "Seifert2024",
            paper = "Seifert et al. 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## both waves are Austrian
df$country = 'Austria'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Seifert_et_al_2024/formatted_dataset.csv")
