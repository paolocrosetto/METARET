#### Coerts, M. (Marin), Heine, F., van Ommeren, F. & van Witteloostuijn, A. (2026). Single
#### and multi-winner auctions with performance obligation.
#### Games and Economic Behavior, 161, 104048 (issue dated 2027).
#### https://doi.org/10.1016/j.geb.2026.104048
#### Data: DataverseNL, https://doi.org/10.34894/SS8WWD (downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is one row per subject from the authors' Full.dta (342
## students, 24 sessions at CentERlab, Tilburg University, z-Tree), keeping the
## session (renumbered), treatment, the lottery choice, gender and age.
## Risk task (before the auctions, incentivised): an Eckel-Grossman style choice
## among eleven 50/50 lotteries -- 28/28, 32/26, 36/24, 40/22, 44/20, 48/18, 52/16,
## 56/14, 60/12, 65/7, 70/2 (payoffs read off Risk_Profit; some sessions paid half,
## which does not change r). gamble = number of the chosen lottery (1 ... 11).
## The SOEP domain items (RiskGeneral etc.) run from 0 to 11 with no documented
## scale and are not used.
## Female: 1 = woman, 0 = man.
df <- read_csv("Data/Coerts_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = gamble,
            age,
            gender = female,
            country = "Netherlands",
            city = "Tilburg")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Coerts2026",
         paper = "Coerts et al. 2026")

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
df %>% write_csv("Data/Coerts_et_al_2026/formatted_dataset.csv")
