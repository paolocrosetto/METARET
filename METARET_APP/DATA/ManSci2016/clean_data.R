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

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# cleaning the bibkey from latex tags -- could be done more elegantly with reg exp
df <- df %>% 
  separate(texbibkey, into = c("drop","keep"), sep = "\\{") %>% 
  select(-drop) %>% 
  separate(keep, into = c("bibkey", "drop"), sep = "\\}") %>% 
  select(-drop)

# since this is a meta analysis paper that groups different papers we need a metabibkey
df <- df %>% 
  mutate(metabibkey = "Meta2016")

## some choices are coded as 'half choice' -- the subject has made e.g. 1.5 choices -> DROP THEM
df <- df %>% 
  filter(choice != 1.5 & choice != 4.5 & choice != 5.5 & choice != 6.5 & choice != 7.5 )

# change to make choice in HL be the number of safe choices
df <- df %>% 
  mutate(choice = 10-choice)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(metabibkey, task, choice), get_r))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/ManSci2016/formatted_dataset.csv")
