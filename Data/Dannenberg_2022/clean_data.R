#####  Pablo Brañas-Garza et al. To pay or not to pay: Measuring risk preferences in lab and field

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Dannenberg_2022/Cleaned_data_experience_information_investment_fishers.dta")

df = df %>% 
  select(village, tablet_id, I, age, female) %>%
  drop_na() %>% 
  rename(city = village,
         choice = I,
         gender = female)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Dannenberg2022",
         paper = "Dannenberg et al. 2022")

## better qualify the location
for (i in 1:nrow(df)){
  if (df$city[i] == "Kakukuru"){
    df$country[i] = 'Uganda'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == "Namasabo"){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Bugula'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Nafuba Island'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Guta'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Shinembo'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Chabula'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Bugabu'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Bezi'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kabangaja'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kijiweni'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kanyala'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kahunda'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Makatani'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Senga'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Mwembeni'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kakete'){
    df$country[i] = 'Tanzania'
  }
  else if (df$city[i] == 'Igabilo'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Mubembe'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Makoko'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kibuyi'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
  else if (df$city[i] == 'Kanga'){
    df$country[i] = 'Kenya'
    df$latitude[i] = ''
    df$longitude[i] = ''
  }
}

df$task = 'IG'
df$subject = 1:nrow(df)
## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Dannenberg_2022/formatted_dataset.csv")

