#### Dai, Z., Galeotti, F. & Villeval, M. C. (2018). Cheating in the lab predicts
#### fraud in the field: An experiment in public transportation.
#### Management Science. https://doi.org/10.1287/mnsc.2016.2616
#### Data: the journal's data supplement (DGV_MS_2016.dta, the variable list and
#### the authors' do-files) and the online appendix, kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Artefactual field experiment with public transport users recruited at the
## Gare Part-Dieu stop in Lyon (France), "during nine consecutive days"; the
## Date variable runs from 7 to 18 November 2014. 279 subjects. DGV_MS_2016.dta
## has one row per subject and destination of the transport game;
## original_dataset.csv keeps one row per subject. The lab replication with
## students (DGV_students_MS_2016.dta) has no risk task.
##
## Task: Eckel and Grossman (2008) with the ring representation of Eckel et al.
## (2012), first set: six 50/50 lotteries, EUR 28/28, 24/36, 20/44, 16/52, 12/60,
## 2/70 (online appendix, screens of part 1). Gain_risk is the lottery chosen,
## 1 the safe one ("degree of risk seeking" in the paper). One lottery of the
## four sets was paid. The other three sets (losses, ambiguity) are not used.
## The menu is the Dave et al. (2010) one used for Ihli2022.
##
## Male: 0 = female. Age is in brackets (variable list and Table A1 of the
## online appendix): 0 = under 18 (one subject, left missing), 1 = 18-24,
## 2 = 25-34, 3 = 35-44, 4 = 45-59, 5 = 60 and over. age = the bracket midpoint;
## the open top bracket is coded 67, the middle of a 60-74 bracket of the same
## width as the one below, as for Hamman2023.
df <- read_csv("Data/Dai_et_al_2018/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 279, all(df$Gain_risk %in% 1:6))

df <- df %>%
  transmute(subject = Subject_ID,
            task = "EG",
            choice = Gain_risk,
            gender = if_else(Male == 0, 1, 0),
            age = c(`1` = 21, `2` = 29.5, `3` = 39.5, `4` = 52, `5` = 67)[as.character(Age)],
            country = "France",
            city = "Lyon")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Dai2018",
         paper = "Dai et al. 2018")

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
df %>% write_csv("Data/Dai_et_al_2018/formatted_dataset.csv")
