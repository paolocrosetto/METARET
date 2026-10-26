#### Schmidt, R. (2025). Social norm uncertainty: Measurement using coordination
#### games and behavioral relevance.
#### Journal of Economic Behavior and Organization, 232, 106937. https://doi.org/10.1016/j.jebo.2025.106937
#### Data: https://osf.io/42gd5/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is one row per subject from the authors' "Analysis File.dta"
## (100 subjects x 20 norm items), keeping only the risk measures, gender and age.
## 100 students, 5 sessions at the experimental lab of Heidelberg University
## (July 2023 - February 2024), z-Tree. Section 4 had seven decisions, one of them
## paid at random (instructions, English version on OSF):
##  - decision 1, EG: eight 50/50 lotteries 8/8, 7/10, 6/12, 5/14, 4/16, 3/18,
##    2/20, 1/21 EUR. lottery = number of the chosen lottery (1 ... 8).
##  - decision 2, IG: endowment 8 EUR, the amount invested is multiplied by 2.5
##    with 50%, else lost. investment = amount invested (to the cent).
##  - decisions 3-7, CE_staircase (Falk et al. 2023): a sure amount against 15 EUR
##    with 50%, else 0. The first sure amount is 8 EUR; after each choice it goes
##    up (lottery chosen) or down (sure amount chosen) by 4, 2, 1, 0.5 EUR.
##    situation3 ... situation7: 1 = sure amount, 2 = lottery. staircase5 is the
##    midpoint of the final 0.5 EUR interval of the CE (checked below against the
##    five choices). choice = (staircase5 - 0.25) / 0.5, 0 ... 31.
## The SOEP general risk question (risiko, 0 - 10) goes to soep.
## female: 1 = woman, 0 = man; one subject has 0.5 in the authors' file and is set to NA.
df <- read_csv("Data/Schmidt_2025/original_dataset.csv", show_col_types = FALSE)

## the staircase path must end in the published staircase5
stair_end <- function(s3, s4, s5, s6, s7) {
  x <- 8; step <- 4
  for (s in c(s3, s4, s5, s6, s7)) {
    x <- x + if (s == 2) step else -step
    step <- step / 2
  }
  x   ## after the fifth choice the step is 0.25, i.e. the interval midpoint
}
stopifnot(all(purrr::pmap_dbl(list(df$situation3, df$situation4, df$situation5,
                                   df$situation6, df$situation7), stair_end) ==
              df$staircase5))

df <- df %>%
  transmute(subject,
            EG = lottery,
            IG = investment,
            CE_staircase = (staircase5 - 0.25) / 0.5,
            soep = risiko,
            age,
            gender = if_else(female %in% c(0, 1), female, NA_real_),
            country = "Germany",
            city = "Heidelberg") %>%
  pivot_longer(c(EG, IG, CE_staircase), names_to = "task", values_to = "choice")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Schmidt2025",
         paper = "Schmidt 2025")

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
df %>% write_csv("Data/Schmidt_2025/formatted_dataset.csv")
