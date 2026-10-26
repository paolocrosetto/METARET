#### Diecidue, E., Guecioueur, A. & Xia, Q. (2026). Trusting human versus
#### machine predictions as a decision under ambiguity.
#### Journal of Risk and Uncertainty, 72, 455-483.
#### https://doi.org/10.1007/s11166-026-09485-x
#### Data: https://osf.io/zrkew

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment in oTree at the INSEAD-Sorbonne Behavioral Lab in
## Paris, April to July 2023, run in French. The tasks elicit matching
## probabilities for events about the accuracy of human and machine analysts,
## which is ambiguity, not risk, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## Between the two tasks a survey asked, on 0 to 10 scales (the wording is in
## the Study Material file of the package, page 9): "Etes-vous generalement une
## personne qui est prete a prendre des risques ou essayez-vous d'eviter de
## prendre des risques?" -- the SOEP general item -- and "Je suis generalement
## pret a prendre des risques dans le domaine financier" -- the financial item
## of the Preference Survey Module (Falk et al. 2023), which goes to
## soep_financial as for Trutmann, Heinke and Rieskamp 2023.
##
## "A total of 203 participants completed the study, including 123 females, 78
## males, and 2 who preferred not to specify their gender." All 203 are kept:
## the paper's exclusions (weak monotonicity of matching probabilities) concern
## the ambiguity task, not the survey. The authors' script codes the gender
## answer as `male` (1 male, 0 female, 2 not said); the counts match the paper
## exactly. Age was not asked.
df <- read_csv("Data/Diecidue_et_al_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 203, sum(df$male == 0) == 123, sum(df$male == 1) == 78,
          all(df$risk_general %in% 0:10), all(df$risk_financial %in% 0:10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(risk_general),
            soep_financial = as.numeric(risk_financial),
            gender = case_when(male == 0 ~ 1, male == 1 ~ 0, TRUE ~ NA_real_),
            age = NA_real_,
            bibkey = "Diecidue2026",
            paper = "Diecidue et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## INSEAD-Sorbonne Universite Behavioral Lab, Paris
df$country = 'France'
df$city = 'Paris'
df$lattitude = '48.8462'
df$longitude = '2.3448'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Diecidue_et_al_2026/formatted_dataset.csv")
