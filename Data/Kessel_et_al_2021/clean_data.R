#####  Dany Kessel, Johanna Mollerstrom, Roel van Veldhuizen
## Can simple advice eliminate the gender gap in willingness to compete?
## European Economic Review

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Kessel_et_al_2021/Kesseletal2021.dta")

df = df %>% select(Investment, byear, female, Riskaversion) %>% 
  rename(soep = Riskaversion,
         choice = Investment,
         gender = female,
         age = byear) %>% 
  mutate(subject = 1:nrow(df))

df$task = 'IG'
df$country = 'Germany'
df$city = 'Berlin'
df$latitude = '52.51250267430032'
df$longitude = '13.324436617770202'

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Kessel2021",
         paper = "Kessel et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kessel_et_al_2021/formatted_dataset.csv")
