#### Haile, K. K., Nillesen, E. & Tirivayi, N. (2020). Impact of formal climate
#### risk transfer mechanisms on risk-aversion: Empirical evidence from rural
#### Ethiopia. World Development, 130, 104930.
#### https://doi.org/10.1016/j.worlddev.2020.104930
#### Data: "Data for Impact of Formal Climate Risk Transfer Mechanisms on
#### Risk-Aversion" (Data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Household survey plus an incentivized risk experiment with heads of
## smallholder farming households in Alamata and Raya Azebo districts, Tigray,
## Ethiopia (120 buyers and 120 non-buyers of weather index insurance; the
## survey covers the 2017 farming season). Following Brick et al. (2012),
## "each choice (task) is a decision between picking a sure amount of money in
## option A, and tossing a coin in option B to earn either 20 ETB if the head
## comes up or nothing" -- sure amounts 20, 15, 10, 6 and 2 ETB (Table 1), one
## task paid at random. A certainty-equivalent price list, filed as CEPL.
##
## sure_20 ... sure_2 are 1 for the sure amount and 2 for the coin toss. The
## first row is the rationality check and everyone passed it; "one subject ...
## shifted between option A and option B multiple times" and is already out of
## the file, so all 239 answers switch at most once. choice = number of rows
## where the sure amount was taken (1 to 5); it reproduces the authors'
## categories in riskaverspar exactly (1 -> risk takers, 2 -> neutral,
## 3 to 5 -> averse). Bounds in the Haile2020 block of generate_r.R.
##
## sex is the household head's, 1 male and 0 female (value labels); the
## respondents are the heads, so it is their own. age is the head's age.
df <- read_csv("Data/Haile_et_al_2020/original_dataset.csv", show_col_types = FALSE)

sure <- as.matrix(df[, c("sure_20", "sure_15", "sure_10", "sure_6", "sure_2")])
n_sure <- rowSums(sure == 1)
## single switch from the sure amount to the coin toss
stopifnot(nrow(df) == 239, all(sure[, 1] == 1),
          all(sapply(seq_len(nrow(sure)), function(i) all(diff(sure[i, ]) >= 0))))

df <- df %>%
  mutate(n_sure = n_sure) %>%
  transmute(subject,
            task = "CEPL",
            choice = n_sure,
            gender = 1 - sex,
            age,
            bibkey = "Haile2020",
            paper = "Haile et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Alamata and Raya Azebo districts, southern Tigray
df$country = 'Ethiopia'
df$city = 'Alamata'
df$lattitude = '12.4167'
df$longitude = '39.5500'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Haile_et_al_2020/formatted_dataset.csv")
