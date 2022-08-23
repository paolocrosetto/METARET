#### Crosetto and Filippin, "The Bomb Risk Elicitation Task", JRU 2013

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_dta("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2013/original_dataset.dta") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% filter(rep != 1, outlier == 0) %>%
  select(subject, gender, age, treatment, perc, soep, starts_with("do"))

df$subject = 1:nrow(df)
## Computing the CRRA (x^r) coefficient of risk aversion from the task data
df <- df %>% mutate(r = perc/(100-perc))

## Task-specific adjustments

# BRET: sometimes the computed r is /0 -> hence Inf in R --> correcting
df <- df %>% mutate(r = if_else(r == Inf, 99, r))

# BRET: recode 'perc' as 'choice'
df <- df %>% rename(choice = perc)

# Adding task, paper and bibtex handles
df <- df %>% 
  mutate(task = "BRET",
         paper = "Crosetto and Filippin, JRU 2013",
         bibkey = "Crosetto2013")

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

df$country = 'Germany'
df$city = 'Jena'
# Writing to file
df %>% write_csv("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2013/formatted_dataset.csv")
