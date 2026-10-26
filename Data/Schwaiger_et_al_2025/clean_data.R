#### Schwaiger, R., Strucks, M. & Zeisberger, S. (2025).
#### The Consequences of Narrow Framing for Risk Taking: A Stress Test of Myopic Loss Aversion.
#### Management Science, 72(2), 1324-1340. https://doi.org/10.1287/mnsc.2024.05720
#### Data: https://osf.io/9xmda/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## round_investments.csv from the replication package: one row per participant
## and period (2,245 students, online, Qualtrics). inv = % of the 100 ECU invested.
## Six conditions x two treatments (HIGH = decide and see feedback each period,
## LOW = one decision for three periods). Only the decision that is a single
## Gneezy-Potters gamble is kept: treatment HIGH, period 1 (before any feedback),
## in the two conditions with the Gneezy-Potters payoffs:
##  - 250-100L9: 1/3 chance of +250%, 2/3 chance of -100% (the original design)
##  - 230-90L9:  1/3 chance of +230%, 2/3 chance of -90%
## The 25-10 conditions (+25% / -10%, linear or compound) are not used.
## No age in the data; female = 1, other gender (other = 1) -> NA.
df <- read_csv("Data/Schwaiger_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(round == 1, treatment == "HIGH", version %in% c("250-100L9", "230-90L9")) %>% 
  transmute(subject = row_number(),
            task = if_else(version == "250-100L9", "IG_250", "IG_230"),
            choice = inv,
            age = NA_real_,
            gender = if_else(other == 1, NA_real_, as.numeric(female)),
            ## waves 1-2: Radboud University; wave 3: University of Innsbruck
            country = if_else(innsbruck == 1, "Austria", "Netherlands"),
            city = if_else(innsbruck == 1, "Innsbruck", "Nijmegen"))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Schwaiger2025",
         paper = "Schwaiger et al. 2025")

## online experiment, so no lab coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% 
  mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r),
         task = "IG")

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Schwaiger_et_al_2025/formatted_dataset.csv")
