#### Charness et al, Do Measures of Risk Attitude in the Laboratory Predict Behavior under Risk in and outside of the Laboratory?, WP 2019

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/Charness_et_al_2019/original_dataset.csv")

## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(-X1, -realestate, -insurance, -self_emp, -deductible, -inv_ris, -valsavings, -starts_with("P1"),
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
                          !is.na(do_1) ~ "soep",
                          !is.na(e_g)  ~ "EG"))

## deleting iconsistents in HL
df <- df %>% 
  filter(mulSwitch_hl == F | is.na(mulSwitch_hl)) %>% 
  select(-mulSwitch_hl)

## assuming the HL variable is the SWITHING POINT
## we need to traslate this into the NUMBER OF SAFE CHOICES -- these are defined as switching point - 1
df <- df %>% 
  mutate(h_l = h_l - 1)

# gathering and renaming each different chocie variable 'choice'
df <- df %>% 
  gather(key, choice, -subject, -gender, -age, -task) %>%  
  filter(!is.na(choice))

# for the time being (aug 2019) delete Tanaka and second soep question
df <- df %>% 
  filter(task != "TA") %>% 
  filter(key != "do_2") %>% 
  select(-key)




# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Charness 2019",
         paper = "Charness et al 2019")

## function to assign random parameter within bounds to HL
## note: use pmap, add one layer for the 'paper' name, and then just apply this to each and every case -- neater, better, less errors.
get_r <- function(task, choice) {
  
  if (task == "EG") {
    if (choice == 1) { out <- -2.45 }
    if (choice == 2) { out <- runif(1, min = -2.45, max = -0.16)}
    if (choice == 3) { out <- runif(1, min = -0.16, max = 0.29)}
    if (choice == 4) { out <- runif(1, min = 0.29, max = 0.50)}
    if (choice == 5) { out <- runif(1, min = 0.50, max = 1)}
    if (choice == 6) { out <- 1}
  }
  
  if (task == "HL") {
    if (choice == 0) { out <- 2.71   }
    if (choice == 1) { out <- runif(1, min = 1.95, max = 2.71) }
    if (choice == 2) { out <- runif(1, min = 1.49, max = 1.95) }
    if (choice == 3) { out <- runif(1, min = 1.15, max = 1.49) }
    if (choice == 4) { out <- runif(1, min = 0.85, max = 1.15) }
    if (choice == 5) { out <- runif(1, min = 0.59, max = 0.85) }
    if (choice == 6) { out <- runif(1, min = 0.32, max = 0.59) }
    if (choice == 7) { out <- runif(1, min = 0.03, max = 0.32) }
    if (choice == 8) { out <- runif(1, min = -0.37, max = 0.03) }
    if (choice == 9) { out <- -0.37 }
    if (choice == 10) { out <- -0.37 }
  }
  
  if (task != "HL" & task != "EG") { out <- NA }
  
  out
}


## Computing the CRRA (x^r) coefficient of risk aversion from the task data
## note: IG data not yet implemented!
df <- df %>% mutate(r = purrr::map2_dbl(task, choice, get_r))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Charness_et_al_2019/formatted_dataset.csv")
