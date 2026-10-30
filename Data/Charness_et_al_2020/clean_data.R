##### Charness et al, Do Measures of Risk Attitude in the Laboratory Predict Behavior under Risk in and outside of the Laboratory?, WP 2019

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/Charness_et_al_2020/original_dataset.csv")

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(-...1, -realestate, -insurance, -self_emp, -deductible, -inv_ris, -valsavings, -starts_with("P1"),
         -ins_g, -mor_g, -income) %>% 
  mutate(gender = abs(male-1)) %>% 
  select(-male) %>% 
  rename(subject = num_mem)

## this is  abetween-subjects paper. There are several tasks. 
## creating a task variable that takes the name of each of the tasks
df <- df %>% 
  mutate(task = case_when(!is.na(h_l) ~ "HL",
                          !is.na(g_p) ~ "IG",
                          !is.na(ta_1) ~ "TA",
                          !is.na(do_1) ~ "quest_only",
                          !is.na(e_g)  ~ "EG"))

## inconsistent HL answers (29.10.2026): the 46 multiple switchers
## (mulSwitch_hl) and the 31 with h_l == 11, who never took B, so kept A even in
## row 10 where B pays the high prize for sure (dominated). They stay for the
## download only, with inconsistent = 1 (Data/inconsistent_rows.R). The file has
## no row-by-row answers, and for the multiple switchers h_l is an average
## (3.5, 4.5 ...), not a switching point, so their choice is left empty; the 31
## get choice 0 like any 10-safe answer. Until 29.10.2026 the multiple switchers
## were deleted and the 31 counted.
df <- df %>% 
  mutate(inconsistent = as.numeric(task %in% "HL" & (mulSwitch_hl %in% TRUE | h_l %in% 11)),
         h_l = if_else(mulSwitch_hl %in% TRUE, NA_real_, h_l)) %>% 
  select(-mulSwitch_hl)
stopifnot(sum(df$inconsistent) == 77)

## assuming the HL variable is the SWITHING POINT
## we need to traslate this into the NUMBER OF SAFE CHOICES -- these are defined as switching point - 1
df <- df %>% 
  mutate(h_l = h_l - 1)

## choice in IG saved in cents -- transforming to euros
df <- df %>% 
  mutate(g_p = g_p/100)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -task, -inconsistent) %>%  
  filter(!is.na(choice) | (inconsistent == 1 & key == "h_l"))

# for the time being (aug 2019) delete Tanaka and second soep question
df <- df %>% 
  filter(task != "TA") %>% 
  filter(key != "do_2") %>% 
  select(-key)


# turning HL around so that higher numbers imply higher risk taking
df <- df %>% 
  mutate(choice = if_else(task == "HL", 10-choice, choice))


# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Charness2019",
         paper = "Charness et al 2019")


## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Charness_et_al_2020/formatted_dataset.csv")
