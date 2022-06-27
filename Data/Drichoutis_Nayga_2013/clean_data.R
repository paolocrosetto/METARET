## Andreas Drichoutis et Rodolfo M. Nayga 2013
## Eliciting risk and time preferences under induced mood states

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Drichoutis_Nayga_2013/DN_JSE_2013.dta")

data = df %>% filter(DelayedP == 0) 

## creating the task column and label it
data$task = 'NA'
for (i in 1:nrow(data)){
  if (data$Vprizeb1[i] == data$Vprizeb1[1]){
    data$task[i] = 'HL'
  }
  else{
    data$task[i] = 'PV'
  }
}

## Filtering the inconsistency 
data$nonconsistent = 0
for (i in 2:nrow(data)-1){
  if(data$Subject[i] == data$Subject[i+1] & data$task[i] == data$task[i+1] & data$choices[i] == 1 & data$choices[i+1] == 0){
    data$nonconsistent[i] = 1
  }
}

## to check if there are -1 left in the dataset -> no
drichoutis = data %>%
  group_by(Subject, task) %>% 
  summarise(choice = sum(choices), n = sum(nonconsistent)) %>%
  filter(n == 0, choice < 11)

# adding paper name and bibkey
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2013",
         paper = "Drichoutis et Nayga 2013")

source("Data/generate_r.R")
drichoutis <- drichoutis %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

drichoutis =  drichoutis %>% 
  left_join(data %>%
               group_by(Subject, task) %>% 
               summarise(across(c(age, gender), ~ mean(.x, na.rm = TRUE))), by = c('task', 'Subject')) %>%
  rename(subject = Subject) %>% 
  # change gender for 1 - female, 0 - male
  mutate(gender = case_when(gender == 0 ~ 1,
                            gender == 1 ~ 0))

# Order of variables
drichoutis <- drichoutis %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r)
drichoutis$country = 'Greece'
# Writing to file
drichoutis %>% write_csv("Data/Drichoutis_Nayga_2013/formatted_dataset.csv")
