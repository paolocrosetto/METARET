#### Kölle, F., Quercia, S. & Tripodi, E. (2025).
#### Social preferences under the shadow of the future.
#### Experimental Economics, 28(1), 22-42.
#### https://doi.org/10.1017/eec.2024.11
#### Data: https://osf.io/xv72k

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Indefinitely repeated prisoner's dilemmas with sorting on social
## preferences, run in oTree in German. The package's Sessions_clean_complete
## file is the round-by-round panel, 74,658 rows; the questionnaire answers are
## constant within a subject, so one row each was copied here. That gives 1074,
## which is the number the online appendix reports (477 prosocial and 597
## selfish types).
df <- read_csv("Data/Koelle_et_al_2025/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 1074)

## WHY quest_only: the experiment contains no choice over lotteries at all --
## the decisions are cooperate or defect, a norm-elicitation task and an IQ
## test.
##
## The survey item is the general risk question, and the oTree app gives it in
## the original German (pd_questionnaire, Page1.html): "Wie schätzen Sie sich
## persönlich ein: Sind Sie im Allgemeinen ein risikobereiter Mensch oder
## versuchen Sie, Risiken zu vermeiden? Das äußerst linke Kästchen bedeutet
## 'gar nicht risikobereit', und das äußerst rechte 'sehr risikobereit'."
## That is the SOEP wording word for word, answered on eleven boxes, and the
## column runs 0 to 10 with no gaps and nothing missing.
##
## female is already 1 for women, 662 of 1074. The direction is the usual one:
## men average 5.60 against women's 4.65. No age was collected.
##
## TWO LABORATORIES. The online appendix lists the five treatment blocks with
## their sites and sizes, and the session numbers reproduce all five exactly:
## sessions 1-8 are the main experiment in Cologne (240), 9-17 the high-delta
## treatment in Cologne (270), 18-20 random matching in Cologne (78), 21-30
## unannounced matching in Bonn (288) and 31-38 the long-run treatment in Bonn
## (198). So sessions up to 20 are Cologne and the rest Bonn.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk_taking),
            gender = as.numeric(female),
            age = NA_real_,
            bonn = session > 20,
            bibkey = "Koelle2025",
            paper = "Koelle et al. 2025")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

df <- df %>%
  mutate(country = 'Germany',
         city = if_else(bonn, 'Bonn', 'Cologne'),
         lattitude = if_else(bonn, '50.7340', '50.9287'),
         longitude = if_else(bonn, '7.1016', '6.9286')) %>%
  select(-bonn)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Koelle_et_al_2025/formatted_dataset.csv")
