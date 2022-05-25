#### J. Huber; S. Palan S. Zeisberger (2019).
#### Does investor risk perception drive asset prices in markets? Experimental evidence

#### Journal of Banking & Finance
#### https://doi.org/10.1016/j.jbankfin.2019.105635

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- readxl::read_excel("Data/HUber_et_al_2019/Huber_etal_2019_RiskMeasures.xls") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires

df <- df %>% pivot_longer(BRET, names_to = 'task', values_to = 'choice')

# rename column names 
df <- df %>% 
  rename(
    soep = RiskType1,
    soep_financial = RiskType2,
    subject = SubjectID)

# adding paper name and bibkey

df <- df %>% 
  mutate(bibkey = "Huber2019",
         paper = "Huber, Palan and Zeisberger 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/HUber_et_al_2019/formatted_dataset.csv")
