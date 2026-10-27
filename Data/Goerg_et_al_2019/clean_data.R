#### Goerg, S. J., Kube, S. & Radbruch, J. (2019). The effectiveness of incentive
#### schemes in the presence of implicit effort costs. Management Science.
#### https://doi.org/10.1287/mnsc.2018.3160
#### Data: the journal's replication package (data.dta, Results.do, Read_ME.txt),
#### kept in raw_repository/Upload

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Real-effort experiment "conducted at the BonnEconLab of the University of
## Bonn": 571 subjects, one row each. Two rows have no subject_id but full
## answers; subjects are numbered by row.
##
## No risk task. The questionnaire included the "general risk attitude (Dohmen
## et al. 2011)": risk runs 1-11, the 11-point scale stored from 1, so
## 0-10 = risk - 1; one subject has no answer. It goes into soep as a
## questionnaire-only row.
##
## female: 1 = woman; sd_age is age in years.
df <- read_csv("Data/Goerg_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 571, all(df$risk %in% c(1:11, NA)))

df <- df %>%
  mutate(subject = row_number()) %>%
  filter(!is.na(risk)) %>%
  transmute(subject,
            task = "quest_only",
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = risk - 1,
            r = NA_real_,
            gender = female,
            age = sd_age,
            country = "Germany",
            city = "Bonn")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Goerg2019",
         paper = "Goerg et al. 2019")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Goerg_et_al_2019/formatted_dataset.csv")
