#### Itaya, J., Mizushima, A. & Kurosaka, K. (2023). Endogenous timing and
#### income inequality in the voluntary provision of public goods: Theory and
#### experiment. Canadian Journal of Economics, 56(4), 1347-1377.
#### Data: Canadian Journal of Economics Dataverse (Borealis),
#### https://doi.org/10.5683/SP3/NTAAEY (Q_Data.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## z-Tree experiment on the voluntary provision of public goods, 12 sessions at
## the Research Institute for Socionetwork Strategies of Kansai University,
## Japan, 8 to 12 November 2021, 172 students recruited through ORSEE.
## original_dataset.csv is Q_Data.tab of the repository, the post-experiment
## questionnaire, unchanged.
##
## There is no incentivised risk elicitation in this study. What it does carry
## is the general willingness-to-take-risks question, already on the 0 to 10
## scale (sub_risk), which the paper uses as the control it calls "Willingness
## to take risks". So the rows are marked 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## One subject left the questionnaire blank and is dropped, leaving 171.
## sex is the authors' coding, 1 female and 2 male, as their do file states.
## Age is the year of the experiment minus the year of birth.
df <- read_csv("Data/Itaya_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(!is.na(sub_risk)) %>%
  transmute(subject = id,
            task = "quest_only",
            choice = sub_risk,
            age = 2021 - birth,
            gender = case_when(sex == 1 ~ 1, sex == 2 ~ 0, TRUE ~ NA_real_),
            bibkey = "Itaya2023",
            paper = "Itaya et al. 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

df$country = 'Japan'
df$city = 'Suita'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Itaya_et_al_2023/formatted_dataset.csv")
