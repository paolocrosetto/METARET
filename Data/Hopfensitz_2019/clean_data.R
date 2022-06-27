## Catch Uncertainty and Reward Schemes in a Commons Dilemma: An Experimental Study
## Astrid Hopfensitz · César Mantilla · Josepa Miquel-Florensa

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Hopfensitz_2019/risk_fishermen.dta")
df <- df %>% 
  select(ID, lottery, age, male) %>% 
  mutate(male = case_when(male == 1 ~ 0)) %>% 
  rename(choice = lottery,
         subject = ID,
         gender = male)
  
df$task = 'EG'
df$country = "Colombia"
# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Hopfensitz2019",
         paper = "Hopfensitz et al. 2019")

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, country)

# Writing to file
df %>% write_csv("Data/Hopfensitz_2019/formatted_dataset.csv")
