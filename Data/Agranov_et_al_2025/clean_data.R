#### Agranov, M., Dasgupta, U. & Schotter, A. (2025). Trust me: Communication
#### and competition in a psychological game. Journal of the European Economic
#### Association. https://doi.org/10.1093/jeea/jvae012
#### Data: supplementary data of the journal
#### (jvae012_Agranov_Dasgupta_Schotter_Data_Files)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment at the CESS lab in New York on communication and
## competition in a trust-style psychological game.
##
## After the main part subjects did a Gneezy-Potters investment task, worded in
## the instructions that ship with the package (instructions/instructionsRisk.
## docx): 200 tokens at 1 token = 1 cent, invest any amount, the project
## succeeds with probability 1/2 and pays 2.5 times the stake, otherwise the
## stake is lost. A second question repeats it at a 40% chance and 3 times the
## stake. One of the two was drawn for payment.
##
## ONLY 49 SUBJECTS. subjects.dta covers 165 people (session and Subject
## together identify them), but risk1 and risk2 are filled for just 49 of them.
## I looked through every .dta in the package, including the temp folder, and
## found no fuller version: risktemp.dta has 26 rows and subjects_exp.dta the
## same 49. The paper describes a larger experiment, so the published data
## evidently carry the investment task for part of the sample only - worth
## asking the authors for the rest.
## Only the first question is used, since the site holds one coefficient per
## subject per task; risk2 is kept in original_dataset.csv for reference.
## The package has no gender or age.
df <- read_csv("Data/Agranov_et_al_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 49, all(df$risk1 >= 0 & df$risk1 <= 200))

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = risk1,
            age = NA_real_,
            gender = NA_real_,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Agranov2025",
         paper = "Agranov et al. 2025")

## the CESS laboratory is in New York
df$city = 'New York'
df$lattitude = '40.7291'
df$longitude = '-73.9965'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Agranov_et_al_2025/formatted_dataset.csv")
