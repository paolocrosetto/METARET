#### Holzmeister, F. & Stefan, M. (2019). The risk elicitation puzzle revisited: Across-methods (In)consistency?

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data
df <- read_xls("Data/Holzmeister_Stefan_Working_Paper_2018/original_dataset.xls")

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
  mutate(bibkey = "Holzmeister2019",
         paper = "Holzmeister and Stefan Working Paper 2019")



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
df <- df %>% mutate(r = case_when(task == "BRET" ~ choice/(100-choice),
                                  task == "Investment Game" & choice != 4 ~ (log(4-choice) - log(8+3*choice) + log(3))/(log(4-choice) +log(2) - log(8+3*choice)),
                                  task == "Investment Game" & choice == 4 ~ 1,
                                  task == "Binswanger" & choice == 1 ~ -1,
                                  task == "Binswanger" & choice == 2 ~ (-1+0.33)/2,
                                  task == "Binswanger" & choice == 3 ~ (0.33+0.62)/2,
                                  task == "Binswanger" & choice == 4 ~ (0.62+0.8)/2,
                                  task == "Binswanger" & choice == 5 ~ 1,
                                  task == "Holt & Laury" & choice == 0 ~ 1.95,
                                  task == "Holt & Laury" & choice == 1 ~ 1.95,
                                  task == "Holt & Laury" & choice == 2 ~ (1.49+1.95)/2,
                                  task == "Holt & Laury" & choice == 3 ~ (1.49+1.15)/2,
                                  task == "Holt & Laury" & choice == 4 ~ (0.85+1.15)/2,
                                  task == "Holt & Laury" & choice == 5 ~ (0.59+0.85)/2,
                                  task == "Holt & Laury" & choice == 6 ~ (0.32+0.59)/2,
                                  task == "Holt & Laury" & choice == 7 ~ (0.03+0.32)/2,
                                  task == "Holt & Laury" & choice == 8 ~ (0.03+-0.37)/2,
                                  task == "Holt & Laury" & choice == 9 ~ -0.37,
                                  task == "Holt & Laury" & choice == 10 ~ -0.37))


# Order of variables

# Writing to file
df %>% write_csv("Data/Holzmeister_Stefan_Working_Paper_2018/formatted_dataset.csv")
