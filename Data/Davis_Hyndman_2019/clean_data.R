#### Davis, A. M. & Hyndman, K. (2019). Multidimensional bargaining and
#### inventory risk in supply chains: An experimental study.
#### Management Science. https://doi.org/10.1287/mnsc.2017.2985
#### Data: the journal's data supplement (the Davis-Hyndman-*.xlsx files) and the
#### online appendix, kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Supply-chain bargaining experiment at Cornell University (Ithaca, NY; the
## first author's lab), students. The three Outcomes files hold one row per
## subject and round; original_dataset.csv keeps one row per subject: 268 in the
## negotiation treatments and 70 in the ultimatum ones (the paper's "total of
## 338 subjects"), plus 24 in the additional focal-point treatment.
##
## After the game subjects "decided between a series of 50-50 binary lotteries",
## one fixed and one riskier whose good payoff rose from question to question;
## RiskSprecific is the number of risky choices out of 12. The payoffs are not
## in the paper, the appendix or the data, so the task is not used.
##
## Subjects were also asked the general risk question of Dohmen et al. (2011),
## on an 11-point scale with higher numbers for more willingness to take risks:
## RiskGeneral, 0-10, which goes into soep as a questionnaire-only row.
##
## The files have no gender or age.
df <- read_csv("Data/Davis_Hyndman_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 362, all(df$RiskGeneral %in% 0:10))

df <- df %>%
  transmute(subject = SubjectID,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = RiskGeneral,
            r = NA_real_,
            gender = NA_real_,
            age = NA_real_,
            country = "United States",
            city = "Ithaca")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Davis2019",
         paper = "Davis and Hyndman 2019")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Davis_Hyndman_2019/formatted_dataset.csv")
