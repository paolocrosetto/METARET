#### Zhou & Hey, "Context matters", Experimental Economics, 2019

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires



## recoding HL as higher number -> more risk

# adding task

# removing bret as it is duplicate of the one in JRU

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Zhou2018",
         paper = "Zhou and Hey Experimental Economics 2018")



## Computing the CRRA (x^r) coefficient of risk aversion from the task data



# Order of variables

# Writing to file
df %>% write_csv("Data/Zhou_Hey_Experimental_Economics_2018/formatted_dataset.csv")
