#### Nielsen, Kirby
##  Dynamic risk preferences under realized and paper outcomes

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data
df <- read_dta("Data/Nielsen_2019/original_dataset.dta")

## some subjects have made no choice apparently (0 everywhere)
df <- df %>% 
  filter(!(box1 == 0 & box2 == 0 & box3 == 0 & box4 ==0))

# scale choice up so that it is consistent with a 100-box BRET
df <- df %>% 
  mutate(subject = 345000 + row_number()) %>% 
  select(subject, treatment, choice = box1) %>% 
  mutate(choice = choice*4) %>% 
  mutate(treatment = as.character(treatment)) %>% 
  mutate(treatment = if_else(treatment == 1, "low stakes", "high stakes"))
  
# Adding task, paper and bibtex handles
df <- df %>% 
  mutate(task = "BRET",
         paper = "Nielsen, JEBO 2019",
         bibkey = "Nielsen2019")

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

df$country = 'United States'
df$city = ""
df$longitude = ""
df$lattitude = ""

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Nielsen_2019/formatted_dataset.csv")
