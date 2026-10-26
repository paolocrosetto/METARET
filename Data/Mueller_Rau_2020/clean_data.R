#### Müller, S. & Rau, H. A. (2020).
#### Motivational crowding out effects in charitable giving: Experimental
#### evidence.
#### Journal of Economic Psychology, 76, 102210.
#### https://doi.org/10.1016/j.joep.2019.102210
#### Data: https://github.com/hrau1380/crowdout

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## Two laboratory studies at the University of Göttingen, programmed in z-Tree
## and recruited through ORSEE: the first with 168 subjects (82 women, 86 men)
## and the second, a replication, with 142 (80 women, 62 men). Both numbers and
## both gender splits match the paper. The two files are stacked here.
s1 <- read_excel("Data/Mueller_Rau_2020/Study1_data.xlsx") %>% mutate(study = 1)
s2 <- read_excel("Data/Mueller_Rau_2020/Study2_data.xlsx") %>% mutate(study = 2)

## Part two of each session was the Eckel and Grossman gamble choice, and the
## variable documentation says so plainly: risk is the "selected lottery (1-5)
## in the Eckel and Grossman task. Lower numbers can be interpreted as a higher
## degree of risk aversion". That is this site's EG convention, so the column
## is kept as it is.
##
## Age was not collected; female is already 1 for women.
df <- bind_rows(s1, s2) %>%
  mutate(subject = row_number()) %>%
  transmute(subject,
            task = "EG",
            choice = as.numeric(risk),
            gender = as.numeric(female),
            age = NA_real_,
            bibkey = "Mueller2020",
            paper = "Müller and Rau 2020")

## University of Göttingen.
df$country = 'Germany'
df$city = 'Göttingen'
df$lattitude = '51.5413'
df$longitude = '9.9158'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mueller_Rau_2020/formatted_dataset.csv")
