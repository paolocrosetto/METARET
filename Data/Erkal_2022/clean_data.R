## Erkal, Gangadharan, and Koh (Experimental Economics, 2022)
## By chance or by choice? Biased attribution of others’ outcomes when social preferences matter

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df1 <- read_dta("Data/Erkal_2022/Exp1-cleaned-long-state.dta")
df2 <- read_dta("Data/Erkal_2022/Exp2-cleaned-long-state.dta")

df2 <- df2 %>% 
  select(id, risk_invest, female, age) %>%
  rename(subject = id,
         choice = risk_invest,
         gender = female) %>% 
  distinct()

df1 = df1 %>% 
  filter(RA == 1) %>% 
  select(ID, RGInvest, surveyAge,
         surveyFemale) %>% 
  rename(subject = ID,
         choice = RGInvest,
         age = surveyAge,
         gender = surveyFemale) %>% distinct()

df = rbind(df1, df2)

## new ID
df$subject = 1:nrow(df)
# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Erkal2022",
         paper = "Erkal, Gangadharan, and Koh 2022")

df$country = 'Australia'
df$city = "Melbourne"
df$longitude = "-37.79822719279415"
df$lattitude = "144.96098472664792"
df$task = 'IG'

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Erkal_2022/formatted_dataset.csv")






