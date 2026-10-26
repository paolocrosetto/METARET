#### Lima de Miranda, K., Detlefsen, L. & Schmidt, U. (2025).
#### Can gender diversity prevent risky choice shifts? The effect of gender composition
#### on group decisions under risk. Experimental Economics. https://doi.org/10.1017/eec.2024.4
#### Data: replication package on OSF, https://osf.io/2wp4z/ (view-only link given in the paper)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## Two treatments: GF (2015), where groups of three first agree on a lottery and each
## member then chooses alone, and IF (2020), where each subject first chooses alone
## and the group decides afterwards. In GF the individual choice comes after the group
## discussion and is shaped by it, so only the IF treatment is used here
## (Data_Treatment2.xlsx, 237 subjects, Kiel).
## one age is recorded as the text "N/A"
df <- read_excel("Data/LimaDeMiranda_et_al_2025/original_dataset_IF.xlsx", na = c("", "N/A"))

## Eckel-Grossman task, individual card (page 19 of 'Experiment and Questionnaire.pdf'):
## six 50/50 coins, in euros, 4/4, 5/3.50, 6/3, 7/2.50, 8/2, 9/1.
## EINZEL_ENT = chosen coin (1 = safest). FEMALE: 1 woman, 0 man. ALTER = age;
## one age of 13 is set to missing. The risk self-assessment is on a 1-5 scale,
## not the SOEP 0-10 item, so it is not mapped.
df <- df %>% 
  transmute(subject = as.numeric(subject),
            choice = as.numeric(EINZEL_ENT),
            age = if_else(as.numeric(ALTER) < 15, NA_real_, as.numeric(ALTER)),
            gender = as.numeric(FEMALE))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "EG",
         bibkey = "LimaDeMiranda2025",
         paper = "Lima de Miranda et al. 2025")

## Kiel
df$country = 'Germany'
df$city = 'Kiel'
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
df %>% write_csv("Data/LimaDeMiranda_et_al_2025/formatted_dataset.csv")
