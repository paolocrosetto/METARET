#### Rentschler, L. & Samad, Z. (2025).
#### Reducing misinformation on social media: an experimental evaluation of two
#### policy interventions. Experimental Economics.
#### https://doi.org/10.1017/eec.2026.10040
#### Data: https://www.openicpsr.org/openicpsr/project/240630

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## The misinformation game itself is not a risk elicitation task. After it, every
## subject did a bomb risk elicitation task and answered the Global Preferences
## Survey questions, and that is what is kept here.
##
## dataset.dta is in long format, twenty periods per subject, while the risk task
## was played once at the end: boxes_collected is constant within subject
## (checked), so one row per subject is enough. 201 subjects over 13 sessions at
## the Utah State University Experimental Economics Laboratory, Spring 2022,
## which matches the README.
df <- read_dta("Data/Rentschler_Samad_2025/original_dataset.dta") %>%
  distinct(subject_id, .keep_all = TRUE)

## Bomb risk elicitation task of Crosetto and Filippin (2013). Footnote 7 of the
## paper: a hundred boxes, one of which hides a bomb, five cents per collected
## box, nothing if the bomb is among them. choice = boxes collected, 1-100; the
## three subjects who took all hundred sit at the corner value.
##
## WTtakerisk is the general willingness to take risks on a 0-10 scale, taken
## from the Global Preferences Survey (Falk et al. 2018) rather than the SOEP,
## but it is the same instrument and scale, so it goes in the soep column as for
## the other papers.
df <- df %>%
  transmute(subject = as.numeric(subject_id),
            choice = as.numeric(boxes_collected),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = as.numeric(female),
            soep = as.numeric(WTtakerisk))

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "BRET",
         bibkey = "Rentschler2025",
         paper = "Rentschler and Samad 2025")

## Utah State University Experimental Economics Laboratory, Logan, Utah.
df$country = 'United States'
df$city = 'Logan'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Rentschler_Samad_2025/formatted_dataset.csv")
