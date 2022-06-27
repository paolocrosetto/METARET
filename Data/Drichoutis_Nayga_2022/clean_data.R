## Andreas Drichoutis et Rodolfo M. Nayga
## On the stability of risk and time preferences amid the COVID-19 pandemic".

#### libraries
library(haven)
library(tidyverse)
library(broom)
library(dplyr)
library(lubridate)

df <- read_dta("Data/Drichoutis_Nayga_2022/osfstorage-archive/data.dta")

### Filter only first wave, prepare df for calculating crras
data = df %>% filter(year == '2019', wave == 3) %>%
  select(AM, choices, Vprizeb1, time1, time2, starts_with("bis"), risk,
         riskinvestment, gender, byear) %>% rename(
           soep = risk,
           soep_financial = riskinvestment,
           soep_patience = time1,
           soep_impulsive = time2) %>% 
  mutate(age = 2019 - byear)  %>%
  drop_na() 

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
  if(data$AM[i] == data$AM[i+1] & data$task[i] == data$task[i+1] & data$choices[i] == 1 & data$choices[i+1] == 0 | data$choices[i+1] == -1){
    data$nonconsistent[i] = 1
  }
}


## to check if there are -1 left in the dataset -> no
drichoutis = data %>% mutate(choices = case_when(choices == -1 ~ 200,
                                                 choices == 1 ~ 1,
                                                 choices == 0 ~ 0)) %>%
  group_by(AM, task) %>% 
  summarise(choice = sum(choices), n = sum(nonconsistent)) %>%
  filter(n == 0)

# adding paper name and bibkey
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2022",
         paper = "Drichoutis et Nayga 2022")

source("Data/generate_r.R")
drichoutis <- drichoutis %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

drichoutis =  drichoutis %>% 
  right_join(data %>%
   group_by(AM, task) %>% 
   summarise(across(c(starts_with('soep'), age, gender), ~ mean(.x, na.rm = TRUE))), by = c('task', 'AM')) %>%
  rename(subject = AM) %>% 
  # change gender for 1 - female, 0 - male
  mutate(gender = case_when(gender == 0 ~ 1,
                            gender == 1 ~ 0))

# adding paper name and bibkey to all the lines 
drichoutis <- drichoutis %>% 
  mutate(bibkey = "DrichoutisNayga2022",
         paper = "Drichoutis et Nayga 2022")
drichoutis$country = 'Greece'
# Order of variables
drichoutis <- drichoutis %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
drichoutis %>% write_csv("Data/Drichoutis_Nayga_2022/formatted_dataset.csv")

