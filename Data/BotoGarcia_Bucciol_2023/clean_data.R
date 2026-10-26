#### Boto-Garcia, D. & Bucciol, A. (2023). Couple and individual willingness to take
#### risks. Journal of Economic Psychology, 99, 102676.
#### https://doi.org/10.1016/j.joep.2023.102676
#### Data: Mendeley Data https://doi.org/10.17632/k87zppg973.4
#### (CoupleWTR replication/data/Questionnaire_data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment with real-life couples from the general population in four
## northern Spanish cities (Aviles, Bilbao, Gijon, Oviedo), July-November 2019.
## original_dataset.csv keeps the individual risk answer, sex and age of all 266
## individuals in the authors' questionnaire file (133 couples; the paper's final
## sample drops 7 couples -- incomplete joint answers or a low-share couple type --
## leaving 126). The couple ids are replaced by row numbers; the joint (couple)
## answer is not used.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item (Q48) is the SOEP general question on 0-10 (0 = "nothing at all",
## 10 = "a great deal" willing to take risks). female: Q1 == "b", as in the
## authors' dataprep_ind.do.
df <- read_csv("Data/BotoGarcia_Bucciol_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk_0to10,
            task = "quest_only",
            country = "Spain")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "BotoGarcia2023",
         paper = "Boto-Garcia and Bucciol 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/BotoGarcia_Bucciol_2023/formatted_dataset.csv")
