#### Angrisani, M., Cipriani, M., Guarino, A., Kendall, R. & Ortiz de Zárate Pina, J. (2026).
#### Risk preferences at the time of COVID-19: An experiment with professional
#### traders and students.
#### Journal of Behavioral and Experimental Finance, 50, 101185.
#### https://doi.org/10.1016/j.jbef.2026.101185
#### Data: https://github.com/cipriani-marco/risk-preferences-covid-experiment
#### (README, do-file and analysis_data.dta in raw_repository/; the COVID
#### infection answers and the traders' employer and job descriptions are removed
#### from the data)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## analysis_data.dta: one row per subject and wave. Wave 1 is the Pre-COVID
## Treatment, in the laboratory in 2019; wave 2 the COVID Treatment, online in
## April 2020, with the same people. The site keeps one observation per subject
## and task, so only wave 1 is used: the 2019 recruits, "56 professional
## traders and 79 undergraduate students" (exp == "Trade"; pro = 1 trader).
## exp == "CGH1" are students of another experiment whom Replication_Code.do
## drops, and the wave-2 rows with no exp are not in the paper.
df <- read_dta("Data/Angrisani_et_al_2026/original_dataset.dta") %>%
  zap_labels() %>%
  filter(wave == 1, exp == "Trade")
stopifnot(nrow(df) == 135, sum(df$pro == 1) == 56, !anyDuplicated(df$subject))

## The BRET (Crosetto and Filippin 2013) with 100 boxes, 1 to 99 may be
## opened, 20 pence per box, the bomb described as an "empty box". bret is the
## number of boxes collected. male: 1 man; on this site gender is 1 for women.
df <- df %>%
  transmute(subject = row_number(),
            age = age,
            gender = 1 - male,
            task = "BRET",
            choice = bret,
            treatment = if_else(pro == 1, "traders", "students"))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Angrisani2026",
         paper = "Angrisani et al. 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "traders and portfolio managers working in the city of London (UK); ii) UCL
## undergraduate students"; in 2019 "participants came into the experimental
## laboratory" -- the ELSE lab of University College London.
df$country = 'United Kingdom'
df$city = 'London'
df$lattitude = '51.5246'
df$longitude = '-0.1340'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Angrisani_et_al_2026/formatted_dataset.csv")
