#### Alan, S., Boneva, T. & Ertac, S. (2019).
#### Ever Failed, Try Again, Succeed Better: Results from a Randomized
#### Educational Intervention on Grit.
#### The Quarterly Journal of Economics, 134(3), 1121-1162.
#### https://doi.org/10.1093/qje/qjz006
#### Data: Harvard Dataverse 10.7910/DVN/SAVGAL

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## A randomised grit curriculum in 52 state-run elementary schools in remote
## districts of Istanbul, evaluated on two independent samples of fourth
## graders. The package publishes them as two files; they are different
## children, so both are stacked here.
s1 <- read_dta("Data/Alan_et_al_2019/original_dataset_sample1.dta") %>% mutate(sample = 1)
s2 <- read_dta("Data/Alan_et_al_2019/original_dataset_sample2.dta") %>% mutate(sample = 2)
stopifnot(nrow(s1) == 2575, nrow(s2) == 1499)

## THE TASK is the Gneezy and Potters allocation, this site's IG, measured at
## baseline: it sits in the balance table of the paper, so it is untouched by
## the intervention. `risk` is the number of tokens put in the risky bowl, 0
## to 5. The parameters are not in the published article, which only cites the
## task, but the same team spells its own version out in Alan, Ertac, Kubilay
## and Loranth (2020): five tokens, the risky ones "either tripled or lost,
## with 50% chance", the rest safe. Endowment 5, multiplier 3.
##
## The column is confirmed to be that allocation by the paper's own Table II,
## which reports risk tolerance at 2.60 and 2.51 across the two arms of sample
## 1 and 2.17 and 2.21 in sample 2; the data give 2.553 and 2.185. Age and
## gender match the same table as well (10.02 and 9.44 years, 51.8 and 51.0
## percent male).
##
## 239 children in sample 1 and 214 in sample 2 have no allocation recorded
## and are dropped, leaving 3,621.
##
## male is the authors' variable, so the site's gender is its complement.
## Age is in years with decimals and missing for 574 children.
## The direction is the usual one, modest as it tends to be at this age: boys
## invest 2.63 against girls' 2.47 in sample 1 and 2.27 against 2.10 in
## sample 2.
df <- bind_rows(s1, s2) %>%
  filter(!is.na(risk)) %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = as.numeric(risk),
            gender = 1 - as.numeric(male),
            age = as.numeric(age),
            bibkey = "Alan2019",
            paper = "Alan et al. 2019")
stopifnot(nrow(df) == 3621)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## State-run elementary schools in remote districts of Istanbul.
df$country = 'Turkey'
df$city = 'Istanbul'
df$lattitude = '41.0082'
df$longitude = '28.9784'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Alan_et_al_2019/formatted_dataset.csv")
