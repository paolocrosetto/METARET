#### Cohn, A., Gesche, T. & Maréchal, M. A. (2022). Honesty in the digital age.
#### Management Science 68(2), 827-845. https://doi.org/10.1287/mnsc.2021.3985
#### Data: the journal's replication package (Main_Data, codebooks and the
#### authors' do-files and R scripts), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online coin-tossing experiments with subjects "from the University of Zurich
## and the Swiss Federal Institute of Technology" (Zurich, Switzerland).
## Experiment 1: wave 1 "in October and November 2013" (257 subjects), wave 2
## "one year later" (211); Experiment 2 (wave 3 in the file, 380 subjects) is
## not dated. Main_Data.csv has one row per subject, 848 in all. The separate
## survey experiment (Survey_data.csv) has no risk measure.
##
## No risk task. Every subject answered the general risk question of Dohmen et
## al. (2011), 0 ("not at all willing to take risks") to 10, as recorded in
## risk (the paper reverses and standardises it, the file does not), which goes
## into soep as a questionnaire-only row.
##
## male: 0 = female.
df <- read_csv("Data/Cohn_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 848, all(df$risk %in% 0:10))

df <- df %>%
  transmute(subject = subjectid,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = risk,
            r = NA_real_,
            gender = if_else(male == 0, 1, 0),
            age,
            country = "Switzerland",
            city = "Zurich")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Cohn2022",
         paper = "Cohn et al. 2022")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Cohn_et_al_2022/formatted_dataset.csv")
