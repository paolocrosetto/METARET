#### Csermely, T., & Rabas, A. (2016).
#### How to reveal people’s preferences: Comparing time consistency 
#### and predictive power of multiple price list risk elicitation methods. 
#### Journal of Risk and Uncertainty, 53(2-3), 107–136.
#### https://doi.org/10.1007/s11166-016-9247-6

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- readxl::read_excel("Data/Csermely_Rabas_JRU/original_data/Risk Results.xlsx") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(method, cluster, cat, gender, age, crra, repeated, `has CE`) 

## Filter appropriate methods and without repetitions 
df = df %>% filter(method %in% c("hlp", "eg", 'cea'), repeated == 0)

# change gender for 1 - female, 0 - male
df <- df %>% 
  mutate(gender = case_when(gender == 2 ~ 1,
                          gender == 1 ~ 0))

# change names of the methods
df <- df %>% 
  mutate(task = case_when(method == "eg" ~ "EG",
                          method == "hlp" ~ "HL",
                          method == 'cea' ~ 'CEPL')) %>% 
  select(-method, -crra, -repeated, -`has CE`)

# rename column names 
df <- df %>% 
  rename(
    subject = cluster,
    choice = cat)

# adding paper name and bibkey

df <- df %>% 
  mutate(bibkey = "Csermely2016",
         paper = "Csermely and Rabas 2016")


## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

df$country = 'Austria'
df$city = 'Vienna'
# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Csermely_Rabas_JRU/original_data/formatted_dataset.csv")
