#### Pitts, S., Boyd, C. M. & Storer, G. X. (2025). Unpacking side-selling:
#### Experimental evidence from rural Mexico.
#### Agricultural Economics, 56, 1119-1149.
#### https://doi.org/10.1111/agec.70051
#### Data: GitHub ChiapasExperimentReplication (master_participants_reduced.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Framed field experiment with 268 indigenous smallholder coffee producers in
## Chiapas, Mexico, members and non-members of one marketing cooperative. The
## risk measure is "a no-loss lottery based on that of Eckel and Grossman
## (2008)": Table 3 of the paper scales the original five-gamble table
## (16/16 ... 0/48) "so that the first gamble has a guaranteed payoff of MXN
## 10000" -- 10000/10000, 7500/15000, 5000/20000, 2500/25000, 0/30000, each
## 50/50. The authors' crra column is the bound of each range (3, 2, 0.67,
## 0.38, 0.2 for gambles 1 to 5), the same bounds as the Banerjee2021 /
## Pitts2025 block of generate_r.R.
##
## Payoffs were in experimental money; the paper does not say how the lottery
## was converted into the final payment. Half the sample got an "additional
## income" treatment, and half played the lottery after the marketing games;
## both are kept. female is 1 for women; edad is age in years. The fieldwork
## dates are not given in the paper.
df <- read_csv("Data/Pitts_et_al_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 268, all(df$lottery %in% 1:5))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = lottery,
            gender = female,
            age,
            bibkey = "Pitts2025",
            paper = "Pitts et al. 2025")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Chiapas; the cooperative's ten regions are not located in the package
df$country = 'Mexico'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Pitts_et_al_2025/formatted_dataset.csv")
