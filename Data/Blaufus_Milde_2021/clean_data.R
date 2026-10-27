#### Blaufus, K. & Milde, M. (2021). Tax misperceptions and the effect of
#### informational tax nudges on retirement savings. Management Science.
#### https://doi.org/10.1287/mnsc.2020.3761
#### Data: the journal's replication package (data.dta, readme.txt and the
#### authors' do-files), kept in raw_repository/mnsc-2

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiments on retirement saving by the Institute for Business
## Taxation in Hanover (Germany), the authors' faculty; the paper does not name
## the lab or date the sessions. 748 participants; data.dta has one row per
## participant, sequence and period, original_dataset.csv one row each.
##
## No risk task. "Risk taking is considered the subject's self-reported
## risk-taking attitude on a scale from 0 = not at all willing to take risks to
## 10 = very willing to take risks (Dohmen et al. 2011)": RiskTaking, which goes
## into soep as a questionnaire-only row.
##
## Male: 1 = man; Age in years.
df <- read_csv("Data/Blaufus_Milde_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 748, all(df$RiskTaking %in% 0:10))

df <- df %>%
  transmute(subject = ID,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = RiskTaking,
            r = NA_real_,
            gender = if_else(Male == 1, 0, 1),
            age = Age,
            country = "Germany",
            city = "Hanover")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Blaufus2021",
         paper = "Blaufus and Milde 2021")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Blaufus_Milde_2021/formatted_dataset.csv")
