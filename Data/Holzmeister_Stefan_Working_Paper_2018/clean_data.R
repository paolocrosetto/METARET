#### Holzmeister, F. & Stefan, M. (2019). The risk elicitation puzzle revisited: Across-methods (In)consistency?

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data
df <- read_xls("Data/Holzmeister_Stefan_Working_Paper_2018/original_dataset.xls")

## sum of choices can be mapped to
## BRET: number of boxes
## EG: chosen lottery
## CEPL: number of risky choices
## HL: number of risky choices
df <- df %>% 
  mutate(task = as_factor(task),
         task = fct_recode(task, "BRET" = "1", "CEPL" = "2", "HL" = "3", "EG" = "4")) %>% 
  group_by(task, pid) %>% 
  summarise(choice = sum(choice))

## recoding HL as higher number -> more risk

# adding task

# removing bret as it is duplicate of the one in JRU

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Holzmeister2019",
         paper = "Holzmeister and Stefan Working Paper 2019")

## translating CEPL and HL as number of RISKY choices
## EG goes from 0 to 5 -> translating into 1 to 6
df <- df %>% 
  mutate(choice = if_else(task == "CEPL", choice + 1, choice)) %>% 
  mutate(choice = if_else(task == "EG", choice +1, choice))



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))


# generate a numeric subect variable
df <- df %>% 
  mutate(subject = as.numeric(factor(pid, levels=unique(pid))),
         subject = 23100+subject) %>% 
  select(-pid)

# Writing to file
df %>% write_csv("Data/Holzmeister_Stefan_Working_Paper_2018/formatted_dataset.csv")
