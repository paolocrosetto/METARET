#### Crosetto and Filippin, "A Reconsideration of Gender Differences in Risk Attitudes", ManSci 2016

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/ManSci2016/original_dataset.csv")

## getting only the data from HL replications:
df <- df %>% 
  filter(safe == 0) %>%    # dropping the papers using a safe option -- i.e. a different task
  filter(ID >= 0) %>%      # keeping only published papers (this needs updating)
  filter(incons_subj == 0) # dropping inconsistent subjects
  
## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, female, age, treatment, totsafe, 
         texbibkey, bibdisplay)

# rename totsafe as 'choice';
df <- df %>% 
  rename(choice = totsafe,
         paper = bibdisplay,
         gender = female) 

# assign HL as task
df <- df %>% 
  mutate(task = "HL")

## recoding HL as higher number -> more risk
df <- df %>% 
  mutate(choice = 10 - choice)

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# cleaning the bibkey from latex tags -- could be done more elegantly with reg exp
df <- df %>% 
  separate(texbibkey, into = c("drop","keep"), sep = "\\{") %>% 
  select(-drop) %>% 
  separate(keep, into = c("bibkey", "drop"), sep = "\\}") %>% 
  select(-drop)



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
df <- df %>% mutate(r = case_when(task == "HL" & choice == 10 ~ 1.95,
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
df %>% write_csv("Data/ManSci2016/formatted_dataset.csv")
