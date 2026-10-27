#### Schwerter, F. (2024). Social Reference Points and Risk Taking. Management
#### Science, 70, 616-632. https://doi.org/10.1287/mnsc.2023.4698
#### Data: Management Science replication package (all.dta); the price list is in
#### the e-companion (mnsc.2023.4698.sm1.pdf, Appendix D) and the questionnaire in
#### Part2-translation.pdf

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 397 subjects at the BonnEconLab, Germany. The main task of the paper (one
## lottery picked with a slider from a convex set, upside 3 to 16.5 EUR) is not
## used: it is the outcome the treatments manipulate by showing peer earnings.
## The measures come from the second part, 1-2 weeks later, which 367 subjects
## attended:
##  - a price list of 20 decisions, a sure 3 EUR against a lottery paying 3.40
##    EUR with 97% ... 16.23 EUR with 2%, else 0 (Appendix D, Table D.2), paid.
##    The file keeps only the row where the subject moved to the sure 3 EUR
##    (riskattitude; 21 = never moved); for subjects who switched several times
##    the authors stored the mean row, a non-integer, and these 63 have no task
##    row here. It pitches a sure amount against a lottery, so it is CEPL;
##  - the SOEP question "are you a person who is generally willing to take
##    risks, or do you try to avoid taking risks?", 0-10 (screen 34). It goes in
##    soep for subjects with a task row and as quest_only for the other 63.
## The hypothetical certainty equivalent of a 50% chance of 1,000 EUR (risk2) is
## not used. original_dataset.csv keeps wave, treatment flags, the upside chosen,
## age, the SOEP answer and the switching row; the authors' ids are dropped and
## subjects are row numbers. The package has no sex variable.
df <- read_csv("Data/Schwerter_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 397, sum(!is.na(df$switch_row)) == 367)

df <- df %>%
  filter(!is.na(switch_row)) %>%
  mutate(single = switch_row %% 1 == 0)

stopifnot(sum(df$single) == 304)

df <- df %>%
  transmute(subject,
            task = if_else(single, "CEPL", "quest_only"),
            ## choice is what generate_data_for_app.R moves into soep for quest_only
            choice = if_else(single, switch_row, soep_risk),
            soep = if_else(single, soep_risk, NA_real_),
            age,
            gender = NA_real_,
            country = "Germany",
            bibkey = "Schwerter2024",
            paper = "Schwerter 2024")

source("Data/generate_r.R")
cepl <- df$task == "CEPL"
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Schwerter_2024/formatted_dataset.csv")
