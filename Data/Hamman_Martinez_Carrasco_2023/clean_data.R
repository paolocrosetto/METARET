#### Hamman, J. R. & Martinez-Carrasco, M. A. (2023). Managing Uncertainty: An
#### Experiment on Delegation and Team Selection. Organization Science, 34(6),
#### 2272-2295. https://doi.org/10.1287/orsc.2021.1545
#### Data: OSF, https://osf.io/f6ypk (OS-data_code_expmaterials.zip,
#### alldata_complete.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## z-Tree experiment on delegation in three-person teams, 16 sessions: six at
## Pompeu Fabra University in Barcelona and ten at the Experimental Science at
## Florida State laboratory. 354 subjects, 126 in Spain and 228 in the United
## States. The repository file is a panel of rounds; original_dataset.csv keeps
## one row per subject, identified as the authors do by country, order,
## treatment, subject number and day, with the gamble choice and the sex
## answer. The gamble is constant within every subject.
##
## Task: the Eckel-Grossman gamble choice asked after the main task, five 50-50
## gambles. The screen in the repository's experimental materials lists them as
## 100/100, 180/60, 260/20, 340/-20, 420/-60 for a session with doubled stakes;
## the payoffs stored in the data are exactly half of those, 50/50, 90/30,
## 130/10, 170/-10, 210/-30, and matching gamble to realised payoff reproduces
## the table row by row. choice = gamble number, 1 (safe) to 5 (riskiest).
##
## The questionnaire recorded sex in English at Florida State and in Spanish at
## Pompeu Fabra. Age was asked in brackets (edad): 18-20, 21-23, 24-26 and
## "27 and above" ("27 y mas" in Spanish). In the csv, edad and sex are blank
## for seven Spanish subjects of order cd, treatment 20; the authors' FinalCode.do
## fills both by hand ("Completing the Spanish Database"), and
## original_dataset.csv carries those corrections. 14 subjects are still blank
## on sex and on age.
## age = bracket midpoint (19, 22, 25), as for Burro2026; the open top bracket
## is coded 28, the middle of a 27-29 bracket of the same width.
df <- read_csv("Data/Hamman_Martinez_Carrasco_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "EG_loss",
            choice = gamble,
            age = case_when(edad == "18 - 20" ~ 19, edad == "21 - 23" ~ 22,
                            edad == "24 - 26" ~ 25, edad == "27 and above" ~ 28,
                            TRUE ~ NA_real_),
            gender = case_when(sex %in% c("Female", "Femenino") ~ 1,
                               sex %in% c("Male", "Masculino") ~ 0,
                               TRUE ~ NA_real_),
            spain = country_raw == "Spain")

df <- df %>%
  mutate(country = if_else(spain, 'Spain', 'United States'),
         city = if_else(spain, 'Barcelona', 'Tallahassee'),
         lattitude = if_else(spain, '41.3851', '30.4383'),
         longitude = if_else(spain, '2.1734', '-84.2807')) %>%
  select(-spain)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Hamman2023",
         paper = "Hamman and Martinez-Carrasco 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hamman_Martinez_Carrasco_2023/formatted_dataset.csv")
