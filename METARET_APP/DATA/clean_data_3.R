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

df <- df %>% mutate(r = choice/(100-choice))
# rename column names 
df <- df %>% 
  rename(
    r = crra,
    subject = cluster,
    choice = cat)

# adding paper name and bibkey

df <- df %>% 
  mutate(bibkey = "Csermely2016",
         paper = "Csermely and Rabas 2016")



# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Csermely_Rabas_JRU/original_data/formatted_dataset.csv")
