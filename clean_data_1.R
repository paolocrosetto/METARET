#### Csermely, T., & Rabas, A. (2016).
#### How to reveal people’s preferences: Comparing time consistency 
#### and predictive power of multiple price list risk elicitation methods. 
#### Journal of Risk and Uncertainty, 53(2-3), 107–136.
#### https://doi.org/10.1007/s11166-016-9247-6

#### cleaning data to be used for the meta-anlaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- readxl::read_excel("Data/Csermely_Rabas_JRU/original_data/Risk Results.xlsx") %>% as_factor()

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, gender, age, treatment, perc, pump, eg, cgptotal, safechoices, inconsistent, soep, starts_with("do")) %>% 
  select(-dominated)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -inconsistent, -soep, -starts_with("do"), -treatment) %>% 
  filter(!is.na(choice))

# adding task
df <- df %>% 
  mutate(task = case_when(treatment == "bret" ~ "BRET",
                          treatment == "cgp" ~ "IG",
                          treatment == "eg" ~ "EG",
                          treatment == "hl" ~ "HL",
                          treatment == "balloon" ~ "BART"))

# removing bret as it is duplicate of the one in JRU
df <- df %>% 
  filter(treatment != "bret")

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Crosetto2016",
         paper = "Crosetto and Filippin EXEC 2016")


# coding choices in HL as number of risky choices
df <- df %>% 
  mutate(choice = if_else(task == "HL", 10-choice, choice))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))



# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crosetto_Filippin_Experimental_Economics_2016/formatted_dataset.csv")