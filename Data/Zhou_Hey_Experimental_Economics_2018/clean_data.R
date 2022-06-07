#### Zhou & Hey, "Context matters", Experimental Economics, 2019

#### cleaning data to be used for the meta-analysis

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


#### getting the data
Allo <- read_delim("Data/Zhou_Hey_Experimental_Economics_2018/original_dataset/AlloAll.txt", delim = ',', col_names = 0) %>% as_factor()
colnames(Allo) <- c("subject", "Problem number", 'Allocation in Red',
                    'Allocation in Yellow', 'Probability of Red (multiplied by 10)',
                    'Exchange Rate of Red (multiplied by 100)',
                    'Exchange Rate of Yellow (multiplied by 100)',
                    'Endowment')

BDM <- read_delim("Data/Zhou_Hey_Experimental_Economics_2018/original_dataset/BDMAll.txt", delim = ',', col_names = 0) %>% as_factor()
colnames(BDM) <- c("subject", 'Problem number', 'Certainty Equivalence or Selling Price (multiplied by 10)',
                   'LotX', 'ProbX (multiplied by 10)', 'LotY')

PC <- read_delim("Data/Zhou_Hey_Experimental_Economics_2018/original_dataset/PCAll.txt", delim = ',', col_names = 0) %>% as_factor()
colnames(PC) <- c("subject", 'problem number', 'choices (1=left,2=right,adjusted)',
                  'outcome1 of left lottery', 'probability of outcome1 of left lottery', 'outcome2 of left lottery', 'outcome1 of right lottery',
                  'probability of outcome1 of right lottery', 'outcome2 of right lotery')

PL <- read_delim("Data/Zhou_Hey_Experimental_Economics_2018/original_dataset/PLAll.txt", delim = ',', col_names = 0) %>% as_factor()
colnames(PL) <- c("subject", 'problem number', 'outcome 1 of the lottery',
                  'probability of outcome 1', 'outcome 2 of the lottery', 'amount of the certainty', 'switch point')


for (i in 1:nrow(PC)){
  if (PC$`choices (1=left,2=right,adjusted)`[i] == 1){
    (PC$`outcome1 of left lottery`)^r*0.1*PC$`probability of outcome1 of left lottery` + 
    (PC$`outcome2 of left lottery`)^r*0.1*PC$`probability of outcome2 of left lottery` -  
    (PC$`outcome1 of right lottery`)^r*0.1*PC$`probability of outcome1 of right lottery` +
    (PC$`outcome2 of right lottery`)^r*0.1*PC$`probability of outcome2 of right lottery` 
  }
  else{
    (PC$`outcome1 of right lottery`)^r*0.1*PC$`probability of outcome1 of right lottery` + 
    (PC$`outcome2 of right lottery`)^r*0.1*PC$`probability of outcome2 of right lottery` -  
    (PC$`outcome1 of left lottery`)^r*0.1*PC$`probability of outcome1 of left lottery` +
    (PC$`outcome2 of left lottery`)^r*0.1*PC$`probability of outcome2 of left lottery` 
  }
}

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
vec_left = c(vec,(PC$`outcome1 of left lottery` + PC$`outcome2 of left lottery`) / 2 / 
               (PC$`outcome1 of left lottery` + PC$`outcome2 of left lottery`) / 2 +
               (PC$`outcome1 of right lottery` + PC$`outcome2 of right lotery`) / 2)

vec_right = c(vec,(PC$`outcome1 of right lottery` + PC$`outcome2 of right lotery`) / 2 / 
                (PC$`outcome1 of left lottery` + PC$`outcome2 of left lottery`) / 2 +
                (PC$`outcome1 of right lottery` + PC$`outcome2 of right lotery`) / 2)
vec = c()
for (i in 1:nrow(PC)){
  if (PC$`choices (1=left,2=right,adjusted)`[i] == 1) {
    vec = c(vec, vec_left[i])
  }
  else {
    vec = c(vec, vec_right[i])
  }
  
}
vec


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
