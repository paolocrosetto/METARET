#### Menkhoff and Sakha, Estimating Risky Behavior with Multiple-Item Risk Measures, Jo Econ Psy 2017

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)

#### getting the data
df <- read_dta("Data/Menkhoff_Sakha_Jo_Econ_Psy_2017/original_dataset.dta") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the tasks
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(-YEAR, -invest) %>% 
  rename(subject = QID, soep = wtr, CEPL = swr, soep_financial = wtr_finance,
         EG_loss = eckelgross, EG = eckelgross_2, IG = game4)

## this is  a within-subjects paper. There are 7 tasks (we keep 6). 
## gathering to create task variable
df <- df %>% 
  gather(task, choice, -subject, -soep, -soep_financial) %>% 
  filter(!is.na(choice))   # 3 subjects had not available chocies for at least one task, one in IG, one in EGLOSS, one in CEPL

## variable for IG game is here amount KEPT
## chanign to amount invested for consistency with other papers
df <- df %>% 
  mutate(choice = if_else(task == "IG", 100 - choice, choice))

## variable for CEPL is switching point
## converting in the NUMBER OF RISKY CHOICES -- these are defined as switching point - 1
df <- df %>% 
   mutate(choice = if_else(task == "CEPL", 21 - choice , choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Menkhoff_Sakha_2017",
         paper = "Menkhoff and Sakha 2017")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## note: IG data not yet implemented!
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

df$country = 'Thailand'
df$city = "Ubon Ratchathani"
df$longitude = "104.856117"
df$lattitude = "15.229730"

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Menkhoff_Sakha_Jo_Econ_Psy_2017/formatted_dataset.csv")
