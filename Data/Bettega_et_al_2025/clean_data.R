#### Bettega, P., Crosetto, P., Dubois, D. & Romaniuc, R. (2025). Hard vs. soft
#### commitments: experimental evidence from a sample of French gamblers.
#### Theory and Decision, 98, 447-472. https://doi.org/10.1007/s11238-024-10016-w
#### Data: https://github.com/paolocrosetto/temptation_experiment_data_and_analysis

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is the authors' temptation_data.csv (one row per subject
## and round) without the panel identifier (participant.label) and the oTree
## session code; participant.code is replaced by a number.
## 1527 clients of la Francaise des Jeux, recruited through the Bilendi panel,
## online oTree experiment. One of the ten rounds was paid (Amazon gift card).
## Static BART: in each round the subject picks a number of pumps 1 ... 64 in
## advance; each pump is worth 0.15 EUR and the balloon bursts at a point drawn
## uniformly from 1 ... 64 (urn of 64 tokens, without replacement). The chosen
## number is recorded whether or not the balloon burst, so there is no
## truncation. Rounds 1-5 are identical in both treatments (the commitment
## device is offered only from round 6), so choice = mean pumps over rounds 1-5.
## female: 1 = woman, 0 = man.
df <- read_csv("Data/Bettega_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(subsession.round_number <= 5) %>%
  group_by(participant.code) %>%
  summarise(choice = mean(player.pumps),
            age = first(age),
            gender = first(female),
            .groups = "drop") %>%
  transmute(subject = participant.code,
            task = "BART",
            choice, age, gender,
            country = "France")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Bettega2025",
         paper = "Bettega et al. 2025")

## online experiment, and the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bettega_et_al_2025/formatted_dataset.csv")
