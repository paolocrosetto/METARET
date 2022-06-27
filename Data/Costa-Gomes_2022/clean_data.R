## Miguel Costa-Gomes & Philipp Schoenegger 2022 
## Sure-Thing vs. Probabilistic Charitable Giving: E
## Experimental Evidence on the Role of Individual Differences in Risky and Ambiguous Charitable Decision-Making

#### libraries
library(tidyverse)
library(haven)
library(broom)

#### getting the data
df <- readxl::read_xlsx("Data/Costa-Gomes_2022/Risk Aversion (BRET) Data.xlsx")

# Adding task, paper and bibtex handles
df <- df %>% 
  mutate(task = 'BRET',
         subject = 1:nrow(df),
         paper = "Costa-Gomes and Schoenegger, 2022",
         bibkey = "Costa-Gomes2022") %>% 
  rename("choice" = `Boxes opened (out of a maximum of 25)`,
         "gender" = `Gender (0=male, 1=female, 2=other)`,
         'age' = 'Age') %>% filter(gender!=2)

source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, gender, age, choice, r, everything())

df$country = 'United Kingdom'
# Writing to file
df %>% write_csv("Data/Costa-Gomes_2022/formatted_dataset.csv")
