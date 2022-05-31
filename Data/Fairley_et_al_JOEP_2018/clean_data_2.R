#### K. Fairley, J. M.Parelman, M. Jones, R. McKell Carter (2019).
#### Risky health choices and the Balloon Economic Risk Protocol
#### https://doi.org/10.1016/j.joep.2019.04.005

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/Fairley_et_al_JOEP_2018/DataFiles/results_with_questionnaires.csv") %>% as_factor()


## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires

df = df %>% select(-firstcash, -MRI) 
df$AuditS.ASscore
# rename column names 
df <- df %>% 
  rename(
    'BART' = 'Alone',
    'BERP' = 'BeliefBalloon',
    'subject' = 'Participant',
    'age' = 'What.is.your.age.',
    'gender' = 'What.is.your.gender.',
    'race' = 'Which.best.describes.your.race.',
    'etnicity' = 'Which.best.describes.your.ethnicity.',
    'educ_level' = 'Which.best.describes.your.formal.education.',
    'CDCrisk' = 'CDCrisk.CDCscore',
    'Druguse' = 'Druguse.Drugstotal_A',
    'BIS' = 'BIS.BISscore',
    'BSSS' = 'BSSS.BSSSscore',
    'AuditS' = 'AuditS.ASscore')

# create a column of tasks and choices
df <- df %>% pivot_longer(c(BART, BERP), names_to = 'task', values_to = 'choice')


# change gender for 1 - female, 0 - male
df <- df %>% 
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0))

# adding paper name and bibkey

results <- df %>% 
  mutate(bibkey = "Fairley2019",
         paper = "Fairley and Parelman 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data

results <- results %>% mutate(r = choice/(MaxBalloonSize-choice))

# Order of variables
results <- results %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
results %>% write_csv("Data/Fairley_et_al_JOEP_2018/DataFiles/formatted_dataset.csv")
