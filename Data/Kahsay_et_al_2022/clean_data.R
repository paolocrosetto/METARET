#### Kahsay, G. A., Kassie, W. A., Medhin, H. & Hansen, L. G. (2022). Are
#### religious farmers more risk taking? Empirical evidence from Ethiopia.
#### Agricultural Economics, 53(4), 617-632.
#### https://doi.org/10.1111/agec.12697
#### Data: data appendix of the article (agec12697-sup-0002-data, religios_risk.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment with household heads, smallholder farmers in
## the Amhara National Regional State, Ethiopia, 819 households in 28 kebeles.
## "We measured Ethiopian farmers' risk preferences using a lab-in-the-field
## experiment with real payoffs following the multiple price listing (MPL)
## method": eight choices between a sure amount (Lottery A) and a coin toss
## paying 50 ETB or 0 (Lottery B), the sure amount falling 50, 37.5, 30, 25,
## 20, 15, 10, 5 ETB (Table 1 of the paper). A certainty-equivalent list,
## filed as CEPL; bounds in the Kahsay2022 block of generate_r.R.
##
## religios_risk.dta is one row per household and decision; choosen_option is
## 0 for the sure amount and 1 for the coin toss, and safechoice is the number
## of sure choices -- it equals the count of zeros for every household.
## consistent_sample == 0 marks the 73 households (8%, as in the paper) that
## switched more than once; their choices are blank and they are dropped.
##
## DOMINATED FIRST ROW. In decision 1 the sure amount equals the prize of the
## coin toss (50 ETB for sure against 50 or 0), so taking the toss there is
## dominated. 218 of the 746 consistent households did so, i.e. took the toss
## in all eight rows (safechoice == 0); the paper counts them as risk seeking,
## but no CRRA value rationalises the choice. They are dropped, as the
## dominated-row choosers of Faravelli et al. 2026 are. 528 households remain.
##
## choice = number of sure choices, 1 to 8. gender: the paper codes 1 = male
## (96% of household heads); flipped to the site's 1 = female. The paper does
## not say when the fieldwork took place.
df <- read_csv("Data/Kahsay_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 819, sum(df$consistent == 0) == 73)

df <- df %>%
  filter(consistent == 1, safe_choices >= 1)

stopifnot(nrow(df) == 528, all(df$safe_choices %in% 1:8))

df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = safe_choices,
            gender = 1 - male,
            age,
            bibkey = "Kahsay2022",
            paper = "Kahsay et al. 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Amhara region; the map shows only the country
df$country = 'Ethiopia'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kahsay_et_al_2022/formatted_dataset.csv")
