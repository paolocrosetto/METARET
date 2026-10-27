#### Bauer, M., Chytilova, J. & Miguel, E. (2020). Using survey questions to
#### measure preferences: Lessons from an experimental validation in Kenya.
#### European Economic Review, 127, 103493.
#### https://doi.org/10.1016/j.euroecorev.2020.103493
#### Data: "Replication files.7z" (Validation_Dataset.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Validation of the Global Preference Survey with low-income adults from
## Kibera, Nairobi, in the Busara Center lab: two visits a week apart, one
## with incentivized experiments and one with the survey. The qualitative
## risk item of the survey is the GPS / SOEP self-assessment on 0 to 10
## ("using a scale from 0 to 10"), s_risk_qual; it goes into soep.
##
## The task coded is the quantitative risk item of the same survey visit: the
## GPS staircase of Falk et al. (CE_staircase), hypothetical, five binary
## choices between a 50/50 draw of KSh 900 (else 0) and a sure amount. The
## variable labels of s_risk_q74 ... s_risk_q104 give the 31 sure amounts, 30,
## 60, ..., 930: the GPS tree (lottery 300, sure amounts 10 ... 310) times 3.
## The first sure amount is 480, then +-240, +-120, +-60, +-30 (up after the
## lottery, down after the sure amount). Rebuilding each path from those five
## answers gives the authors' s_risk_quant (1 ... 32) for all 123 rows, so
## choice = s_risk_quant and the CE lies in [30 (choice - 1), 30 choice] --
## the same choice-to-r mapping as Bittner2024. 13 people took the draw even
## against a sure 930 (choice 32) and 2 against a sure 900 (choice 31); as for
## Bittner2024 they are kept and coded at the bound r(870).
##
## THE INCENTIVIZED TASK IS NOT CODED YET. It is a certainty-equivalent list,
## "21 binary choices between a lottery that yielded a positive amount or zero
## with equal probability, and a safe payment option that increased in each
## subsequent binary choice" (e_risk = switching row). The prize and the 21
## safe amounts are only in the Online Appendix, which is not in the package;
## once it is at hand the rows can be filed as CEPL.
##
## 123 rows in the file, 120 people: survey_id 142149 appears four times with
## the same experimental record, risk answer, age and gender, differing only in
## other survey items, and is kept once. gender and age are taken from the
## survey visit (s_gender, s_age); four ages are missing.
df <- read_csv("Data/Bauer_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 120, all(df$risk_qual %in% 0:10), all(df$risk_quant %in% 1:32))

df <- df %>%
  transmute(subject,
            task = "CE_staircase",
            choice = risk_quant,
            soep = risk_qual,
            gender = case_when(s_gender == "Female" ~ 1, s_gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            age = s_age,
            bibkey = "Bauer2020",
            paper = "Bauer et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Busara Center, Nairobi; participants from Kibera
df$country = 'Kenya'
df$city = 'Nairobi'
df$lattitude = '-1.3133'
df$longitude = '36.7876'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bauer_et_al_2020/formatted_dataset.csv")
