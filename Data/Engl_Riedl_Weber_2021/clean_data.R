#### Engl, F., Riedl, A. & Weber, R. (2021). Spillover effects of institutions on
#### cooperative behavior, preferences, and beliefs.
#### American Economic Journal: Microeconomics, 13(4), 261-299.
#### https://doi.org/10.1257/mic.20180336
#### Data: openICPSR project 128682 (AEJMicro_2018_0336.R2_data_pgg.dta and
#### AEJMicro_2018_0336.R2_data_trust.dta), downloaded by hand

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiments (z-Tree) with students in Maastricht (BEElab) and Zurich
## (LEE/UZH and ETH). original_dataset.csv keeps one row per subject from the two
## authors' files: study (public goods or trust variant), wave, treatment, the risk
## answer, sex and age; session ids and the subject numbers are dropped.
## Waves (paper, section II and VI): main study, 136 subjects in Maastricht
## (November 2014) and 136 in Zurich (February 2015); follow-up treatments, 192
## subjects (2016) and trust treatments, 184 subjects (2019), each with half of
## the sessions in Maastricht and half in Zurich -- which sessions ran where is not
## in the files, so the country of these two waves is left empty.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the self-reported risk attitude of Part V, the SOEP general
## risk question on 0-10 (women 5.73, men 6.49). female: 1 = woman, 0 = man.
df <- read_csv("Data/Engl_Riedl_Weber_2021/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk,
            task = "quest_only",
            country = case_when(wave == "2014 Maastricht" ~ "Netherlands",
                                wave == "2015 Zurich" ~ "Switzerland",
                                TRUE ~ NA_character_))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Engl2021",
         paper = "Engl et al. 2021")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Engl_Riedl_Weber_2021/formatted_dataset.csv")
