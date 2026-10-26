#### Chowdhury, S., Sutter, M. & Zimmermann, K. F. (2022). Economic preferences
#### across generations and family clusters: A large-scale experiment in a
#### developing country.
#### Journal of Political Economy, 130(9), 2361-2410.
#### https://doi.org/10.1086/720395
#### Data: replication archive of the article ("Data Archive")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Field experiment with whole families in rural Bangladesh: fathers, mothers
## and one of their children in each household. The risk task, quoted from the
## paper: "Here we followed the design created by Binswanger (1980) ...
## Participants had to choose one out of six gambles that yielded either a high
## or a low payoff with equal probability. The low payoff was decreasing and
## the high payoff was increasing for each successive gamble." The six menus
## of Table 3 are in the Chowdhury2022 block of generate_r.R.
##
## The payoffs were age contingent, from 6-7 year olds up to the parents, but
## every menu is the same list scaled, so the CRRA cuts are the same for all.
##
## 1,084 parents and 461 children. The children are only about half the sample:
## "because of some miscommunication between the experiment administrators in
## the field and us, we have collected risk preferences for only half of the
## children (but still for all parents)". The paper shows there is no
## systematic difference between the households where they were collected and
## the rest.
##
## original_dataset.csv stacks the risk column of ConstructedData/children.dta
## and ConstructedData/parents.dta with age, sex and the comprehension flag.
df <- read_csv("Data/Chowdhury_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 1545, all(df$binswanger %in% 1:6))

## gender is labelled "female=0, male=1" in the file, the opposite of this
## site, so it is flipped.
## ustood_risk marks whether the game had to be explained a fourth time: 16 of
## the 1,545 were still unsure. The authors build the flag but do not drop
## those rows anywhere in their cleaning, so they are kept here too.
df <- df %>%
  transmute(subject,
            task = "EG",
            choice = as.numeric(binswanger),
            gender = 1 - as.numeric(gender),
            age = as.numeric(age_at_exp),
            bibkey = "Chowdhury2022",
            paper = "Chowdhury et al. 2022")

## villages across rural Bangladesh, so no single city
df$country = 'Bangladesh'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chowdhury_et_al_2022/formatted_dataset.csv")
