#### Falk, A., Becker, A., Dohmen, T., Huffman, D. & Sunde, U. (2023). The
#### preference survey module: A validated instrument for measuring risk, time,
#### and social preferences. Management Science 69(4), 1935-1950.
#### https://doi.org/10.1287/mnsc.2022.4455
#### Data: the journal's replication package (MainSample_Replication.dta and the
#### test-retest and pretest files, MS_Replication.do), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "Four hundred and nine subjects participated in our study. Subjects were
## students from the University of Bonn", two lab sessions "at the Laboratory
## for Experimental Economics at the University of Bonn in winter 2010/2011".
## MainSample_Replication.dta has one row per subject; the file has no age or
## sex. The small test-retest and pretest samples are not used.
##
## The incentivized risk experiments were two price lists (a sure 0, 50, ...,
## 1,000 points against 1,000 points with probability 0.5), but the file keeps
## only x_risk_av, the average of the two switching rows, not each list, so no
## task is taken.
##
## v_94, "Risk: willingness to take risks", is the general risk question of
## Dohmen et al. (2011), 0-10, answered by 394 subjects; it goes into soep as a
## questionnaire-only row.
df <- read_csv("Data/Falk_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 409, sum(!is.na(df$v_94_general_risk)) == 394)

df <- df %>%
  filter(!is.na(v_94_general_risk)) %>%
  transmute(subject = row,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = v_94_general_risk,
            r = NA_real_,
            gender = NA_real_,
            age = NA_real_,
            country = "Germany",
            city = "Bonn")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Falk2023",
         paper = "Falk et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Falk_et_al_2023/formatted_dataset.csv")
