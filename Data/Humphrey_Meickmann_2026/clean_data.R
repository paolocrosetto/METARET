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
## Five subjects switch more than once (hl_inconsistent == 1); the authors'
## own summary variable hl_switch_lasta is left missing for them. Until
## 29.10.2026 they were counted; now they, and anyone with A in row 10, where B
## pays 23.00 for sure (dominated), are kept for the download only, with
## inconsistent = 1 and one row per switch to B (Data/inconsistent_rows.R).
## Checked: for the 443 consistent subjects, choice == 10 - hl_switch_lasta.
##
## The stationarity tasks (situation*), the loss-aversion list (lossaversion1-10)
## and the CRT are part of the same experiment but are not risk elicitation
## tasks in the sense of this repository, so they are not kept.
source("Data/inconsistent_rows.R")
B <- 1 - as.matrix(select(df, num_range("riskdecision", 1:10)))
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(!apply(B, 1, single_switch) | B[, 10] == 0)) %>%
  transmute(subject = as.numeric(id),
            points, inconsistent,
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = as.numeric(female)) %>%
  ## choice = number of B choices = 11 - the row where B starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

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
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Humphrey_Meickmann_2026/formatted_dataset.csv")
