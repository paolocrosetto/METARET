#### Charness, G., Chemaya, N. & Trujano-Ochoa, D. (2023). Learning your own
#### risk preferences. Journal of Risk and Uncertainty, 67, 1-19.
#### https://doi.org/10.1007/s11166-023-09413-3
#### Data: GitHub learning_risk_preferences_data (ExperienceRisk.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment at the Experimental and Behavioral Economics Lab of
## UC Santa Barbara, April 2022, 99 participants recruited through ORSEE.
## Six 50/50 gambles, "a slight modification of the Dave et al. (2010) version
## of the original Eckel and Grossman (2002, 2008) mechanism" (Table 1, in
## points worth $0.15): 28/28, 24/36, 20/44, 16/52, 12/60, 2/66. Cuts in the
## Charness2023 block of generate_r.R.
##
## Each person chose a gamble, then made 24 practice rolls (12 with the row
## preset, 12 freely chosen), then chose again; one of the two choices was
## paid. Gamble.1 -- the first choice, made before any experience -- is the
## one comparable with the rest of the site; Gamble.2 stays in
## original_dataset.csv.
##
## Gender is F / M.
df <- read_csv("Data/Charness_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 99, all(df$gamble_first %in% 1:6))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = gamble_first,
            gender = case_when(gender == "F" ~ 1, gender == "M" ~ 0, TRUE ~ NA_real_),
            age,
            bibkey = "Charness2023",
            paper = "Charness et al. 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## UC Santa Barbara
df$country = 'United States'
df$city = 'Santa Barbara'
df$lattitude = '34.4140'
df$longitude = '-119.8489'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Charness_et_al_2023/formatted_dataset.csv")
