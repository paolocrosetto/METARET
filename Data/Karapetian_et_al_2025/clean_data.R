#### Karapetian, A., Sundali, J., Guerrero, F., Hanna, A. & Ridinger, G. (2025).
#### Risk aversion and social influence.
#### Experimental Economics. https://doi.org/10.1017/eec.2025.10020
#### Data: https://doi.org/10.17605/OSF.IO/FH254

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

## Standard Holt and Laury (2002) list: option A pays $2.00/$1.60, option B pays
## $3.85/$0.10, probability of the high payoff rising from 10% to 100% over 10 rows.
## Answers are coded 1 = option A (safe), 2 = option B (risky);
## choice = number of risky (B) choices, as for the other HL papers.
##
## The treatment groups were shown how other people had chosen in this same list,
## precisely to shift their choices. Only the CONTROL groups, who saw no such
## information, are kept. Experiments 1 and 2 (MTurk, US) are used; the files for
## Experiment 3 (lab) are partial and overlapping, so they are left out.
##
## Exclusions follow the paper: subjects who did not answer all 10 rows or failed
## either of the two attention-check rows (correct answers: A, then B) are dropped.
## This reproduces the paper's control samples exactly: N = 76 (41% female) in
## Experiment 1 and N = 93 (52% female) in Experiment 2.
## Sex: 1 male, 2 female (checked against the shares reported in the paper).
## Age was asked in brackets only, so it is not kept.

clean_control <- function(df, q, att1, att2, sex) {
  df %>% 
    filter(Group == "Control") %>% 
    mutate(across(all_of(c(q, att1, att2, sex)), ~ suppressWarnings(as.numeric(.x)))) %>% 
    filter(if_all(all_of(q), ~ !is.na(.x)),
           .data[[att1]] == 1, .data[[att2]] == 2) %>% 
    transmute(choice = rowSums(across(all_of(q)) == 2),
              ## 1 - female, 0 - male
              gender = case_when(.data[[sex]] == 2 ~ 1,
                                 .data[[sex]] == 1 ~ 0,
                                 TRUE ~ NA_real_))
}

## Experiment 1: the first two rows of the Qualtrics export are labels
exp1 <- read_csv("Data/Karapetian_et_al_2025/original_exp1.csv", show_col_types = FALSE) %>% 
  slice(-(1:2)) %>% 
  clean_control(q = paste0("CGQ", 1:10), att1 = "CGATT1", att2 = "CGATT2", sex = "D6")

exp2 <- read_csv("Data/Karapetian_et_al_2025/original_exp2.csv", show_col_types = FALSE) %>% 
  clean_control(q = paste0("CG_HL", 1:10), att1 = "CG_ATT1", att2 = "CG_ATT2", sex = "Sex")

df <- bind_rows(exp1, exp2) %>% 
  mutate(subject = row_number())

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "HL",
         bibkey = "Karapetian2025",
         paper = "Karapetian et al. 2025")

## online (Amazon Mechanical Turk), US participants
df$country = 'United States'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Karapetian_et_al_2025/formatted_dataset.csv")
