#### Minnich, A., Roggenkamp, H. & Lange, A. (2024).
#### Ambiguity attitudes and surprises: Experimental evidence on communicating
#### new information within a large population sample.
#### Journal of Economic Behavior & Organization, 228, 106778.
#### https://doi.org/10.1016/j.jebo.2024.106778
#### Data: https://osf.io/hk6jr

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## An online study on a sample invited to be representative of Germany by the
## market research institute Respondi, with quotas on gender, age (18 to 69)
## and region, run between 2 and 14 September 2021. 1505 completed surveys.
##
## Two files are used. original_dataset.csv holds the questionnaire block of
## the oTree export, one row per participant who reached it; analysis_sample.csv
## is the authors' own cleaned file, two rows per subject (one per elicitation
## stage), and it defines the 1505 they analyse.
q <- read_csv("Data/Minnich_et_al_2024/original_dataset.csv", show_col_types = FALSE) %>%
  rename_with(~ str_remove(., "^Outro\\.1\\.player\\."))
keep <- read_csv("Data/Minnich_et_al_2024/analysis_sample.csv", show_col_types = FALSE) %>%
  filter(stage == 1) %>%
  distinct(participant.code)
stopifnot(nrow(keep) == 1505)

## WHY quest_only. The incentivised task is Baillon et al.'s matching
## probability method applied to tomorrow's weather in a named town, twelve
## rounds of it. That measures AMBIGUITY attitudes, not risk: the bets are on
## events whose probabilities are unknown, which is the whole point of the
## paper, and this site's scale is not defined for them.
##
## What is kept is the general risk question, which the paper states plainly:
## "For the general risk attitude question, we used the measurement method of
## Dohmen et al." Its Table reports the mean at 4.19 over 1505, and the column
## gives 4.193. No answer is missing.
##
## The questionnaire also carries a weather-specific risk item that the authors
## built "related to Dohmen et al."; it is a domain this site has no column
## for, so it is left out.
##
## Gender is a word. The six who answered "diverse" and the two who declined
## are left missing. The direction is the usual one: men average 4.72 against
## women's 3.64.
##
## Age is self-reported in years. Two entries, 5 and 6, are below the panel's
## own 18 to 69 quota and are set missing; the rest run 18 to 69 with a mean
## of 43.8.
df <- q %>%
  semi_join(keep, by = "participant.code") %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(Risk_General),
            gender = case_when(Gender == "female" ~ 1,
                               Gender == "male" ~ 0,
                               TRUE ~ NA_real_),
            age = if_else(as.numeric(Age) >= 18 & as.numeric(Age) <= 69,
                          as.numeric(Age), NA_real_),
            bibkey = "Minnich2024",
            paper = "Minnich et al. 2024")
stopifnot(nrow(df) == 1505, !any(is.na(df$choice)))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## An online panel drawn across Germany by region quota, so no single city.
df$country = 'Germany'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Minnich_et_al_2024/formatted_dataset.csv")
