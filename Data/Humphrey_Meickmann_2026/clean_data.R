#### Humphrey, S. J. & Meickmann, F. C. (2026).
#### Are violations of the stationarity principle mistakes?
#### Journal of Behavioral and Experimental Economics, 124, 102606.
#### https://doi.org/10.1016/j.socec.2026.102606
#### Data: https://doi.org/10.17605/OSF.IO/VDC7M

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## data.csv from the OSF replication package, semicolon separated.
## One row per subject; variables are documented in Replication_readme.txt.
df <- read_delim("Data/Humphrey_Meickmann_2026/original_dataset.csv",
                 delim = ";", show_col_types = FALSE)

## Holt and Laury list of ten rows: option A pays EUR 12.00 with probability
## row/10 and EUR 9.50 otherwise, option B pays EUR 23.00 with the same
## probability and EUR 0.50 otherwise. riskdecision1-10 are coded 1 = option A
## (safe), 0 = option B (risky), so choice = number of risky choices, as for the
## other HL papers. No row is missing for any subject.
##
## Five subjects switch more than once (hl_inconsistent == 1). They are kept:
## counting B choices is defined for them too, and the site keeps inconsistent
## subjects elsewhere. The authors do not drop them from the data either -- their
## own summary variable hl_switch_lasta is simply left missing for those five.
## Checked: for the 443 consistent subjects, choice == 10 - hl_switch_lasta.
##
## The stationarity tasks (situation*), the loss-aversion list (lossaversion1-10)
## and the CRT are part of the same experiment but are not risk elicitation
## tasks in the sense of this repository, so they are not kept.
df <- df %>%
  transmute(subject = as.numeric(id),
            choice = 10L - rowSums(across(num_range("riskdecision", 1:10))),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = as.numeric(female))

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "HL",
         bibkey = "Humphrey2026",
         paper = "Humphrey and Meickmann 2026")

## Laboratory for Economics Research (LaER), University of Osnabrueck.
## Fourteen sessions were run in the laboratory and twelve online with identical
## procedures; the authors pool them, having checked that the risk and
## loss-aversion tasks show no laboratory/online difference.
df$country = 'Germany'
df$city = 'Osnabrueck'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Humphrey_Meickmann_2026/formatted_dataset.csv")
