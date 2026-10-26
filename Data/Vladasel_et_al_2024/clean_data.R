#### Vladasel, T., Parker, S. C., Sloof, R. & van Praag, M. (2024).
#### Revenue drift, incentives, and effort allocation in social enterprises.
#### Journal of Economics & Management Strategy, 33(3), 630-651.
#### https://doi.org/10.1111/jems.12590
#### Data: Harvard Dataverse 10.7910/DVN/XMLLDZ

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## An online experiment on Prolific, with the subject pool restricted to UK
## residents aged 18 to 64 who are students or active in the labour force.
## The published file already applies every exclusion the paper describes,
## leaving the 708 subjects it analyses (out of 796 responses).
df <- read_dta("Data/Vladasel_et_al_2024/original_dataset.dta")
stopifnot(nrow(df) == 708)

## WHY quest_only. The experiment is about effort allocation between a social
## and a commercial task under three contracts, and nothing in it elicits risk
## preferences. The two columns that look like candidates are not: `lottery`
## is how much of a hypothetical 1000-pound win the subject would share, which
## the paper labels hypothetical altruism, and `choice` is the contract picked
## (fixed pay, bonus pay or self-employment), the paper's outcome variable.
##
## The survey item is the general risk question on the usual scale: the paper
## says it measures "self-reported risk-taking (Risk) and future discounting
## (Time) preferences on a 0-10 scale (Dohmen et al.)", and its summary table
## reports Risk taking at 5.130 with a standard deviation of 2.474 over all
## 708, which the column reproduces. No answer is missing.
##
## female is already 1 for women, 353 of 708, and the randomisation was
## stratified on gender, which is why the split is almost exactly even. The
## direction is the usual one: men average 5.62 against women's 4.64.
##
## Age was asked in five brackets. The first and last are open, but the
## recruitment filter closes them: the pool was restricted to ages 18 to 64,
## so "Under 25" is 18 to 24 and "55 or older" is 55 to 64, and all five
## midpoints are well defined.
age_mid <- c(21, 29.5, 39.5, 49.5, 59.5)

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(riskwill),
            gender = as.numeric(female),
            age = age_mid[as.integer(age)],
            bibkey = "Vladasel2024",
            paper = "Vladasel et al. 2024")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Online on Prolific; the pool was restricted to residents of the United
## Kingdom, and no city is recorded.
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Vladasel_et_al_2024/formatted_dataset.csv")
