#### Ifcher, J. & Zarghamee, H. (2024). Does Decision Making for Others Close the
#### Gender Gap in Competition? Management Science, 70.
#### https://doi.org/10.1287/mnsc.2023.4861
#### Data: Management Science replication package (analytical_dataset.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 324 students at Columbia University and Santa Clara University, fall 2019.
## Task 5 (paper, section 3.7): a fixed payment of USD 0, 1, ..., 10 against a
## lottery paying 10 or 0 with probability 1/2. The authors' file holds IP
## addresses and MTurk fields; original_dataset.csv keeps only session,
## treatment, age, sex and one 0/1 column per row (1 = fixed payment chosen), and
## the authors' file is not copied to raw_repository. Subjects are row numbers.
## As in the authors' do-file, subjects who take USD 0 for sure, take the lottery
## against USD 10, or go back from the fixed payment to the lottery are dropped.
## choice = the first fixed payment taken (1-10): the certainty equivalent lies
## between choice - 1 and choice.
df <- read_csv("Data/Ifcher_Zarghamee_2024/original_dataset.csv", show_col_types = FALSE)

Fx <- df %>% select(fixed_0:fixed_10) %>% as.matrix()
consistent <- apply(Fx, 1, function(x) all(diff(x) >= 0)) & Fx[, 1] == 0 & Fx[, 11] == 1

df <- df %>%
  mutate(switch = apply(Fx, 1, function(x) which(x == 1)[1] - 1)) %>%
  filter(consistent) %>%
  transmute(subject,
            task = "CEPL",
            choice = switch,
            age,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Ifcher2024",
         paper = "Ifcher and Zarghamee 2024")

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
df %>% write_csv("Data/Ifcher_Zarghamee_2024/formatted_dataset.csv")
