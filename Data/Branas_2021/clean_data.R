#####  Pablo Brañas-Garza et al. To pay or not to pay: Measuring risk preferences in lab and field

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df_spain <- read_csv("Data/Branas_2021/spain.csv")
df_honduras <- read_csv("Data/Branas_2021/honduras.csv")
df_nigeria <- read_csv("Data/Branas_2021/nigeria.csv")


## Inconsistent answers (29.10.2026): the authors' consistency flag (gamma in
## Spain, consistency in Honduras and Nigeria) is 0 exactly for the answers
## a1-a5 that are not risky first and safe after (1...1 0...0). Those subjects
## used to be dropped; now they are kept for the download only, with
## inconsistent = 1 and one row per switch to the safe option
## (Data/inconsistent_rows.R). choice = RA_all, the number of risky answers =
## the row where the safe option starts - 1 (5 if never). The one subject per
## country file with no flag is left out, as before.
source("Data/inconsistent_rows.R")
risk_rows <- function(d, flag) {
  A <- as.matrix(d[, paste0("a", 1:5)])
  d %>%
    mutate(points = lapply(seq_len(nrow(A)), function(i) switch_points(1 - A[i, ])),
           inconsistent = as.numeric({{ flag }} == 0))
}

##################  SPAIN ########################################
### gamma is a consistency
df_spain = df_spain %>% filter(treatment == 'Real', !is.na(gamma)) %>%
  risk_rows(gamma) %>%
  mutate(gender = case_when(male == 'Sí' ~ 0,
                          male == 'No' ~ 1)) %>% 
  select(age, points, inconsistent, gender) 
df_spain$country = 'Spain'


##################  HONDURAS ########################################
### gamma is a consistency
df_honduras = df_honduras %>% filter(!is.na(consistency), pay == 2) %>%
  risk_rows(consistency) %>%
  mutate(gender = case_when(male == 1 ~ 0,
                            male == 0 ~ 1)) %>% 
  select(age, points, inconsistent, gender) 
df_honduras$country = 'Honduras'
##################  NIGERIA ########################################

## No variable pay or not pay BUT in article it is said that 
## Result 4: Compared to hypothetical payments in the field: Paying 1/10 of the subjects
## has no impact on consistency, number of safe choices or response time
## So we can use all dataset

df_nigeria = df_nigeria %>% filter(!is.na(consistency)) %>%
  risk_rows(consistency) %>%
  mutate(female = case_when(female == 'MALE' ~ 0,
                            female == 'FEMALE' ~ 1)) %>% 
  rename(gender = female) %>%  
  select(age, points, inconsistent, gender) 

df_nigeria$country = 'Nigeria'

df = rbind(df_honduras, df_nigeria, df_spain)

df$subject = 1:nrow(df)
df <- df %>% expand_switches(function(k) if_else(is.na(k), 5, k - 1))
df$task = 'HL'
# adding paper name and bibkey to all the lines 
df <- df %>% 
  mutate(bibkey = "Brañas-Garza2021",
         paper = "Brañas-Garza et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, inconsistent, switch_no, country)
         

# Writing to file
df %>% write_csv("Data/Branas_2021/formatted_dataset.csv")
