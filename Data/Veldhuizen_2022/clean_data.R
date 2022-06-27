#####  Roel van Veldhuizen
## GENDER DIFFERENCES IN TOURNAMENT CHOICES: RISK PREFERENCES, OVERCONFIDENCE OR COMPETITIVENESS?

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Veldhuizen_2022/Veldhuizen2022.dta")

df = df %>% select(age, eckel, dohmen1, dohmen3,
                   holtlauryswitch,
                   holtlaury, realpp, female) %>% 
  rename(EG = eckel,
         HL = holtlaury,
         gender = female,
         subject = realpp,
         soep = dohmen1,
         soep_financial = dohmen3
         ) %>% 
  pivot_longer(-c(age, soep, soep_financial,
                 holtlauryswitch,
                  subject, gender), names_to = 'task', values_to = 'choice')

for (i in 1:nrow(df)){
  if (df$task[i] == "HL" & df$holtlauryswitch[i] > 1){
    df$choice[i] = NA
  }
}

df = df %>% drop_na() %>% select(-holtlauryswitch)

df$country = 'Germany'
df$city = 'Berlin'
df$latitude = '52.51250267430032'
df$longitude = '13.324436617770202'

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Veldhuizen2022",
         paper = "Veldhuizen 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Veldhuizen_2022/formatted_dataset.csv")
