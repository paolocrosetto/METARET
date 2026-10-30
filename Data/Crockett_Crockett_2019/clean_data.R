#### Crockett, E. & Crockett, S. (2019). Endowments and risky choice. Journal of
#### Economic Behavior & Organization, 159, 344-354.
#### https://doi.org/10.1016/j.jebo.2019.01.015
#### Data: replication package "Data for Endowments and Risky Choice" (dataHL.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment at Baruch College, City University of New York. The session
## codes (yymmddhh) date the sessions February 2013 to April 2014. Each subject
## made 21 choices between A (11.20 or 14 dollars) and B (0.70 or 26.95), the
## Holt-Laury payoffs times seven, with the probability of the high outcome
## rising 0, 0.05, ..., 1 (Table 2 of the paper); one row paid.
##
## The treatments are the paper's manipulation: in MPL-A and MPL-B subjects
## were endowed with lottery A or B before choosing, and the endowment shifts
## the choices (the endowment effect the paper reports). Only the unendowed
## MPL-N treatment is a standard elicitation, so only its 61 subjects are kept.
##
## dataHL.csv is one row per subject and decision, choice 1 = B. Five subjects
## have a garbled record (2, 19, 23, 40 or 42 rows instead of 21; none in
## MPL-N). Of the 61, 12 switched more than once and 1 chose A even at
## probability 1, where B pays 26.95 for sure: these 13 are kept for the
## download only, with inconsistent = 1 and one row per switch to B
## (Data/inconsistent_rows.R). 48 remain in the statistics. (B in row 1, where
## it pays 0.70 for sure, would be dominated too; nobody did it.)
## choice = number of B choices, 1 ... 20, i.e. 22 - the row where B starts;
## bounds in the Crockett2019 block of generate_r.R. gender: male 1 flipped to
## the site's female 1. No age.
df <- read_csv("Data/Crockett_Crockett_2019/original_dataset.csv",
               col_types = cols(pattern = col_character()))

stopifnot(nrow(df) == 185)

df <- df %>%
  filter(treatment == "MPL-N")

stopifnot(nrow(df) == 61, all(nchar(df$pattern) == 21))

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(strsplit(pattern, ""), function(x) switch_points(as.numeric(x))),
         inconsistent = as.numeric(!(str_detect(pattern, "^0*1*$") & n_risky %in% 1:20)))

stopifnot(sum(df$inconsistent == 0) == 48)

df <- df %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            gender = 1 - male,
            age = NA_real_,
            bibkey = "Crockett2019",
            paper = "Crockett and Crockett 2019") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 22 - k))

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Baruch College, New York; the map shows only the country
df$country = 'United States'
df$city = 'New York'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crockett_Crockett_2019/formatted_dataset.csv")
