#### Breunig, C., Huck, S., Schmidt, T. & Weizsäcker, G. (2021). The standard
#### portfolio choice problem in Germany. The Economic Journal.
#### https://doi.org/10.1093/ej/ueab006
#### Data: the journal's replication files (ueab006_replication_files); only the
#### laboratory part (post-survey sessions.RData and the edited version, the import
#### code, the instructions, ReadMe and the SOEP data note) is kept in
#### raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two parts: a survey experiment in the SOEP Innovation Sample 2012 and, "upon
## completion of the field data collection in the SOEP-IS", the "identical
## experimental module for a set of 198 university students in the WZB-TU Berlin
## decision laboratory" (created.at: March 19 - April 10, 2013). Only the
## laboratory part is used: "SOEP data are available from the German
## Socio-economic Panel Study due to third party restrictions ... signing a data
## distribution contract is a precondition for working with SOEP data"
## (SOEP-DATA-Availability.pdf). One row per student (observation.id).
##
## No risk task: the portfolio choice between a riskless asset and a DAX fund
## has historical, not 50/50, returns. The post-experiment survey repeats the SOEP
## questions, among them the general willingness to take risks (risk_general in
## the raw log, renamed risk.tolerance), 0-10; 3 students have no answer. It goes
## into soep as a questionnaire-only row.
##
## gender is stored as 1 / 2 with no label in the files, and the authors' own
## female = (gender == 'female') does not match these codes, so gender is left
## empty. age in years; one entry of 1984 is a birth year, not an age, and is
## left empty.
df <- read_csv("Data/Breunig_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 198, all(df$risk.tolerance %in% c(0:10, NA)))

df <- df %>%
  filter(!is.na(risk.tolerance)) %>%
  transmute(subject = observation.id,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = risk.tolerance,
            r = NA_real_,
            gender = NA_real_,
            age = if_else(age < 100, age, NA_real_),
            country = "Germany",
            city = "Berlin")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Breunig2021",
         paper = "Breunig et al. 2021")

## the map is drawn by country; the coordinates are those of TU Berlin
df$lattitude = '52.5125'
df$longitude = '13.3269'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Breunig_et_al_2021/formatted_dataset.csv")
