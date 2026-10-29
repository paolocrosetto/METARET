#### Casal, S. & Filippin, A. (2024).
#### The effect of observing multiple private information outcomes on the
#### inclination to cheat.
#### Economic Inquiry, 62(2), 543-562. https://doi.org/10.1111/ecin.13197
#### Data: openICPSR, https://doi.org/10.3886/E194601V3 (README: "The data are
#### licensed under a Creative Commons/CC-BY-NC-SA license"), dataset/all.csv.
#### original_dataset.csv keeps only the lab, session date, treatment, the lab
#### id, the BRET choice, age and gender; the exam grades, the cheating claims
#### and the other tasks are not copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "A total of 668 subjects took part in the experiment, 360 in the first wave
## and 308 in the second." Wave 1: "between January 2018 and February 2019 at
## the University of Milan (Italy)" (z-Tree); wave 2: "between April 2022 and
## May 2023, at the University of Trento (Italy)" (oTree). The treatments vary
## the cheating task (1-Uniform, 10-Uniform, 1-Normal), not the BRET.
df <- read_csv("Data/Casal_Filippin_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 668, sum(df$lab == "MI") == 360, sum(df$lab == "TN") == 308)

## The task: "Participants are presented with a 10 x 10 square in which each
## cell represents a box: 99 boxes contain 1 ECU, while one contains a time
## bomb. Participants choose how many boxes to collect ... if the bomb is
## collected earnings will be zero", the static BRET of Crosetto and Filippin
## (2013); earnings in ECU are part of the payment. choice = choicebret, the
## number of boxes collected (1 ... 88 here).
## gender: "0 -> Male, 1 -> Female" (README).
df <- df %>%
  transmute(subject = row_number(),
            task = "BRET",
            choice = choicebret,
            age = as.numeric(age),
            gender = gender,
            treatment = paste(Treatment, if_else(lab == "MI", "Milan", "Trento")),
            milan = lab == "MI")
stopifnot(all(df$choice >= 1 & df$choice <= 100))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Casal2024",
         paper = "Casal and Filippin 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Laboratories of the University of Milan (Department of Economics, Via
## Conservatorio) and of the University of Trento (Department of Economics and
## Management, Via Inama).
df <- df %>%
  mutate(country = 'Italy',
         city = if_else(milan, 'Milan', 'Trento'),
         lattitude = if_else(milan, '45.4640', '46.0665'),
         longitude = if_else(milan, '9.2010', '11.1262')) %>%
  select(-milan)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Casal_Filippin_2024/formatted_dataset.csv")
