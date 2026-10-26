#### Hermann, D., Musshoff, O. & Rau, H. A. (2019). The disposition effect when
#### deciding on behalf of others. Journal of Economic Psychology, 74, 102192.
#### https://doi.org/10.1016/j.joep.2019.102192
#### Data: data.xlsx from the authors' replication package

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment at the University of Goettingen, z-Tree, autumn 2016: a Weber
## and Camerer stock trading task, run either for the subject's own account
## (Individual) or on behalf of a matched other subject (Responsibility). Eight
## sessions, 85 subjects per treatment, 170 in all; mean age 25.28, 51% female,
## average earnings 16.70 EUR.
##
## Before the trading task every subject did an incentivized risk elicitation:
## a version of Eckel & Grossman (2008) extended from the usual five or six
## gambles to NINE, so that risk neutral and risk seeking subjects can be told
## apart as well. Each gamble pays one of two amounts with probability 1/2;
## egvalue is the gamble chosen, 1 = safest (a sure amount) to 9 = riskiest, so
## higher numbers mean less risk aversion. The payoff of the chosen gamble was
## paid out. The menu itself is table 2 of Hermann & Musshoff (2019, Journal of
## Risk Research) by the same group; the CRRA intervals that come with this data
## file ("lamda and CRRA" sheet of data.xlsx) are the ones that menu implies and
## are reproduced in generate_r.R.
## Both treatments are kept: the risk task came before the trading task, so the
## treatment cannot have touched it.
## original_dataset.csv keeps the treatment, the chosen gamble, the authors'
## female and age variables and the economics-major dummy; everything about the
## trading task, the SVO slider, loss aversion and the empathy questionnaire is
## dropped. One subject has no gender recorded.
df <- read_csv("Data/Hermann_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 170, all(df$egvalue >= 1 & df$egvalue <= 9))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = egvalue,
            age,
            gender = female,
            country = "Germany")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Hermann2019",
         paper = "Hermann et al. 2019")

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
df %>% write_csv("Data/Hermann_et_al_2019/formatted_dataset.csv")
