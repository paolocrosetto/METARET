#### Burro, G. & Castagnetti, A. (2022). Will I tell you that you are smart (dumb)?
#### Deceiving others about their IQ or about a random draw.
#### Journal of Behavioral and Experimental Economics, 100, 101920.
#### https://doi.org/10.1016/j.socec.2022.101920
#### Data: Mendeley Data, senders https://doi.org/10.17632/mzsctb3fzn.2
#### (data_sender_deception.csv) and receivers https://doi.org/10.17632/mgghc39cd6.2
#### (data_receiver_deception.csv; posted for the companion paper "The Ego is No
#### Fool", same experiment)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online sender-receiver experiment (oTree, July 2020) with students from the
## laboratory pool of the Pontificia Universidad Catolica del Peru, Lima, paid in
## soles. original_dataset.csv stacks the 314 senders and the 317 receivers (two
## files, different people): role, condition, the risk answer, gender and age;
## session numbers and departments are dropped and subjects are row numbers.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (Dohmen et al. 2011), 0-10,
## "risk seeking" in the authors' code.
## gender: the authors code male = (gender == 1), so 1 = man and 2 = woman; the 3
## other answers (3 or 4) are set to NA. In this sample women answer slightly
## higher than men (6.86 against 6.50).
df <- read_csv("Data/Burro_Castagnetti_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = case_when(gender_code == 2 ~ 1, gender_code == 1 ~ 0, TRUE ~ NA_real_),
            choice = risk_0to10,
            task = "quest_only",
            country = "Peru")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Burro2022",
         paper = "Burro and Castagnetti 2022")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Burro_Castagnetti_2022/formatted_dataset.csv")
