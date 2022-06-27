## Erkal, Gangadharan, and Koh (2020, JEP)
## Replication: Belief elicitation with quadratic and binarized scoring
## rules

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Erkal_2020/belief_elicitation-paper.dta")

df = df %>% 
  select(ID, starts_with('RGInputRisky'), RGSafeTotal, surveyAge,
         surveyFemale) %>% 
  rename(subject = ID,
         choice = RGSafeTotal,
         age = surveyAge,
         gender = surveyFemale)


## Filtering the inconsistency 
df$nonconsistent = 0
for (i in 1:9){
  for (j in 1:nrow(df)){
    if(grepl("RGInputRisky", colnames(df[,i])) & pull(df[j,i]) == 1 & pull(df[j,i+1]) == 0){
      df$nonconsistent[j] = 1
    }
  }
}

df = df %>% filter(nonconsistent != 1) %>%
  select(subject, choice, age, gender)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Erkal2020",
         paper = "Erkal, Gangadharan, and Koh 2020")

df$country = 'Australia'
df$city = "Melbourne"
df$longitude = "-37.79822719279415"
df$lattitude = "144.96098472664792"
df$task = 'CEPL'

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Erkal_2020/formatted_dataset.csv")






