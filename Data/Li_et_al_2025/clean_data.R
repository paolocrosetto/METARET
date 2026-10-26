#### Li, X., Haan, M. A., Onderstal, S. & Veldman, J. (2025). A wind tunnel
#### test of wind farm auctions. Energy Economics, 108984.
#### https://doi.org/10.1016/j.eneco.2025.108984
#### Data: dataset.dta of the replication material

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "The experiment was run online in September and October 2020 using LIONESS
## Lab ... We organized 12 sessions recruiting 192 subjects from the
## undergraduate population of the University of Amsterdam using the CREED
## subject pool", groups of three bidding in 25 auction periods under four
## support regimes. The auctions are not a risk elicitation, so the rows are
## 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
##
## The post-experiment survey asks the Dohmen et al. (2011) question, quoted in
## footnote 13: "Are you generally a person who is fully prepared to take risks
## or do you try to avoid taking risks? ... 0 means: not at all willing to take
## risks and the value 10 means: very willing to take risks" -- variable risk.
##
## dataset.dta is one row per subject and period (4,800 = 192 x 25);
## original_dataset.csv keeps one row per subject (treatment, group, seat).
## AGE AND GENDER ARE LEFT EMPTY: both are stored as unlabelled codes (age 1-8,
## evidently brackets; gender 1-4 with 83, 106, 1 and 2 subjects) and neither
## the file nor the paper says what the codes mean. A codebook from the authors
## would fill them.
df <- read_csv("Data/Li_et_al_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 192, all(df$risk %in% 0:10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = risk,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Li2025",
            paper = "Li et al. 2025")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online, University of Amsterdam students; the map shows only the country
df$country = 'Netherlands'
df$city = 'Amsterdam'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Li_et_al_2025/formatted_dataset.csv")
