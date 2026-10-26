#### Fuellbrunn, S. & Luhan, W. J. (2020). Responsibility and limited liability
#### in decision making for others: An experimental consideration.
#### Journal of Economic Psychology, 77, 102186.
#### https://doi.org/10.1016/j.joep.2019.06.009
#### Data: deposit of the authors (CC BY), file _PublicationDatensatz.dta

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment in Bochum, Germany, 329 subjects. The experiment is
## about investing on behalf of someone else under limited liability, which is
## not a risk elicitation of the kind the site codes, so the rows are
## 'quest_only' and generate_data_for_app.R moves `choice` into `soep`.
##
## The questionnaire is the Dohmen et al. battery -- the variable label in the
## file reads "Dolmen et al risk measures" -- with a general item and the
## domain items for driving, finance, career, leisure, health and trust. The
## site has slots for the general and the financial one.
##
## THE SCALE RUNS 1 TO 10, not the 0 to 10 of the original. Across 329 subjects
## no one answers 0, and the highest answer is 10, so this is a ten-point
## version rather than an eleven-point one with an empty bottom category. It is
## rescaled linearly onto 0 to 10, as the 1 to 10 answers of Cox et al. 2026
## and Drouvelis and Qiu are. Worth asking the authors to confirm.
##
## risk_lottery is the hypothetical windfall question (how much of 100,000 to
## put in a risky asset, in steps of 20,000). It is not the investment task the
## site codes as IG -- there is no stated probability and no payment -- so it
## is kept in original_dataset.csv for reference only.
df <- read_csv("Data/Fullbrunn_Luhan_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 329,
          all(df$risk_general >= 1 & df$risk_general <= 10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = (as.numeric(risk_general) - 1) * 10 / 9,
            soep_financial = (as.numeric(risk_financial) - 1) * 10 / 9,
            gender = as.numeric(female),
            age = as.numeric(age),
            bibkey = "Fullbrunn2020",
            paper = "Fuellbrunn and Luhan 2020")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## the readme of the deposit gives the location as Bochum, Germany
df$country = 'Germany'
df$city = 'Bochum'
df$lattitude = '51.4818'
df$longitude = '7.2162'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fullbrunn_Luhan_2020/formatted_dataset.csv")
