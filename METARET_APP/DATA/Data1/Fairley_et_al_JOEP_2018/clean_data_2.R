#### K. Fairley, J. M.Parelman, M. Jones, R. McKell Carter (2019).
#### Risky health choices and the Balloon Economic Risk Protocol
#### https://doi.org/10.1016/j.joep.2019.04.005

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/Fairley_et_al_JOEP_2018/DataFiles/BERPdata.csv") %>% as_factor()
quest <- read_csv("Data/Fairley_et_al_JOEP_2018/DataFiles/Questionnaire.csv") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires

df %>% select(-firstcash) 

## choosing age, gender, ethical, as well as financial, health/safety, social
## and recreational risks
quest <- quest %>% 
  select(What.is.your.age., What.is.your.gender., What.is.your.subject.ID.,
         ) 
# rename column names 
df <- df %>% 
  rename(
    'BART' = 'Alone',
    'BERP' = 'BeliefBalloon',
    'subject' = 'Participant')

quest <- quest %>% 
  rename(
    'age' = 'What.is.your.age.',
    'gender' = 'What.is.your.gender.',
    'subject' = 'What.is.your.subject.ID.')

# create a column of tasks and choices
df <- df %>% pivot_longer(c(BART, BERP), names_to = 'task', values_to = 'choice')

results<-merge(x=df, y=quest, by= 'subject', all.x=TRUE)

# change gender for 1 - female, 0 - male
results <- results %>% 
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0))

# adding paper name and bibkey

results <- results %>% 
  mutate(bibkey = "Fairley2019",
         paper = "Fairley and Parelman 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data

results <- results %>% mutate(r = choice/(MaxBalloonSize-choice))

# Order of variables
results <- results %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r)

# Writing to file
results %>% write_csv("Data/Fairley_et_al_JOEP_2018/DataFiles/formatted_dataset.csv")
