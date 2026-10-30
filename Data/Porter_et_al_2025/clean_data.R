#### Porter, M., Nuhu, A. S., Nakasone, E. & Maredia, M. K. (2025). Trust, risk,
#### and institutions: Experimental evidence from a community of firms in Kenya.
#### Journal of Economic Psychology, 110, 102834.
#### https://doi.org/10.1016/j.joep.2025.102834
#### Data: Mendeley Data, https://data.mendeley.com/datasets/7t3yk5w26p
#### (trustcop_public.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment with Kenyan food processing SMEs, run in six
## sessions at five Community of Practice meetings of the Marketplace for
## Nutritious Foods programme between August 2019 and January 2020. 83
## participants, mean age 39.3, 42% women. The repository file is a panel of
## trust game rounds; original_dataset.csv keeps one row per participant with
## the risk measure and the demographics.
##
## Task: a ten-row price list, each row the same lottery -- 50% of 500 Kenyan
## shillings, 50% of nothing -- against a sure payment rising 50, 100, ..., 500
## down the list. The risk task was run before the trust games. choice is the
## row where the subject first took the sure payment.
##
## The repository stores no raw switch row, only the authors' new_avgswitch,
## which averages all switch points for subjects who switched more than once.
## For the 56 subjects the authors flag as consistent (rational == 1, exactly
## one switch point, two thirds of the sample as the paper reports) that
## average is the switch row itself and every value is a whole number. The
## other 27 have no single crossing, so no certainty equivalent interval is
## defined for them and they are out of the statistics, as multiple switchers
## are elsewhere in this corpus (the paper instead keeps them at their average
## switch row); they are kept for the download only, with inconsistent = 1 and
## no choice (Data/inconsistent_rows.R), since only the average is stored.
##
## The city is not named in the paper, so only the country is carried over.
df <- read_csv("Data/Porter_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = if_else(rational == 1, switch_row, NA_real_),
            inconsistent = as.numeric(rational != 1),
            age,
            gender = female,
            country = "Kenya")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Porter2025",
         paper = "Porter et al. 2025")

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Porter_et_al_2025/formatted_dataset.csv")
