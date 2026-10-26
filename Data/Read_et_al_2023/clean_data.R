#### Read, D., McDonald, R. & Cubitt, R. (2023).
#### Comparison-specific preferences: The attentional dilution effect for delay and risk.
#### Journal of Behavioral Decision Making. https://doi.org/10.1002/bdm.2348
#### Data: https://osf.io/vqryx/ (folder "Data and do-files May 2023")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 4a. raw_data_for_sharing_Risk.dta: Experiment 2 (risk), 320 US participants on
## Prolific, one row each. Choices were hypothetical (Prolific did not allow the
## authors to pay by outcome).
df <- read_dta("Data/Read_et_al_2023/original_dataset.dta")

## Eckel and Grossman (2002) no-loss task (Interface fig. 19): five 50/50 gambles
##   16/16, 24/12, 32/8, 40/4, 48/0 dollars
## EckelGrossman = row of the chosen gamble (1 = safest).
## This file has no gender or age.
df <- df %>% 
  transmute(subject = row_number(),
            choice = as.numeric(EckelGrossman))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "EG",
         bibkey = "Read2023",
         paper = "Read et al. 2023")

## online (Prolific), US residents
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Read_et_al_2023/formatted_dataset.csv")
