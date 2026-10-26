#### Friedl, A., Pondorfer, A. & Schmidt, U. (2020). Gender differences in
#### social risk taking. Journal of Economic Psychology, 77, 102182.
#### https://doi.org/10.1016/j.joep.2019.06.005
#### Data: OSF, https://osf.io/xw8cy (data_gdsr.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two samples run with the same six-gamble Eckel-Grossman task: 192 university
## students in Germany (96 men, 96 women, mean age 22.21) and 156 Teop
## participants from coastal villages on Bougainville Island, Papua New Guinea
## (76 men, 80 women, mean age 39.05). Only active players were recorded.
## original_dataset.csv is data_gdsr.dta of the repository, unchanged.
##
## Each subject made the gamble choice three times: IR, where the gamble pays
## the subject alone; PCR, where a passive partner receives the same draw; and
## NCR, where the partner receives the opposite one. Only IR is an individual
## risk elicitation, so PCR and NCR are not used here. IR was always asked
## first, before the social treatments were mentioned.
##
## Task: six pairs of cards, each a 50/50 gamble, chosen physically from a bag.
## German pairs (Table 1, euro): 2.50/2.50, 3.50/2.00, 4.50/1.50, 5.50/1.00,
## 6.50/0.50, 7.00/0.00. Papua New Guinean pairs (Table A3, kina) are exactly
## twice those amounts. choice = gamble number, 1 (safe) to 6 (riskiest).
## One subject in Papua New Guinea has no IR choice and is dropped.
df <- read_csv("Data/Friedl_et_al_2020/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(ir)) %>%
  transmute(subject = row_number(),
            task = "EG",
            choice = ir,
            age,
            gender = female,
            germany = society == 1)

## the German lab is not named in the paper, so that sample carries the country
## only; the Teop villages are on Bougainville Island
df <- df %>%
  mutate(country = if_else(germany, 'Germany', 'Papua New Guinea'),
         city = if_else(germany, '', 'Bougainville'),
         lattitude = if_else(germany, '', '-5.63'),
         longitude = if_else(germany, '', '154.89')) %>%
  select(-germany)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Friedl2020",
         paper = "Friedl et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Friedl_et_al_2020/formatted_dataset.csv")
