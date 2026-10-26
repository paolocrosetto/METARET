#### Chaudhuri, A., Iversen, V., Jensenius, F. R. & Maitra, P. (2024).
#### Time in office and the changing gender gap in dishonesty: Evidence from local politics in India.
#### American Journal of Political Science. https://doi.org/10.1111/ajps.12733
#### Data: Harvard Dataverse, https://doi.org/10.7910/DVN/HX6YRD

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## Time_in_Office_Chaudhuri_Jensenius_Iversen_Maitra.dta (see Codebook.pdf):
## 400 local politicians (Gram Panchayat members) in West Bengal, 2018, one row each.
df <- read_dta("Data/Chaudhuri_et_al_2024/original_dataset.dta")

## Investment game (Gneezy and Potters 1997): endowment of Rs. 100, any part can be
## invested; with probability 1/2 the invested amount is tripled, otherwise lost.
## The paper calls it a "risky hypothetical project"; whether it was paid is not
## stated explicitly. invest = amount allocated to the risky asset (0-100).
## female: 1 female, 0 male.
df <- df %>% 
  transmute(subject = row_number(),
            choice = as.numeric(invest),
            age = as.numeric(age),
            gender = as.numeric(female))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "IG",
         bibkey = "Chaudhuri2024",
         paper = "Chaudhuri et al. 2024")

## field study across districts of West Bengal; coordinates of the state
df$country = 'India'
df$city = 'West Bengal'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chaudhuri_et_al_2024/formatted_dataset.csv")
