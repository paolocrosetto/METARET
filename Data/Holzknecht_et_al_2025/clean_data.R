#### Holzknecht, A., Huber, J., Kirchler, M. & Neugebauer, T. (2025).
#### Speculating in zero-value assets: The greater fool game experiment.
#### European Economic Review, 180, 105180.
#### https://doi.org/10.1016/j.euroecorev.2025.105180
#### Data: https://osf.io/gszbw

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## side_tasks.csv from the package's Processed Data folder: one row per
## subject, 470 of them, which is the number the paper states. The other
## cleaned file, individual_data.csv, is the market panel at 20680 rows and
## repeats the same questionnaire answers for every period.
##
## The experiment ran at the EconLab of the University of Innsbruck between
## December 2023 and March 2024. The main task is a greater-fool asset market
## where subjects bid for a token; there is no risk elicitation anywhere in
## the protocol, and the side tasks are a beauty contest, a Nim game, the
## cognitive reflection test, a nine-item fear-of-missing-out questionnaire
## and financial literacy. Hence quest_only.
df <- read_csv("Data/Holzknecht_et_al_2025/original_dataset.csv",
               show_col_types = FALSE)
stopifnot(nrow(df) == 470)

## The questionnaire carries no general risk question, only the domain one, so
## the answer goes into soep_financial and the general column stays empty.
## The oTree app spells the wording out: "How do you see yourself: Are you a
## person who is fully prepared to take risks or do you try to avoid taking
## risks when doing investments?", answered on a slider from "Not willing to
## take risks" to "Very willing to take risks". The paper confirms the range,
## "an 11-point scale (0 = not willing to take risks; 10 = very willing to
## take risks)", and its own Table reports the two treatment groups at 3.60
## and 4.09, whose average 3.845 is what the column gives (3.847). No answer
## is missing.
##
## Gender is a word; the two subjects who answered "diverse" are left missing.
## The direction is the usual one: men average 4.77 against women's 3.22.
## Age is self-reported and runs 18 to 82 -- the 82 is in the paper's own
## table too, so it is kept.
df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = NA_real_,
            soep_financial = as.numeric(soep_investments),
            gender = case_when(gender == "female" ~ 1,
                               gender == "male" ~ 0,
                               TRUE ~ NA_real_),
            age = as.numeric(age),
            bibkey = "Holzknecht2025",
            paper = "Holzknecht et al. 2025")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## EconLab, University of Innsbruck.
df$country = 'Austria'
df$city = 'Innsbruck'
df$lattitude = '47.2654'
df$longitude = '11.3843'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holzknecht_et_al_2025/formatted_dataset.csv")
