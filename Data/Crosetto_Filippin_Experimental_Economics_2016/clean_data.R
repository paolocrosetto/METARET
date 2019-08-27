#### Crosetto and Filippin, "The Bomb Risk Elicitation Task", JRU 2013

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_dta("Data/Crosetto_Filippin_Experimental_Economics_2016/original_dataset.dta") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, gender, age, treatment, perc, pump, eg, cgptotal, safechoices, inconsistent, soep, starts_with("do")) %>% 
  select(-dominated)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -inconsistent, -soep, -starts_with("do"), -treatment) %>% 
  filter(!is.na(choice))

## recoding HL as higher number -> more risk
df <- df %>% 
  mutate(choice = if_else(treatment == "hl", 10 - choice, choice))

# adding task
df <- df %>% 
  mutate(task = case_when(treatment == "bret" ~ "BRET",
                          treatment == "cgp" ~ "IG",
                          treatment == "eg" ~ "EG",
                          treatment == "hl" ~ "HL",
                          treatment == "balloon" ~ "BART"))

# removing bret as it is duplicate of the one in JRU
df <- df %>% 
  filter(treatment != "bret")

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Crosetto2016",
         paper = "Crosetto and Filippin EXEC 2016")



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
df <- df %>% mutate(r = case_when(task == "BART" ~ choice/(100-choice),
                                  task == "IG" & choice != 4 ~ (log(4-choice) - log(8+3*choice) + log(3))/(log(4-choice) +log(2) - log(8+3*choice)),
                                  task == "IG" & choice == 4 ~ 1,
                                  task == "EG" & choice == 1 ~ -1,
                                  task == "EG" & choice == 2 ~ (-1+0.33)/2,
                                  task == "EG" & choice == 3 ~ (0.33+0.62)/2,
                                  task == "EG" & choice == 4 ~ (0.62+0.8)/2,
                                  task == "EG" & choice == 5 ~ 1,
                                  task == "HL" & choice == 10 ~ 1.95,
                                  task == "HL" & choice == 9 ~ 1.95,
                                  task == "HL" & choice == 8 ~ (1.49+1.95)/2,
                                  task == "HL" & choice == 7 ~ (1.49+1.15)/2,
                                  task == "HL" & choice == 6 ~ (0.85+1.15)/2,
                                  task == "HL" & choice == 5 ~ (0.59+0.85)/2,
                                  task == "HL" & choice == 4 ~ (0.32+0.59)/2,
                                  task == "HL" & choice == 3 ~ (0.03+0.32)/2,
                                  task == "HL" & choice == 2 ~ (0.03+-0.37)/2,
                                  task == "HL" & choice == 1 ~ -0.37,
                                  task == "HL" & choice == 0 ~ -0.37))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crosetto_Filippin_Experimental_Economics_2016/formatted_dataset.csv")
