## Daniel Friedman, Sameh Habib, Duncan James, and Brett Williams
## Varieties of Risk Preference Elicitation 
## 2022 

library(tidyverse)
library(broom)
library(lubridate)

## task 6 for gains  and task 10 for losses
df <- read_csv("Data/Shachat_2021/wuhan_risk_data.csv")
df = df %>% select(-risk_loss) %>% drop_na() %>% 
# 1 - females 
  mutate(gender = case_when(gender == 1~0,
                            gender == 0~1)) %>% 
  rename(choice = risk_gain,
         subject = id)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Shachat2021",
         paper = "Shachat 2021")

df$country = 'China'
df$city = 'Wuhan'
df$lattitude = '30.592850'
df$longitude = '114.305542'

df$task = 'CEPL'
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, country, everything())

# Writing to file
df %>% write_csv("Data/Shachat_2021/formatted_dataset.csv")
