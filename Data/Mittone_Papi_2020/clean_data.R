#### Mittone, L. & Papi, M. (2020). Inducing alternative-based and
#### characteristic-based search procedures in risky choice.
#### Judgment and Decision Making, 15(3), 371-380.
#### https://doi.org/10.1017/S1930297500007178
#### Data: supplementary file S1930297500007178sup001.xlsx

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment at CEEL, University of Trento, five dates between
## April 2017 and November 2018, 226 subjects (76 ABS, 72 CBS, 78 Baseline).
## Task 1, common to all treatments, is the BRET: "In the experiment we set
## n = 100 and a equal to 3 euro cents" (supplement sup002), static version
## (subjects state how many boxes to collect, 0 to 100). Task 2 -- lotteries
## with induced search procedures -- comes after and is not used.
## The shared 100-box BRET rule of generate_r.R applies.
##
## The file is one row per lottery problem, 18 per subject; BRET, gender
## (F = 1) and age are repeated. One nickname has 17 rows with male, 21, 34
## boxes and one row with female, 22, 25 boxes: the modal row is kept.
df <- read_csv("Data/Mittone_Papi_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 226, all(df$bret >= 0 & df$bret <= 100),
          sum(df$treatment == "ABS") == 76, sum(df$treatment == "CBS") == 72)

df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = bret,
            gender = female,
            age,
            bibkey = "Mittone2020",
            paper = "Mittone and Papi 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## CEEL, Trento
df$country = 'Italy'
df$city = 'Trento'
df$lattitude = '46.0664'
df$longitude = '11.1257'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mittone_Papi_2020/formatted_dataset.csv")
