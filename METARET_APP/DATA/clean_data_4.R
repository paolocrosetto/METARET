#### W. Zhou, J. Hey (2018).
#### Hontext matters
#### 
#### https://doi.org/10.1007/s10683-017-9546-z

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


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

df <- df %>% 
  select(method, cluster, cat, gender, age, crra, repeated) 

## Filter appropriate methods 
df = df %>% filter(method %in% c("hlp", "eg"))

# change gender for 1 - female, 0 - male
df <- df %>% 
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0))

# change names of the methods
df <- df %>% 
  mutate(task = case_when(method == "eg" ~ "EG",
                          method == "hlp" ~ "HL")) %>%  select(-method)

# rename column names 
df <- df %>% 
  rename(
    r = crra,
    subject = cluster,
    choice = cat)

# adding paper name and bibkey

df <- df %>% 
  mutate(bibkey = "Csermely2016",
         paper = "Csermely and Rabas 2016")



# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Csermely_Rabas_JRU/original_data/formatted_dataset.csv")
