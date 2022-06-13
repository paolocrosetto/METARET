#### Eyal Ert, Ernan Haruvy (2017).
#### Revisiting risk aversion: Can risk preferences change with experience?
#### Economics Letters 151, 91-95

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- readxl::read_excel("Data/Eyal/EyalCombined.xlsx") %>% as_factor()
df <- df[order(df$Period),]
df$subj_id = rep(seq(1, 60), 200)

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires

### Also filter the first period for now
df <- df %>% 
  select(subj_id, Period, LotteryChosen, gender) %>% filter(Period == 1)

## add column with a method used
df$task = 'HL'

# change gender for 1 - female, 0 - male and rename column names 
df <- df %>% 
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0)) %>% 
  rename(
    subject = subj_id,
    choice = LotteryChosen)


# adding paper name and bibkey

df <- df %>% 
  mutate(bibkey = "ErtHaruvy2017",
         paper = "Ert and Haruvy 2017")


source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, gender, choice, r)
df$country = 'Israel'
# Writing to file
df %>% write_csv("Data/Eyal/formatted_dataset.csv")
