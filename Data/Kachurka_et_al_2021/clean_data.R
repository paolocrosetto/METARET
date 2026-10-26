#### Kachurka, R., Krawczyk, M. & Rachubik, J. (2021). State lottery in the
#### lab: An experiment in external validity. Experimental Economics, 24(4),
#### 1242-1266. https://doi.org/10.1007/s10683-020-09696-2
#### Data: electronic supplementary material 1 (10683_2020_9696_MOESM1_ESM.xls,
#### sheet "Coded")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Pen-and-paper lab experiment at the Faculty of Economic Sciences, University
## of Warsaw: participants chose how many numbers to bet on in a real state
## lottery draw, under five between-subject framings. Sessions on 14 August,
## 16 September, 3 October and 24 October 2019 (session_date). The paper also
## ran a Holt and Laury list, but the supplement holds no list choices, so the
## rows are 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
##
## The questionnaire asks the risk questions of Dohmen et al. (2011), 0 ... 10:
## the general item (dohmen_general, missing for 8 participants) and the one on
## financial matters (dohmen_finance), which goes to soep_financial.
## gender: male 1 flipped to the site's female 1. 326 participants.
df <- read_csv("Data/Kachurka_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 326, all(df$dohmen_general %in% c(0:10, NA)),
          all(df$dohmen_finance %in% 0:10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = dohmen_general,
            soep_financial = dohmen_finance,
            gender = 1 - male,
            age,
            bibkey = "Kachurka2021",
            paper = "Kachurka et al. 2021")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## University of Warsaw; the map shows only the country
df$country = 'Poland'
df$city = 'Warsaw'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kachurka_et_al_2021/formatted_dataset.csv")
