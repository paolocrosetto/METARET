#### Rommel, J., Sagebiel, J., Baaken, M. C., Barreiro-Hurlé, J., Bougherara, D.,
#### Cembalo, L., Cerjak, M., Čop, T., Czajkowski, M., et al. (2023).
#### Farmers' risk preferences in 11 European farming systems: A multi-country
#### replication of Bocquého et al. (2014).
#### Applied Economic Perspectives and Policy, 45(3), 1374-1399.
#### https://doi.org/10.1002/aepp.13330
#### Data: https://github.com/sagebiej/riskreplication (data/allcountrydata.csv;
#### no licence set on the repository). The readme and the code that defines and
#### reads the lists are in raw_repository/; original_dataset.csv keeps only the
#### ids, country, survey channel, the three list answers, sex and age.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## allcountrydata.csv has the 1,430 farmers of the 11 replication samples
## (Austria, Croatia, France I and II, Germany, Italy, Netherlands, Poland,
## Slovenia, Spain, Sweden) and the 107 farmers of the original Bocquého et al.
## (2014) study (Country "BJR2014"), which belong to that paper and are left out
## (when the file was reduced to original_dataset.csv).
df <- read_csv("Data/Rommel_et_al_2023/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 1430)

## The task (Tanaka et al. 2010 as adapted by Bocquého et al. 2014), three
## series, in points converted to money at a sample-specific rate announced in
## advance ("We used a common point system ... We adjusted exchange rates
## between points and monetary rewards"; some samples paid a random fraction of
## participants). Only series 1 is used here (functions.R, genDesign):
##   option A: 30% 400, 70% 100 points;
##   option B: 10% X, 90% 50 points, X = 680, 750, 830, 930, 1060, 1250, 1500,
##             1850, 2200, 3000, 4000, 6000 in rows 1-12.
## A pays the same in every row and B's high prize rises, so it is a
## payoff-varying list (PV). Series 2 is a second PV list with other
## probabilities and series 3 mixes gains and losses (loss aversion).
## series_1_question is the number of rows in which A is chosen ("ChooseA = ...
## serieslotteryNo <= series_1_question", ML estimation.R); the switch is
## enforced, so there is a single switch. choice = number of B choices.
## Points are converted at a fixed rate, and u = x^r does not depend on the
## scale, so the same bounds hold for every sample.
## Sex: "Females" / "Males" (134 missing); Age in years (59 missing).
df <- df %>%
  transmute(subject = row_number(),
            age = as.numeric(Age),
            gender = case_when(Sex == "Females" ~ 1, Sex == "Males" ~ 0),
            task = "PV",
            choice = 12 - series_1_question,
            treatment = str_replace(Country, "_", " "),
            country = str_remove(Country, "_.*$"))
stopifnot(all(df$choice %in% 0:12))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Rommel2023",
         paper = "Rommel et al. 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Farming-system samples spread over regions (online and face-to-face; e.g.
## "wine growers in Croatia", "young farmers in Slovenia", "olive growers in
## Apulia"), so no city and no coordinates.
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Rommel_et_al_2023/formatted_dataset.csv")
