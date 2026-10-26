#### De Giorgi, E., Omar, A. & Post, T. (2026). Analyzing individual bracketing
#### behavior in risk aggregation tasks. Journal of Behavioral and Experimental
#### Finance, 52, 101242. https://doi.org/10.1016/j.jbef.2026.101242
#### Data: Zenodo, https://doi.org/10.5281/zenodo.22207235
#### (Data/03_experiment_clean_data.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment run through the Sona system of the HSG Behavioral Lab at
## the University of St. Gallen. 407 students volunteered, 388 completed and
## are unique, split between two between-subject treatments: Balanced Gambles
## (184) and Skewed Gambles (204). Each subject answered twelve lotteries under
## three framings, 36 tasks in all. original_dataset.csv is the repository's
## clean file reduced to the treatment, the four narrow-framing answers used
## here and the demographics.
##
## Task: in the Narrow framing the subject holds one ticket on a single
## binomial gamble, and a slider picks how many of twenty gambles, ordered from
## the smallest loss to the largest, they accept; the rest pay zero. Each round
## carries an endowment equal to its largest loss, so final wealth is never
## negative. This is a payoff-varying price list, so the task is filed as PV.
##
## Only the Balanced Gamble treatment and only its four rounds with p = 0.4 are
## used. Those four are the same list at four scales (gain 1000, 2000, 3000,
## 4000), their CRRA thresholds agree to within 0.005, and they are the only
## rounds in the study whose range contains risk neutrality: the p = 0.5 and
## p = 0.6 rounds stop at r = 0.94 and 0.865, and every Skewed Gamble round
## spans no more than r in (0.09, 0.52) while leaving about 30% of its subjects
## at the ceiling. choice is the mean of the four answers, rounded.
##
## gender: 1 for the 59 who answered Female, 0 for the 121 who answered Male,
## missing for the 4 who preferred not to answer. Four subjects have no age.
df <- read_csv("Data/De_Giorgi_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(treatment == "good") %>%
  transmute(subject = row_number(),
            task = "PV",
            choice = round((nb_1 + nb_4 + nb_7 + nb_10) / 4),
            age = suppressWarnings(as.numeric(age)),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            country = "Switzerland",
            city = "St. Gallen")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "DeGiorgi2026",
         paper = "De Giorgi et al. 2026")

df$lattitude = '47.4316'
df$longitude = '9.3736'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/De_Giorgi_et_al_2026/formatted_dataset.csv")
