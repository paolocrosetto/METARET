#### Holzmeister, F. & Stefan, M. (2019). The risk elicitation puzzle revisited: Across-methods (In)consistency?

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data
df <- read_xls("Data/Holzmeister_Stefan_2021/original_dataset.xls")

## sum of choices can be mapped to
## BRET: number of boxes
## EG: chosen lottery
## CEPL: number of risky choices
## HL: number of risky choices
df <- df %>% 
  mutate(task = as_factor(task),
         task = fct_recode(task, "BRET" = "1", "CEPL" = "2", "HL" = "3", "EG" = "4")) %>% 
  arrange(task, pid, k) %>% 
  group_by(task, pid) %>% 
  summarise(## inconsistent (29.10.2026): a dominated choice, checked row by row
            ## from the prizes and probabilities in the file -- in the CEPL list
            ## the sure amount in row 1 (5 against the lottery 15 or 5), in the
            ## HL list the safe option in row 10 (B pays more for sure); 6 and 9
            ## subjects, counted until now. Nobody switches more than once in
            ## either list. Kept for the download only (Data/inconsistent_rows.R).
            inconsistent = as.numeric((first(task) == "CEPL" & first(choice) == 0) |
                                        (first(task) == "HL" & last(choice) == 0)),
            choice = sum(choice), .groups = "drop")
stopifnot(sum(df$inconsistent[df$task == "CEPL"]) == 6, sum(df$inconsistent[df$task == "HL"]) == 9)

## recoding HL as higher number -> more risk

# adding task

# removing bret as it is duplicate of the one in JRU

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Holzmeister2019",
         paper = "Holzmeister and Stefan Working Paper 2019")

## translating CEPL and HL as number of RISKY choices
## EG goes from 0 to 5 -> translating into 1 to 6
df <- df %>% 
  mutate(choice = if_else(task == "CEPL", choice + 1, choice)) %>% 
  mutate(choice = if_else(task == "EG", choice +1, choice))



## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

df$country = "Austria"
# generate a numeric subect variable
df <- df %>% 
  mutate(subject = as.numeric(factor(pid, levels=unique(pid))),
         subject = 23100+subject) %>% 
  select(-pid)

# Writing to file
df %>% write_csv("Data/Holzmeister_Stefan_2021/formatted_dataset.csv")
