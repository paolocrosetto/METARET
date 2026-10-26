#### Dambaur, A. J. & Jaspersen, J. G. (2026).
#### Insurance as commitment?
#### Journal of Risk and Insurance.
#### https://doi.org/10.1111/jori.70080
#### Data: Dataverse FAVYZZ

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(jsonlite)

#### getting the data
## The oTree export is a wide JSON, one field per column and the participant
## index as the key. It holds 328 keys, but `finished` is 1 for exactly 199 of
## them and that is the sample the authors analyse throughout 03_analysis.R;
## the rest dropped out of a study that ran over four weekly sessions.
raw <- fromJSON("Data/Dambaur_Jaspersen_2026/original_dataset.json")
df <- as_tibble(map_dfc(raw, ~ as.character(.x[order(as.numeric(names(.x)))]))) %>%
  rename_with(~ str_remove(., "^participant\\."))

df <- df %>% filter(finished == "1")
stopifnot(nrow(df) == 199)

## WHY quest_only, even though the experiment is incentivised: the willingness
## to pay for insurance is the paper's dependent variable, not an elicitation.
## It is asked twice per subject under the two treatments (wtpf without and
## wtpc with a commitment device), the price is drawn at random for a
## Becker-DeGroot-Marschak auction, and the loss itself is a transcription
## workload rather than money, so the number carries the treatment effect the
## paper is measuring. The package also recovers a pair (beta, gamma) per
## subject, and gamma is a curvature parameter; it is not used anywhere in the
## paper's analysis, it is read off a grid jointly with the present-bias
## parameter from a hypothetical savings decision under four assumed values
## (w = 500, p = 0.25, L = 1000, delta = 1), and the utility in build_grid.jl
## is written x^(1+gamma)/(-1-gamma), whose derivative is -x^gamma, i.e.
## decreasing in wealth -- a sign slip that makes the scale of gamma
## unreadable. Neither quantity belongs on this site's CRRA scale.
##
## What is kept is the survey: section 4 of the paper says the final
## questionnaire carries "the general risk question of Dohmen et al. (2011)",
## and Table 2 reports it at 4.65 with a standard deviation of 2.01, which the
## raw column reproduces exactly, as do the two treatment groups (4.78 and
## 4.52). Values are used as stored, since that is the scale the paper reports
## and compares with other studies' means. One oddity worth recording: the
## answer 9 appears zero times although 8 appears 16 times and 10 once, so one
## interior point of the scale looks never to have been offered.
##
## The direction is the usual one: men average 5.31 against women's 4.38.
## Gender matches Table 1 exactly (135 women, 62 men); the one non-binary
## subject and the one who declined are left missing.
##
## Age was asked in brackets only, so the midpoints are used, the same
## treatment as in the files for Burro et al. and Gonzalez Jimenez et al. The
## six bracket counts reproduce Table 1 (99, 71, 22, 3, 3, 1).
age_mid <- c("18-24 years" = 21, "25-34 years" = 29.5, "35-44 years" = 39.5,
             "45-54 years" = 49.5, "55-64 years" = 59.5, "65-74 years" = 69.5)

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = as.numeric(general_risk),
            gender = case_when(gender == "female" ~ 1,
                               gender == "male" ~ 0,
                               TRUE ~ NA_real_),
            age = unname(age_mid[age]),
            bibkey = "Dambaur2026",
            paper = "Dambaur and Jaspersen 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## Run online with the subject pool of MELESSA, the Munich Experimental
## Laboratory for Economic and Social Sciences at Ludwig-Maximilians-
## Universitaet Muenchen; 195 of the 199 report German nationality.
df$country = 'Germany'
df$city = 'Munich'
df$lattitude = '48.1508'
df$longitude = '11.5802'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Dambaur_Jaspersen_2026/formatted_dataset.csv")
