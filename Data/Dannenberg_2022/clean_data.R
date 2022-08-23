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
    df$latitude[i] = '0.133333'
    df$longitude[i] = '30.783333'
  }
  else if (df$city[i] == "Namasabo"){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.10875'
    df$longitude[i] = '33.04086'
  }
  else if (df$city[i] == 'Bugula'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.01209'
    df$longitude[i] = '32.87846'
  }
  else if (df$city[i] == 'Nafuba Island'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.19918'
    df$longitude[i] = '33.28838'
  }
  else if (df$city[i] == 'Guta'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.075145935036385'
    df$longitude[i] = '33.74057028922266'
  }
  else if (df$city[i] == 'Shinembo'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.5537'
    df$longitude[i] = '33.33597'
  }
  else if (df$city[i] == 'Chabula'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.47532'
    df$longitude[i] = '33.15021'
  }
  else if (df$city[i] == 'Bugabu'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.53212'
    df$longitude[i] = '33.39738'
  }
  else if (df$city[i] == 'Bezi'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.279100244759778'
    df$longitude[i] = '33.123603668684126'
  }
  else if (df$city[i] == 'Kabangaja'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.3877688361024285'
    df$longitude[i] = '32.97763532789297'
  }
  else if (df$city[i] == 'Kijiweni'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.384387687881357'
    df$longitude[i] = '32.65860819894339'
  }
  else if (df$city[i] == 'Kanyala'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.277308430027509'
    df$longitude[i] = '32.23619409039246'
  }
  else if (df$city[i] == 'Kahunda'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.3987135559254797'
    df$longitude[i] = '32.06632349624662'
  }
  else if (df$city[i] == 'Makatani'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.495871536967837'
    df$longitude[i] = '32.00283378362571'
  }
  else if (df$city[i] == 'Senga'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.6071959338363175'
    df$longitude[i] = '31.971477626961544'
  }
  else if (df$city[i] == 'Mwembeni'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.909259042746012'
    df$longitude[i] = '32.23259358177653'
  }
  else if (df$city[i] == 'Kakete'){
    df$country[i] = 'Tanzania'
  }
  else if (df$city[i] == 'Igabilo'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-2.726244047330907'
    df$longitude[i] = '30.645804654790666'
  }
  else if (df$city[i] == 'Mubembe'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-1.2929267725616311'
    df$longitude[i] = ' 31.553147127802593'
  }
  else if (df$city[i] == 'Makoko'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-7.963328400941517'
    df$longitude[i] = '33.65912831264465'
  }
  else if (df$city[i] == 'Kibuyi'){
    df$country[i] = 'Tanzania'
    df$latitude[i] = '-1.4156169810606982'
    df$longitude[i] = '33.813314888200416'
  }
  else if (df$city[i] == 'Kanga'){
    df$country[i] = 'Kenya'
    df$latitude[i] = '-0.7855195354883444'
    df$longitude[i] = '34.584250575018466'
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

