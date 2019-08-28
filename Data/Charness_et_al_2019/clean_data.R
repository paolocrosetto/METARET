#### Charness et al, Do Measures of Risk Attitude in the Laboratory Predict Behavior under Risk in and outside of the Laboratory?, WP 2019

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/Charness_et_al_2019/original_dataset.csv")

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(-X1, -realestate, -insurance, -self_emp, -deductible, -inv_ris, -valsavings, -starts_with("P1"),
         -ins_g, -mor_g, -income) %>% 
  mutate(gender = abs(male-1)) %>% 
  select(-male) %>% 
  rename(subject = num_mem)

## this is  abetween-subjects paper. There are several tasks. 
## creating a task variable that takes the name of each of the tasks
df <- df %>% 
  mutate(task = case_when(!is.na(h_l) ~ "HL",
                          !is.na(g_p) ~ "IG",
                          !is.na(ta_1) ~ "TA",
                          !is.na(do_1) ~ "soep",
                          !is.na(e_g)  ~ "EG"))

## deleting iconsistents in HL
df <- df %>% 
  filter(mulSwitch_hl == F | is.na(mulSwitch_hl)) %>% 
  select(-mulSwitch_hl)

## assuming the HL variable is the SWITHING POINT
## we need to traslate this into the NUMBER OF SAFE CHOICES -- these are defined as switching point - 1
df <- df %>% 
  mutate(h_l = h_l - 1)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -task) %>%  
  filter(!is.na(choice))

# for the time being (aug 2019) delete Tanaka and second soep question
df <- df %>% 
  filter(task != "TA") %>% 
  filter(key != "do_2") %>% 
  select(-key)




# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Charness2019",
         paper = "Charness et al 2019")

## function to assign random parameter within bounds to HL
## note: use pmap, add one layer for the 'paper' name, and then just apply this to each and every case -- neater, better, less errors.



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## note: IG data not yet implemented!
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Charness_et_al_2019/formatted_dataset.csv")
