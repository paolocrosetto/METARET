#### Babin, J. J., Chauhan, H. & Tiwari, M. (2026).
#### Sibling kinship, prosociality, language AI, and norms.
#### Judgment and Decision Making, 21, e5. https://doi.org/10.1017/jdm.2026.10032
#### Data: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/8LIGQ5

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## sibsALLcsv.csv from Dataverse, one row per subject: 859 Prolific participants
## (international, mostly US). Only the treatment, the lottery choice, age,
## gender and country of residence were copied here; the Prolific id, IP
## address, location coordinates and free-text answers were left out.
## After three games, subjects chose one of five 50/50 gambles (instrument p. 12;
## 100 tokens = 1 dollar), paid with the bonus of the games:
##   1 = 10/10, 2 = 18/6, 3 = 26/2, 4 = 34/-2, 5 = 42/-6 tokens.
## risktolerance = number of the gamble (1 = safest). This is METARET's EG_loss.
## The paper finds no difference in risk choices across the sibling-cue
## treatments, so all are kept. female: 1 = female.
df <- read_csv("Data/Babin_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "EG_loss",
            choice = risktolerance,
            age = as.numeric(age),
            gender = as.numeric(female),
            country = countryofresidence,
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Babin2026",
         paper = "Babin et al. 2026")

## online experiment, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Babin_et_al_2026/formatted_dataset.csv")
