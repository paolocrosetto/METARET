#### Stueber, R. (2024). Why high incentives cause repugnance: A framed field
#### experiment. The Economic Journal, 134(662), 2580-2620.
#### https://doi.org/10.1093/ej/ueae018
#### Data: Zenodo, https://doi.org/10.5281/zenodo.10776523 (final_data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Framed field experiment on why paying people more can make a transaction
## look repugnant. Participants were recruited by the agency Norstat to match
## the German general population on age, gender, education, household size and
## region: wave 1 in February 2020 (1,062 people) and wave 2 in June 2021
## (1,396). A third wave of 170 is members of the German Ethics Council and of
## ethics committees at the ten largest German public universities.
##
## There is NO risk elicitation task here. The experiment itself measures the
## willingness to approve a monetary offer (WTP_Low, WTP_High), which is not a
## lottery, so this paper enters the site as quest_only.
## The questionnaire does carry the SOEP item word for word (screen 14 of
## documents/20220645_instructions_English.pdf): "How do you see yourself: Are
## you generally a person who is fully prepared to take risks or do you try to
## avoid taking risks? The value 0 means 'not at all willing to take risks' and
## the value 10 means 'very willing to take risks.'" That is the soep slot.
##
## Kept: the 1,925 subjects who answered it - all of wave 1 and 863 of wave 2.
## The ethics-committee wave was never asked the question, so it drops out by
## itself. gender: the authors' female dummy. age: their age_adj, which already
## excludes implausible years.
df <- read_csv("Data/Stueber_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 2628)

df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(risk),
            age = as.numeric(age),
            gender = as.numeric(female),
            bibkey = "Stueber2024",
            paper = "Stueber 2024")
stopifnot(nrow(df) == 1925, all(df$choice >= 0 & df$choice <= 10))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## an online panel matched to the German population; the map shows the country
df$country = 'Germany'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Stueber_2024/formatted_dataset.csv")
