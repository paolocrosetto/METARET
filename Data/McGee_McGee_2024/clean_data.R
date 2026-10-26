#### McGee, A. & McGee, P. (2024).
#### Whoever you want me to be: Personality and incentives.
#### Economic Inquiry. https://doi.org/10.1111/ecin.13220
#### Data: https://doi.org/10.3886/E194887 (openICPSR, downloaded by hand --
#### the platform refuses automated access)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## The experiment is about faking personality tests; the Holt and Laury list run
## in the first (Baseline) session is the risk elicitation task and is all that
## is kept. One row per subject: the paper reports 474 subjects who completed
## both a Baseline and an Evaluation session between 2014 and 2016, which is
## exactly the number of rows.
##
## Note on identifiers: permid repeats across rows and looks like a person key,
## but the repeats are all *negative* values, which are a missing-data
## placeholder -- two rows sharing one of them sit in the same session with
## different ages and sexes. Among the 167 valid, positive permid values there
## are no repeats at all, and preid is unique across all 474 rows. So every row
## is a distinct person and nothing has to be collapsed.
df <- read_dta("Data/McGee_McGee_2024/original_dataset.dta")

## Standard Holt and Laury (2002) low-stakes list, quoted verbatim in the
## instructions appendix: option A pays 200 or 160 pennies, option B pays 385 or
## 10 pennies, with the chance of the high payoff rising from 1/10 to 10/10.
##
## holt1-holt10 are 1 when the subject picked the second option, and the package
## builds hlrisk as 10 minus their sum -- that is, hlrisk counts the *safe*
## choices, despite the name. Checked two ways: the shipped construction code
## sets each holt variable from "option 2", and the surviving patterns are of the
## form 0000000111, safe first and risky in the last rows, which is how a
## consistent subject answers this list. So the number of risky choices, the
## convention used for HL here, is the sum of holt1-holt10.
df <- df %>%
  transmute(subject = as.numeric(preid),
            choice = rowSums(across(num_range("holt", 1:10))),
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = 1 - as.numeric(male))

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "HL",
         bibkey = "McGee2024",
         paper = "McGee and McGee 2024")

## University of Arkansas, Fayetteville.
df$country = 'United States'
df$city = 'Fayetteville'
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
df %>% write_csv("Data/McGee_McGee_2024/formatted_dataset.csv")
