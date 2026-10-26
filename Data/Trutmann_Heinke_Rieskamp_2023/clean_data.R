#### Trutmann, K., Heinke, S. & Rieskamp, J. (2023). Take your time: How
#### delayed information and restricted decision opportunities improve belief
#### formation in investment decisions.
#### Finance Research Letters, 51, 103442.
#### https://doi.org/10.1016/j.frl.2022.103442
#### Data: https://osf.io/3zja2 (component "Data" of project kxqda)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment on Prolific in March 2022: a repeated investment task in
## which the asset's price drifts up or down and the subject trades and reports
## beliefs round by round. That task is a dynamic trading exercise rather than a
## risk elicitation, so none of its 6,720 columns are used.
##
## What is used is the questionnaire block (oTree app Individual_Measures),
## which carries the SOEP risk items: soep_general and soep_finance, both on the
## usual 0 to 10 scale. soep_ambiguity and soep_loss_aversion are also asked but
## the site has no slot for them.
##
## Sample. full_data_exp.csv has 616 rows, but only 329 reach the demographics
## page; the rest are abandoned sessions. The paper reports a final sample of
## 315 (156 female, mean age 33.36, SD 10.86). Keeping the subjects who passed
## the attention check and did not ask for their data to be discarded gives 316
## with exactly 156 women, mean age 33.35 and SD 10.85 -- the paper's numbers to
## the last subject. One extra person remains whose exclusion I could not
## reconstruct from the released columns; since their age sits at the mean it
## changes nothing, and they are kept rather than dropped arbitrarily.
##
## original_dataset.csv holds the six columns needed out of the 7,806 in the
## released file.
df <- read_csv("Data/Trutmann_Heinke_Rieskamp_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 329)

df <- df %>%
  filter(attention_check == 1, dont_use_data != 1) %>%
  filter(!is.na(soep_general))

stopifnot(nrow(df) == 316, sum(df$gender == "Female") == 156)

## gender is a free label; "Other" and "No Answer" (three each) go to missing.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(soep_general),
            soep_financial = as.numeric(soep_finance),
            gender = case_when(gender == "Female" ~ 1,
                               gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "TrutmannRieskamp2023",
            paper = "Trutmann, Heinke and Rieskamp 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## country: NOT SET. Prolific study with no country restriction stated in the
## paper. The demographics page offers US census ethnicity categories, which
## hints at an American pool, but a hint is not a statement -- same treatment as
## Horvath2025 and Snowberg2021.
df$country = NA_character_
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Trutmann_Heinke_Rieskamp_2023/formatted_dataset.csv")
