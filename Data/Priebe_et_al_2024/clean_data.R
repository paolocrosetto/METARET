#### Priebe, J., Rink, U. & Stemmler, H. (2024). Disability and risk preferences:
#### Experimental and survey evidence from Vietnam.
#### The Economic Journal, 134, 3390-3427. https://doi.org/10.1093/ej/ueae029
#### Data: https://doi.org/10.5281/zenodo.10911278 (data/clean/data_final.dta),
#### downloaded by hand

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper has two parts: a TVSEP household panel (survey risk question only)
## and a lab-in-the-field experiment in rural Vietnam (2018). Only the experiment
## is used: 804 respondents, half from households with a disabled member, after
## the authors dropped 29 who failed the comprehension checks. original_dataset.csv
## keeps the priming treatment (0 neutral, 1 negative, 2 positive), the disability
## sample flag, the EG choice, the general risk question, sex and age from the
## authors' data_final.dta; household, village and district ids are dropped and
## subjects are row numbers. Ages above 69 were top-coded at 69 by the authors.
## EG task (paper, Table 5): one choice among six 50/50 gambles, in VND
## 130,000/130,000; 115,000/155,000; 100,000/180,000; 85,000/205,000;
## 70,000/230,000; 20,000/280,000. choice = gamble 1-6 (exp_risk); the shares
## match Table 5 (11.1, 19.3, 31.6, 20.9, 11.2, 6.0%). The second incentivised task
## (accept or reject six 50/50 gambles against a safe amount, a loss-aversion-type
## measure) has no METARET category and is not used.
## soep: the general risk question (d1, 0 = unwilling, 10 = willing to take a lot
## of risk), asked before the priming; the repeat after the priming (m2) is not
## used. female: 1 = woman, 0 = man.
df <- read_csv("Data/Priebe_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = eg_choice,
            soep,
            age,
            gender = female,
            country = "Vietnam")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Priebe2024",
         paper = "Priebe et al. 2024")

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
df %>% write_csv("Data/Priebe_et_al_2024/formatted_dataset.csv")
