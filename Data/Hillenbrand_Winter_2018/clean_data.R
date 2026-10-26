#### Hillenbrand, A. & Winter, F. (2018). Volunteering under population
#### uncertainty.
#### Games and Economic Behavior, 109, 65-81.
#### https://doi.org/10.1016/j.geb.2017.12.009
#### Data: https://osf.io/zsv86

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Volunteer's dilemma run at the BonnEconLab of the University of Bonn in
## oTree, 438 subjects recruited with hroot. The volunteering game itself is
## not a risk elicitation, but every subject also did the bomb task:
## "Risk preferences where elicited with the Bomb Risk Elicitation Task
## (Crosetto and Filippin, 2013). Subjects could earn up to 3.15 EUR in this
## incentivized measure."
##
## The grid is 8 by 8, so 64 boxes: bomb_location in the package runs row 1 to
## 8 and column 1 to 8 over all 64 cells, and the largest number of boxes
## collected is exactly 64. The inversion is in the Hillenbrand2018 block of
## generate_r.R.
##
## original_dataset.csv joins Bret.csv (boxes_collected) to Quest.csv (age and
## gender) on the oTree participant code; all 438 appear in both, and none is
## flagged exclude_from_data_analysis.
df <- read_csv("Data/Hillenbrand_Winter_2018/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 438,
          all(df$boxes_collected >= 1 & df$boxes_collected <= 64))

## gender: the authors' own analysis file states "q_gender 1 male 0 female",
## so it is flipped to the site's 1 = female.
df <- df %>%
  transmute(subject,
            task = "BRET",
            choice = as.numeric(boxes_collected),
            gender = 1 - as.numeric(q_gender),
            age = as.numeric(q_age),
            bibkey = "Hillenbrand2018",
            paper = "Hillenbrand and Winter 2018")

## BonnEconLab, University of Bonn
df$country = 'Germany'
df$city = 'Bonn'
df$lattitude = '50.7340'
df$longitude = '7.1000'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hillenbrand_Winter_2018/formatted_dataset.csv")
