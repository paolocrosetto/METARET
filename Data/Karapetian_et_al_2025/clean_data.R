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
## Age was asked in brackets only (D1 in both files). The authors' own scripts
## (Exp 1.R, SI Exp 2.R in the data repository) recode 99 ... 105 to 1 ... 7 and
## label them 18-24, 25-34, 35-44, 45-54, 55-64, 65-74, 75-84; the shares in the
## paper (Experiment 1: 3% 18-24, 44% 25-34, 28% 35-44, 17% 45-54, 7.5% 55+)
## fit that reading. age = bracket midpoint, as for Burro2026 (21, 29.5, ...).
source("Data/inconsistent_rows.R")
age_mid <- c(`99` = 21, `100` = 29.5, `101` = 39.5, `102` = 49.5, `103` = 59.5,
             `104` = 69.5, `105` = 79.5)

clean_control <- function(df, q, att1, att2, sex, age) {
  df %>%
    filter(Group == "Control") %>%
    mutate(across(all_of(c(q, att1, att2, sex, age)), ~ suppressWarnings(as.numeric(.x)))) %>%
    filter(if_all(all_of(q), ~ !is.na(.x)),
           .data[[att1]] == 1, .data[[att2]] == 2) %>%
    mutate(points = lapply(seq_len(n()), function(i) switch_points(as.numeric(unlist(pick(all_of(q))[i, ]) == 2))),
           inconsistent = as.numeric(sapply(seq_len(n()), function(i) {
             b <- as.numeric(unlist(pick(all_of(q))[i, ]) == 2)
             !single_switch(b) | b[10] == 0
           }))) %>%
    transmute(points, inconsistent,
              ## 1 - female, 0 - male
              gender = case_when(.data[[sex]] == 2 ~ 1,
                                 .data[[sex]] == 1 ~ 0,
                                 TRUE ~ NA_real_),
              age = unname(age_mid[as.character(.data[[age]])]))
}

## Experiment 1: the first two rows of the Qualtrics export are labels
exp1 <- read_csv("Data/Karapetian_et_al_2025/original_exp1.csv", show_col_types = FALSE) %>% 
  slice(-(1:2)) %>% 
  clean_control(q = paste0("CGQ", 1:10), att1 = "CGATT1", att2 = "CGATT2", sex = "D6",
                age = "D1")

exp2 <- read_csv("Data/Karapetian_et_al_2025/original_exp2.csv", show_col_types = FALSE) %>% 
  clean_control(q = paste0("CG_HL", 1:10), att1 = "CG_ATT1", att2 = "CG_ATT2", sex = "Sex",
                age = "D1")

## Inconsistent (counted until 29.10.2026): subjects who switch more than once
## or keep A in row 10, where B pays $3.85 for sure; they are kept for the
## download only, with inconsistent = 1 and one row per switch to B
## (Data/inconsistent_rows.R). choice = 11 - the row where B starts.
df <- bind_rows(exp1, exp2) %>% 
  mutate(subject = row_number()) %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

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
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Karapetian_et_al_2025/formatted_dataset.csv")
