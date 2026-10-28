#### Zhang, H. (2019). Common fate motivates cooperation: The influence of risks
#### on contributions to public goods. Journal of Economic Psychology, 70, 12-21.
#### https://doi.org/10.1016/j.joep.2018.10.012
#### Data: Mendeley Data 10.17632/chrg8wcb7v (a.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "The computerized experiment was conducted in a US university", 12 sessions of
## 8 undergraduates (96 subjects); the paper does not name the university. a.dta
## has one row per subject and period of the public goods game;
## original_dataset.csv keeps one row per subject (session, Subject).
##
## Task: after the game, "the investment task of Gneezy and Potters (1997). All
## the subjects were given $5 and asked to decide the amount of money to invest in
## a risky investment (with increments of $0.50). The investment had a 50% success
## rate. If the investment turned out to be successful, it returned three times
## the amount invested; otherwise, the money invested was lost." AmountInvested.
##
## sex is coded 1/2 with no label in the file or the paper (nor in the author's
## earlier deposit of the same data, Mendeley 10.17632/998pc9y8jc, commonfate.csv,
## in raw_repository/mendeley_998pc9y8jc). It is read as 1 = male, 2 = female from
## the majors, which do not depend on the risk task: Management/Business 15 vs 5
## and Economics 4 vs 0 against Liberal Arts 1 vs 5, Education 0 vs 2 and
## Humanities 0 vs 1 (code 1 vs code 2), the US pattern by sex. The investment
## itself is not used to decide, so the gender gap of this paper is not built in.
## age in years.
df <- read_csv("Data/Zhang_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 96, all(df$AmountInvested %in% seq(0, 5, 0.5)))

df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = AmountInvested,
            age,
            gender = case_when(sex == 2 ~ 1, sex == 1 ~ 0),
            country = "United States",
            city = "",
            bibkey = "Zhang2019",
            paper = "Zhang 2019")

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zhang_2019/formatted_dataset.csv")
