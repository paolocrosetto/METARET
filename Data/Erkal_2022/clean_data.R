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

## surveyFemale / female are "=1 if female", but 7 subjects carry -1, a third
## answer with no label in either file; it is not male, so it is left missing
df <- df %>% mutate(gender = if_else(gender %in% c(0, 1), as.numeric(gender), NA_real_))

## new ID
df$subject = 1:nrow(df)
# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Erkal2022",
         paper = "Erkal, Gangadharan, and Koh 2022")

df$country = 'Australia'
df$city = "Melbourne"
df$longitude = ''
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$task = 'IG'

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Erkal_2022/formatted_dataset.csv")






