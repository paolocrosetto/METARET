#### Becchetti, L., Buso, I. M., Corazzini, L. & Pelligra, V. (2026).
#### Chains of generosity: the impact of indirect recipients on prosocial
#### behavior and welfare in experimental settings.
#### Theory and Decision.
#### https://doi.org/10.1007/s11238-026-10159-y
#### Data: https://osf.io/ygkm4

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 360 subjects recruited through ORSEE between March and November 2023 at
## VeraLabEx, the experimental economics laboratory of Ca' Foscari University
## in Venice. The replication file has one row per subject and 391 columns;
## only the three used here were copied out.
##
## The experiment is about giving to direct and indirect recipients, not about
## risk, so the rows are 'quest_only' and generate_data_for_app.R moves
## `choice` into `soep`.
##
## The replication folder is named after an earlier working title, "the taste
## for generativity"; the treatment names in the do-files (1-REC, 2-REC and so
## on) and the 360 subjects identify it as this paper.
df <- read_csv("Data/Becchetti_et_al_2026/original_dataset.csv", show_col_types = FALSE)

## Risk is the general risk question on 0 to 10 with no gaps. Sex is 1 for men
## -- the authors' create-DB file sets d_male = 1 if Sex == 1 -- 2 for women and
## 3 for the four other answers, which are left missing. The direction is the
## usual one: men average 5.81 against women's 5.08.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(Risk),
            gender = case_when(Sex == 2 ~ 1, Sex == 1 ~ 0, TRUE ~ NA_real_),
            age = as.numeric(Age),
            bibkey = "Becchetti2026",
            paper = "Becchetti et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## VeraLabEx, Ca' Foscari University, Venice.
df$country = 'Italy'
df$city = 'Venice'
df$lattitude = '45.4408'
df$longitude = '12.3155'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Becchetti_et_al_2026/formatted_dataset.csv")
