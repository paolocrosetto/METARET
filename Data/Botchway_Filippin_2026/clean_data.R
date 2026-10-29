#### Botchway, E. & Filippin, A. (2026).
#### Persistent risk of natural disasters fosters cooperation.
#### Journal of Risk and Uncertainty, 73, 27-59.
#### https://doi.org/10.1007/s11166-026-09488-8
#### Data: Mendeley Data, "Persistent Risk Data" (Botchway 2025),
#### https://doi.org/10.17632/mcm254x3p3.1 (CC BY 4.0), one file,
#### Final_Data_Antonio_Ebo.dta. original_dataset.csv keeps only the household
#### code, community, flood exposure, age and the BRET choice; the farm, income,
#### willingness-to-pay and public-good columns are not copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "The experiment took place in September 2017 in the Tolon-Kumbungu district,
## in the Northern part of Ghana, and involved 200 participants in 10 different
## communities", 20 farmers in each; location is "Treatment" for the
## communities exposed to recurrent floods and "Control" for the others (100
## each). The file has no gender variable.
df <- read_csv("Data/Botchway_Filippin_2026/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 200, n_distinct(df$community) == 10)

## The task: "we administer a further simplified version of the Bomb Risk
## Elicitation Task (Crosetto and Filippin, 2013) ... participants are presented
## a winding road ... in which participants earn 0.5 Ghana cedi for every step
## taken in numerical order, with a time bomb hidden behind one (and only one)
## of the 100 steps"; one task, drawn at the end, was paid. boxsel = "Number of
## Steps Taken in the Minefield" (3 ... 95), the static BRET with 100 boxes.
df <- df %>%
  transmute(subject = row_number(),
            task = "BRET",
            choice = boxsel,
            age = age,
            treatment = if_else(location == "Treatment", "flood-exposed communities", "control communities"))
stopifnot(all(df$choice >= 1 & df$choice <= 100))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Botchway2026",
         paper = "Botchway and Filippin 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Tolon-Kumbungu district, Northern Region; the coordinates are those of
## Tolon, the district capital.
df$country = 'Ghana'
df$city = 'Tolon'
df$lattitude = '9.4306'
df$longitude = '-1.0655'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Botchway_Filippin_2026/formatted_dataset.csv")
