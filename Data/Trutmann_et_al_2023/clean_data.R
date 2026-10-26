#### Trutmann, K., Heinke, S. & Rudin, C. (2023). Degree of personal
#### responsibility in decisions and the likelihood to abandon an investment
#### among professionals: Evidence from a lab-in-the-field experiment.
#### Journal of Behavioral Finance, 26(1), 46-63.
#### https://doi.org/10.1080/15427560.2023.2228549
#### Data: supplementary files of the article (placed directly in this folder)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment with 167 employees of the finance and
## controlling department of one of the largest infrastructure companies in
## Switzerland, invited by email in July and August 2019. The experiment itself
## is a repeated investment task about abandoning a losing investment, which is
## not a risk elicitation, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## The questionnaire is the seven-domain SOEP battery of Dohmen et al. (2011),
## all on 0 to 10 ("0 not willingness to take risks, 10 very willing to take
## risks" in the authors' codebook). Two of the seven have slots on this site:
## riskgeneral is the general item (soep) and riskinvestment is the financial
## one (soep_financial). The other five -- driving, leisure, career, health,
## social -- have no slot and are left out.
##
## gender is 1 if female, stated in the note to the paper's Table 1 ("gender,
## dummy variable taking on the value of 1 if the participant is female, 0
## otherwise"), which is already this site's convention; 39.5% of the sample.
## No missing values anywhere in the four columns used.
df <- read_csv("Data/Trutmann_et_al_2023/trutmann_heinke_rudin_2023_data_risk_preferences.csv",
               show_col_types = FALSE)

stopifnot(nrow(df) == 167)

df <- df %>%
  transmute(subject = subjectid,
            task = "quest_only",
            choice = as.numeric(riskgeneral),
            soep_financial = as.numeric(riskinvestment),
            gender = as.numeric(gender),
            age = as.numeric(age),
            bibkey = "Trutmann2023",
            paper = "Trutmann et al. 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## one Swiss company, no city given
df$country = 'Switzerland'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Trutmann_et_al_2023/formatted_dataset.csv")
