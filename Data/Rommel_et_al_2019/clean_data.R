#####  Jens Rommel , Daniel Hermann, Malte Mu€ller and Oliver Mußhoff1
## Contextual Framing and Monetary Incentives in Field Experiments on Risk Preferences: Evidence from German Farmers

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read.csv("Data/Rommel_et_al_2019/Datensatz_final_June 2016.csv", sep = ";")

df = df %>% 
  filter(INCONSIST_HLL1 == 0) %>%
  select(starts_with('HLL1'), 
                   f1, f2) %>% 
  mutate(subject = 1:nrow(.),
         age = 2019 - f2) %>%
  rename(gender = f1)  %>%
  select(-f2) %>%
  ## 1 - females
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0)) %>% 
  pivot_longer(-c(gender, subject, age), names_to = 'task', values_to = 'choice') %>%
  group_by(gender, subject, age) %>% 
  summarise(choice = sum(choice))
 

df$task = 'HL'
df$country = 'Germany'

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Rommel2019",
         paper = "Rommel et al. 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Rommel_et_al_2019/formatted_dataset.csv")
