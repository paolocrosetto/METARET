#### Red Color and Risk-Taking Behavior in Online Environments
## Timo Gnambs
#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_csv("Data/Gnambs_et_al_PLOS_2015/original_dataset.csv")

## reshaping
df <- df %>% mutate(id = row_number()) %>% gather(key, value, -id, -age, -sex, -cb) %>% 
             separate(key, into = c("dropme","var","balloon"), sep = c(4,5)) %>% select(-dropme, -cb) 

## spreading out
df %>% group_by(id, var, balloon) %>% spread(var,value) %>% select(id, age, sex, balloon, pumps = p, explosion = e) %>% 
       ungroup() %>% 
       mutate(balloon = as.integer(balloon)) %>% arrange(id, balloon) %>% 
       mutate(explosion = as.factor(explosion)) %>% 
       mutate(explosion = fct_recode(explosion, "Stopped" = "0", "Exploded" = "1")) -> df

## adding the average of the not exploded balloons to the picture
df <- df %>% 
  mutate(treatment = if_else(balloon <16, "red balloon", "blue ballonn")) %>% 
  group_by(id,age, sex, treatment, explosion) %>% 
  filter(explosion == "Stopped") %>% 
  mutate(adjmeasure = mean(pumps)) %>% 
  ungroup() %>% 
  select(id, age, sex, treatment, adjmeasure) %>% 
  distinct()

## renaming and adjusting variables
df <- df %>% 
  mutate(gender = sex - 1) %>% # 1 si female, 0 is male
  rename(choice = adjmeasure,
         subject = id) %>% 
  mutate(subject = 756000+subject)

## r assuming no burst (leap of faith actually)
df <- df %>% mutate(r = choice/(64-choice))

## name, bibkey and task
df <- df %>% 
  mutate(task = "BART",
         bibkey = "Gnambs2015",
         paper = "Gnambs et al PONE 2015")

df$country = 'Germany'
# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gnambs_et_al_PLOS_2015/formatted_dataset.csv")