## Cognitive abilities and risk-taking: Errors, not preferences
## Luis Amador, Pablo Brañas-Garz
## 2022 

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Amador_Hidalgo_2021/data file.dta")

df = df %>% 
  select(starts_with('rp'), edad, female, -rp_factor) %>%
  drop_na()  %>% 
  mutate(subject = 1:nrow(.)) %>% 
  mutate_at(
    vars(starts_with('rp'), starts_with('la')),
    funs(case_when(
      . == "1" ~ 0,
      . == "2" ~ 1))) %>% 
  rename(gender = female)

## Filtering the inconsistency 
df$nonconsistent_hl = 0
for (i in 1:9){
  for (j in 1:nrow(df)){
  if(grepl("rp", colnames(df[,i])) & pull(df[j,i]) == 1 & pull(df[j,i+1]) == 0){
    df$nonconsistent_hl[j] = 1
  }
 }
}


df = df %>% 
  rowwise() %>% 
  summarise(
    HL = sum(c_across(contains("rp"))),
    age = mean(edad),
    subject = mean(subject),
    nonconsistent_hl = sum(nonconsistent_hl),
    gender = mean(gender)) %>% 
  pivot_longer(-c(subject, age, gender, nonconsistent_hl), names_to = "task", values_to = 'choice')  %>%
  filter((task == 'HL' & nonconsistent_hl == 0))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Amador2021",
         paper = "Amador Hidalgo et al. 2021")

df$country = 'Spain'
df$city = ""
df$longitude = ""
df$lattitude = ""

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, country)

# Writing to file
df %>% write_csv("Data/Amador_Hidalgo_2021/formatted_dataset.csv")

  


