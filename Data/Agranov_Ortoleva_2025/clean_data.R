#### Agranov, M. & Ortoleva, P. (2025). Ranges of randomization.
#### Review of Economics and Statistics, 107(6), 1702-1713.
#### https://doi.org/10.1162/rest_a_01355
#### Data: replication package on Dataverse (folder INCPREF)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 165 undergraduates at the University of California, Irvine: "A total of 165
## subjects participated in an experiment run at the University of California,
## Irvine; all subjects were undergraduate students."
##
## The experiment itself is about deliberate randomization: ten price-list
## questions in which a subject may ask for a coin flip between the two
## options, and the paper studies how wide a range of mixtures people accept.
## Nothing in that part maps onto a CRRA coefficient, so it is not used.
##
## What is used is the closing part: "subjects completed two investment tasks
## (Gneezy & Potters, 1997)", recorded as risk1 and risk2. Both are a straight
## investment of a 100-point endowment in a project that pays 2.5 times the
## stake with probability 1/2 and nothing otherwise; the wording is quoted in
## the AgranovOrtoleva2025 block of generate_r.R. The two differ only in the
## value of a point (10 cents, then 2 cents). Only risk1 is kept, since the
## site holds one coefficient per subject per task, and 10 cents a point is the
## larger stake and the one the paper describes first.
##
## The paper restricts most of its analysis to the 148 subjects whose price-list
## answers are undominated, but the investment task is a separate question
## answered by everyone, so all 165 are kept.
##
## original_dataset.csv is the two investment columns of cleaned.dta.
df <- read_csv("Data/Agranov_Ortoleva_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 165, all(df$risk1 >= 0 & df$risk1 <= 100))

## gender and age: NOT AVAILABLE. The package carries no demographics at all --
## the only subject-level non-experimental field in cleaned.dta is the Qualtrics
## interface language, which is 'EN' for everyone.
df <- df %>%
  transmute(subject,
            task = "IG",
            choice = risk1,
            age = NA_real_,
            gender = NA_real_,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "AgranovOrtoleva2025",
         paper = "Agranov and Ortoleva 2025")

## laboratory at the University of California, Irvine
df$city = 'Irvine'
df$lattitude = '33.6405'
df$longitude = '-117.8443'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Agranov_Ortoleva_2025/formatted_dataset.csv")
