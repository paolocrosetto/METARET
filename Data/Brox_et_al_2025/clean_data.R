#### Brox, E., Janas, M. & Renerte, B. (2025).
#### Social ties and preferences for competition.
#### Experimental Economics, 28, 274-297. https://doi.org/10.1017/eec.2025.10016
#### Data: replication package on OSF, https://doi.org/10.17605/OSF.IO/K2JTA

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## alldata_cleaned.dta from the replication package (created by 1_importandcleandata.do)
df <- read_dta("Data/Brox_et_al_2025/original_dataset.dta")

## Static BRET with 25 boxes, 20 Eurocents per box (Covariates stage).
## numboxesopened is the number of boxes the subject tagged; -1 marks the one
## subject with no recorded decision, who is dropped.
## risk7 is a 7-point self-assessment, not the 0-10 SOEP item, so it is not mapped.
df <- df %>% 
  filter(numboxesopened >= 0) %>% 
  transmute(subject = row_number(),
            choice = as.numeric(numboxesopened),
            age = as.numeric(alter),
            ## 1 - female, 0 - male
            gender = if_else(ismale == 1, 0, 1)) %>% 
  ## two impossible ages in the raw data (2 and 99) are set to missing rather than guessed
  mutate(age = if_else(age < 15 | age > 90, NA_real_, age))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "BRET",
         bibkey = "Brox2025",
         paper = "Brox et al. 2025")

## University of Konstanz
df$country = 'Germany'
df$city = 'Konstanz'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Brox_et_al_2025/formatted_dataset.csv")
