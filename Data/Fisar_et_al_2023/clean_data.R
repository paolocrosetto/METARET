#### Fišar, M., Cingl, L., Reggiani, T., Kundtová Klocová, E., Kundt, R., Krátký, J.,
#### Kostolanská, K., Bencúrová, P., Pešková, M. K. & Marečková, K. (2023).
#### Ovulatory shift, hormonal changes, and no effects on incentivized decision-making.
#### Journal of Economic Psychology, 97, 102656. https://doi.org/10.1016/j.joep.2023.102656
#### Data: replication package on OSF, https://osf.io/bc673/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## GAMU_DATA_03.dta from the replication package, renamed
df <- read_dta("Data/Fisar_et_al_2023/original_dataset.dta")

## Every participant played the BRET twice, in two sessions some weeks apart
## (females: menstruation and ovulation phase; males: session 1 and 2).
## 171 subjects x 2 sessions = 342 rows. To keep one observation per subject,
## as for the other panel datasets, we keep the first session only.
df <- df %>% 
  filter(Session == 1)

## Dynamic BRET with 100 boxes (10x10 grid, one box uncovered per second).
## BRETchoice is the step at which the subject stopped: 1 = first box, 100 = last box,
## so it is directly the number of collected boxes.
df <- df %>% 
  transmute(subject = as.numeric(UniID),
            choice = as.numeric(BRETchoice),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = as.numeric(female))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "BRET",
         bibkey = "Fisar2023",
         paper = "Fišar et al. 2023")

df$country = 'Czech Republic'
df$city = 'Brno'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fisar_et_al_2023/formatted_dataset.csv")
