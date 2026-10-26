#### Segovia, M. S., Palma, M. A., Lusk, J. L. & Drichoutis, A. C. (2025).
#### Visual formats in risk preference elicitation: What catches the eye?
#### Journal of Risk and Uncertainty, 70, 275-303. https://doi.org/10.1007/s11166-025-09455-9
#### Data: https://osf.io/vra65/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## riskeyetrack.dta from OSF: 206 Texas A&M undergraduates (2017), one row per
## subject x decision. Rows nchoice 1-10 are the Holt-Laury list (hl == 1),
## rows 11-20 the payoff-varying list of Drichoutis and Lusk (2016) (hl == 0).
## rchoice = 1 when the risky option B was chosen. The four treatments only change
## the visual format of the lists (no effect in the paper), so all are kept.
df <- read_dta("Data/Segovia_et_al_2025/original_dataset.dta")

## Prizes are stored rescaled; their ratios are those of the standard HL list
## (A 2.00/1.60, B 3.85/0.10). choice = number of B choices in each list.
## male: 1 male, 0 female.
df <- df %>% 
  mutate(task = if_else(hl == 1, "HL", "PV")) %>% 
  group_by(id, task) %>% 
  summarise(choice = sum(rchoice == 1),
            age = first(as.numeric(age)),
            gender = first(case_when(male == 1 ~ 0, male == 0 ~ 1, TRUE ~ NA_real_)),
            .groups = "drop") %>% 
  rename(subject = id)

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Segovia2025",
         paper = "Segovia et al. 2025")

## Texas A&M University, College Station
df$country = 'United States'
df$city = 'College Station'
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
df %>% write_csv("Data/Segovia_et_al_2025/formatted_dataset.csv")
