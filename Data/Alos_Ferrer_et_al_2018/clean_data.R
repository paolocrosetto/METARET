#### Alós-Ferrer, C., García-Segarra, J. & Ritschel, A. (2018). Performance curiosity.
#### Journal of Economic Psychology, 64, 1-17. https://doi.org/10.1016/j.joep.2017.08.002
#### Data: https://osf.io/5hkj6/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Experiment1PerfCuriosity.csv, the authors' file (one row per subject, no personal data):
## Experiment 1, 180 students (90 women, 90 men) at the Cologne Laboratory for
## Economic Research, z-Tree. At the end everyone answered the Holt-Laury
## lottery questionnaire; risk1safe ... risk10safe = 1 if the safe lottery was
## chosen in that row. choice = number of risky choices (9 subjects switch more
## than once; as elsewhere in METARET the total count is used).
## Experiment 2 (osf file Experiment2PerfCuriosity.csv) has no risk task.
## female: 1 = woman, 0 = man.
df <- read_csv("Data/Alos_Ferrer_et_al_2018/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = subject,
            task = "HL",
            choice = 10 - (risk1safe + risk2safe + risk3safe + risk4safe + risk5safe +
                           risk6safe + risk7safe + risk8safe + risk9safe + risk10safe),
            age = age,
            gender = female,
            country = "Germany",
            city = "Cologne")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "AlosFerrer2018",
         paper = "Alos-Ferrer et al. 2018")

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
df %>% write_csv("Data/Alos_Ferrer_et_al_2018/formatted_dataset.csv")
