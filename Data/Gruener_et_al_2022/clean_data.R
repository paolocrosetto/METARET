#### Gruener, S., Lehberger, M., Hirschauer, N. & Musshoff, O. (2022). How
#### (un)informative are experiments with students for other social groups? A
#### study of agricultural students and farmers. Australian Journal of
#### Agricultural and Resource Economics, 66(3), 471-504.
#### https://doi.org/10.1111/1467-8489.12485
#### Data: Supporting Information, Appendix S1 "Data and Code"
#### (data_population+incentives-3_final.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Internet-based study run in Germany from 14 September to 13 November 2020
## with two populations of 150 each, agricultural students and farmers, and
## three monetary incentive levels (100 subjects per level). The paper asks
## whether students can stand in for farmers; on risk aversion it finds no
## difference, and the data agree -- mean safe choices 5.49 against 5.51.
## original_dataset.csv is the Appendix S1 workbook reduced to the ten Holt-
## Laury rows, the authors' own consistency flags and the demographics.
##
## Task: the Holt and Laury (2002) list as published, option A paying EUR 2.00
## or 1.60 and option B 3.85 or 0.10, the high payoff with probability 10%,
## 20%, ... down the rows (the exact wording is in Appendix S2). hl1 ... hl10
## are 1 when the safe option A was chosen, and sum_hl is their sum, so
## choice = 10 - sum_hl is the number of risky choices.
##
## Dropped on the authors' own flags: the 22 subjects marked multiple switch,
## who have no single crossing, and the 11 marked a_10, who took option A in
## the last row where it pays EUR 2.00 for sure against B's 3.85. One subject
## are in both groups, so 270 remain.
##
## gender is 1 female, 0 male; one subject answered a third category and is
## left missing.
df <- read_csv("Data/Gruener_et_al_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(multiple_switch == 0, a_10 == 0) %>%
  transmute(subject = id,
            task = "HL",
            choice = 10L - sum_hl,
            age,
            gender = case_when(gender == 1 ~ 1, gender == 0 ~ 0, TRUE ~ NA_real_),
            country = "Germany")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Gruener2022",
         paper = "Gruener et al. 2022")

## online study across Germany, so no city
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gruener_et_al_2022/formatted_dataset.csv")
