#### Snowberg, E. & Yariv, L. (2021). Testing the waters: Behavior across
#### participant pools. American Economic Review, 111(2), 687-719.
#### https://doi.org/10.1257/aer.20181065
#### Data: openICPSR, https://doi.org/10.3886/E120227 (SYMainData.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## One incentivized online survey run on four pools, to see how far behaviour
## travels between them:
##   sample 0  SSI, a sample representative of the US population by age, income
##             and gender, spring 2017, 1,000 people, average payment $10.26
##   sample 1  995 US-based Amazon Mechanical Turk users, spring 2016, $10.50
##   sample 2  Caltech Cohort Study, almost the whole Caltech undergraduate
##             body, spring 2015, 819 people
##   sample 3  10 sessions in the UBC lab in Vancouver, summer 2019, 202 people
## Samples 4-6 are earlier CCS waves that did not include these elicitations,
## and sample 7 is the same 96 CCS subjects taking the survey a second time in
## the lab (inLabSample == 1), so neither is used: sample 7 would double count.
## That leaves 3,016 subjects.
##
## Two of the paper's three risk elicitations are used.
## IG: "Risky Projects: Following Gneezy and Potters (1997)" -- an endowment of
## 100 tokens split between keeping them and a project returning 3 tokens per
## token invested with probability 35%. (A second project, 200 tokens at 2.5x
## and 50%, is in the file as secondRiskyProjectAllocation; the site holds one
## coefficient per subject per task, so only the first is used.)
## CEPL: "Risky Urns" -- a price list against an urn of 20 balls, 10 of the
## colour the subject picked, paying 100 tokens. (A second urn of 30 balls
## paying 150 is likewise left out.)
## The compound and ambiguous urns in the file are about ambiguity, not risk,
## and are not used at all.
##
## Questionnaire: qualitativeRisk is "Following Dohmen et al. (2010),
## participants were asked to rate themselves, on a scale of 0-10, in terms of
## their willingness to take risks" -- the SOEP item, so it fills the soep slot.
## It is attached to both task rows, since it is a property of the subject.
##
## gender: the authors' male dummy, inverted. age: birth year is recorded for
## SSI, MTurk and UBC but not for the Caltech students, so age is computed from
## the year each pool was surveyed and is missing for sample 2.
df <- read_csv("Data/Snowberg_Yariv_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 3016,
          all(df$firstRiskyProjectAllocation >= 0 & df$firstRiskyProjectAllocation <= 100),
          all(df$riskyUrn20MaxValue >= 10 & df$riskyUrn20MaxValue <= 100))

survey_year <- c(`0` = 2017, `1` = 2016, `2` = NA, `3` = 2019)

base <- df %>%
  transmute(subject,
            soep = qualitativeRisk,
            age = survey_year[as.character(sample)] - birthYear,
            gender = 1 - male,
            country = if_else(sample == 3, "Canada", "United States"),
            city = case_when(sample == 2 ~ "Pasadena",
                             sample == 3 ~ "Vancouver",
                             TRUE ~ NA_character_),
            ig = firstRiskyProjectAllocation,
            ce = riskyUrn20MaxValue)

df <- bind_rows(
  base %>% mutate(task = "IG",   choice = ig),
  base %>% mutate(task = "CEPL", choice = ce)
) %>%
  select(-ig, -ce)
stopifnot(nrow(df) == 2 * 3016)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Snowberg2021",
         paper = "Snowberg and Yariv 2021")

## two of the four pools are online panels with no single location
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Snowberg_Yariv_2021/formatted_dataset.csv")
