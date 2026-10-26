#### Grimalda, G., Murtin, F., Pipke, D., Putterman, L. & Sutter, M. (2026).
#### Did the outbreak of COVID-19 and individual exposure to it increase or
#### decrease trust? Economica, 93, 1421-1445.
#### https://doi.org/10.1111/ecca.70062
#### Data: OSF, https://doi.org/10.17605/OSF.IO/97FYT
#### (code_and_data.zip, Trustlab_Covid.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Two online waves of the OECD Trustlab platform with nationally
## representative samples of the United States: 1,090 respondents in wave 1
## (before the pandemic) and 1,120 in wave 2 (during it). The waves are
## independent cross-sections -- all 2,210 respondent ids are distinct -- so
## every row is one person. original_dataset.csv is the repository file reduced
## to the wave, the risk variables and the demographics.
##
## Task: the Trustlab gamble choice, six 50-50 gambles given in the platform
## instructions in the repository and identical in both waves: 8/8, 7/10, 6/12,
## 5/14, 4/16 and 1/19 dollars. choice = gamble number, the stored risk_game
## plus one.
##
## risk_sv is the general willingness-to-take-risks question on the 0-10 scale,
## carried over as soep. It was only asked in wave 1, so 1,131 of the rows have
## none.
df <- read_csv("Data/Grimalda_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "EG",
            choice = risk_game + 1L,
            soep = risk_sv,
            age,
            gender = fem_resp,
            country = "United States")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Grimalda2026",
         paper = "Grimalda et al. 2026")

## nationally representative online samples, so no city
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Grimalda_et_al_2026/formatted_dataset.csv")
