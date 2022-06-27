#####  Pablo Brañas-Garza et al. To pay or not to pay: Measuring risk preferences in lab and field

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df_spain <- read_csv("Data/Branas_2021/spain.csv")
df_honduras <- read_csv("Data/Branas_2021/honduras.csv")
df_nigeria <- read_csv("Data/Branas_2021/nigeria.csv")


##################  SPAIN ########################################
### gamma is a consistency
df_spain = df_spain %>% filter(treatment == 'Real', gamma == 1) %>%
  mutate(gender = case_when(male == 'Sí' ~ 0,
                          male == 'No' ~ 1)) %>% 
  rename(choice = RA_all,
         subject = id) %>%  
  select(subject, age, choice, gender) 
df_spain$country = 'Spain'

##################  HONDURAS ########################################
### gamma is a consistency
df_honduras = df_honduras %>% filter(consistency == 1, pay == 2) %>%
  mutate(gender = case_when(male == 1 ~ 0,
                            male == 0 ~ 1)) %>% 
  rename(choice = RA_all,
         subject = id) %>% 
  select(subject, age, choice, gender) 
df_honduras$country = 'Honduras'
##################  NIGERIA ########################################

## No variable pay or not pay BUT in article it is said that 
## Result 4: Compared to hypothetical payments in the field: Paying 1/10 of the subjects
## has no impact on consistency, number of safe choices or response time
## So we can use  all dataset
df_nigeria = df_nigeria %>% filter(consistency == 1) %>%
  mutate(female = case_when(female == 'MALE' ~ 0,
                            female == 'FEMALE' ~ 1)) %>% 
  rename(choice = RA.all,
         subject = unique.id,
         gender = female) %>%  
  select(subject, age, choice, gender) 

df_nigeria$country = 'Nigeria'

df = rbind(df_honduras, df_nigeria, df_spain)

df$task = 'HL'
# adding paper name and bibkey to all the lines 
df <- df %>% 
  mutate(bibkey = "Brañas-Garza2021",
         paper = "Brañas-Garza et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df<- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, country)
         

# Writing to file
df %>% write_csv("Data/Branas_2021/formatted_dataset.csv")
