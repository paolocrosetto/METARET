#### Buser, T., Peter, N. & Wolter, S. C. (2022). Willingness to compete, gender and career
#### choices along the whole ability distribution. Experimental Economics, 25, 1299-1326.
#### https://doi.org/10.1007/s10683-022-09765-8
#### Data: openICPSR, https://doi.org/10.3886/E170641V1 (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## data_EEreplication.dta, one row per student: 1514 lower-secondary students
## (8th grade) in the canton of Bern, Switzerland, classroom experiment.
## Only school, class, the two risk tasks, age and gender were copied here.
## Two incentivised risk tasks (English_instructions_questionnaire.pdf):
##  - EG, screen 16 (v16010, 0-4, as listed): 0 = 2 CHF for sure, 1 = 3.50/1.50,
##    2 = 4.00/1.00, 3 = 5.00/0.50, 4 = 6.00/0.00, 50/50. choice = v16010 + 1
##    (= the authors' lotto_wahl), 1 = safest; boys choose higher on average.
##  - BRET, screen 44 (v44020): dynamic, 100 squares, 10 centimes each, one bomb;
##    choice = squares revealed.
## age: alter_jahr (age in years, with decimals). gender: geschlecht.
df <- read_csv("Data/Buser_et_al_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            EG = v16010 + 1,
            BRET = v44020,
            age = alter_jahr,
            gender = case_when(geschlecht == "female" ~ 1, geschlecht == "male" ~ 0, TRUE ~ NA_real_),
            country = "Switzerland",
            city = "") %>% 
  pivot_longer(c(EG, BRET), names_to = "task", values_to = "choice") %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Buser2022",
         paper = "Buser et al. 2022")

## classroom experiment in several schools, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_et_al_2022/formatted_dataset.csv")
