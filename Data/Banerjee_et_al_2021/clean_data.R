#### Banerjee, S., Cason, T. N., de Vries, F. P. & Hanley, N. (2021). Spatial
#### coordination and joint bidding in conservation auctions.
#### Journal of the Association of Environmental and Resource Economists, 8(5),
#### 1013-1049. https://doi.org/10.1086/714601
#### Data: Harvard Dataverse replication files (subjects.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory auction experiment in z-Tree at Purdue University, 2018 and 2019
## (session codes 180328 ... 190321), students recruited broadly. "Stage 1
## involves a short risk preference elicitation through an incentivized
## Eckel-Grossman" task: "subjects have to choose one of five gambles which
## are increasing both in expected returns and risk level". The payoffs are in
## the z-Tree program Cons_Auction_treatment1.ztt (each 50/50): $4/4, 3/6,
## 2/8, 1/10, 0/12 -- the original Eckel and Grossman (2002) table, block
## Banerjee2021 in generate_r.R.
##
## The closing questionnaire also asks "Are you generally a person who is
## fully prepared to take risks or do you try to avoid taking risks? ... the
## value 0 means: 'unwilling to take risks' and the value 10 means: 'fully
## prepared to take risk'" -- the SOEP item, variable Risk. z-Tree keeps it at
## its default -1 until the questionnaire is filled in, so for 96 subjects the
## periods before it read -1; the answered value is taken, and all 384 have one.
##
## subjects.dta is one row per subject and auction period; RiskChoice and Risk
## are collapsed to one row per subject (384). Age and gender were asked in
## the questionnaire but are not in the published data.
df <- read_csv("Data/Banerjee_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 384, all(df$gamble %in% 1:5),
          all(df$risk_general %in% 0:10 | is.na(df$risk_general)))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = gamble,
            soep = risk_general,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Banerjee2021",
            paper = "Banerjee et al. 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Purdue University, West Lafayette, Indiana
df$country = 'United States'
df$city = 'West Lafayette'
df$lattitude = '40.4237'
df$longitude = '-86.9212'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Banerjee_et_al_2021/formatted_dataset.csv")
