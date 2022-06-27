## Erkal, Gangadharan, and Koh (2018, EER)
## Monetary and non-monetary incentives in real-effort tournaments

library(haven)
library(tidyverse)
library(broom)
library(lubridate)

df <- read_dta("Data/Erkal_2018/EER-D-17-00107R2_data.dta")

df = df %>% 
  filter(Exp1 == 1) %>% 
  select(ID, RiskInvest, Female, Age) %>% 
  rename(subject = ID,
         choice = RiskInvest,
         age = Age,
         gender = Female)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Erkal2018",
         paper = "Erkal, Gangadharan, and Koh 2018")

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
df %>% write_csv("Data/Erkal_2018/formatted_dataset.csv")





 