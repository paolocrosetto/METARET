#####  Thomas Buser, Eva Ranehill, Roel van Veldhuizen
## Gender differences in willingness to compete: The role of public observability
## Journal of Economic Psychology

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Buser_et_al_2021/Buseretal2021.dta")

df = df %>% select(Subject, Investment, Gender, Age) %>% 
  rename(choice = Investment,
         gender = Gender,
         age = Age) %>% 
  ## 1 - females
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0))
df$subject = 1:nrow(df)
df$task = 'IG'
df$country = 'Germany'
df$city = 'Berlin'
df$latitude = '52.51250267430032'
df$longitude = '13.324436617770202'

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Buser2021",
         paper = "Buser et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_et_al_2021/formatted_dataset.csv")
