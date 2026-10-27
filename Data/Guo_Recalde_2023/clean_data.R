#### Guo, J. & Recalde, M. P. (2023). Overriding in Teams: The Role of Beliefs,
#### Social Image, and Gender. Management Science, 69.
#### https://doi.org/10.1287/mnsc.2022.4434
#### Data: Management Science replication package (data/data_main_experiment.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 254 students at the University of Melbourne Experimental Economics Laboratory.
## Risk task (z-Tree "Task 4", codebook): option A is a 50-50 lottery between
## AUD 1 and 2, option B pays 3 with probability 5, 10, 20, 25, 30, 40, 50, 60,
## 70, 75, 80, 90, 95% in rows 1-13 (rows 0 and 14, probability 0 and 100, are
## fixed by the program). One lottery is held against a varying probability of a
## prize, so it is filed with the probability-equivalent lists as CEPL.
## original_dataset.csv keeps one row per subject (session, photo treatment,
## age, sex, choices 1 = A, 2 = B); subjects are row numbers. Only subjects who
## never go back from B to A are kept. choice = number of B choices in rows
## 1-13. gender: 2 = female, 1 = male, 3 = other (coded NA).
df <- read_csv("Data/Guo_Recalde_2023/original_dataset.csv", show_col_types = FALSE)

B <- df %>% select(choice1:choice13) %>% as.matrix()
consistent <- apply(B, 1, function(x) all(diff(x) >= 0))

df <- df %>%
  mutate(nB = rowSums(B == 2)) %>%
  filter(consistent) %>%
  transmute(subject,
            task = "CEPL",
            choice = nB,
            age,
            gender = case_when(gender == 2 ~ 1, gender == 1 ~ 0),
            country = "Australia")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Guo2023",
         paper = "Guo and Recalde 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Guo_Recalde_2023/formatted_dataset.csv")
