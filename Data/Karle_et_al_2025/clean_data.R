#### Karle, H., Kerzenmacher, F., Schumacher, H. & Verboven, F. (2025).
#### Search Costs and Context Effects.
#### American Economic Journal: Microeconomics, 17(2), 127-161.
#### https://doi.org/10.1257/mic.20240115
#### Data: openICPSR https://doi.org/10.3886/E207961V1

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## A consumer search experiment run on Amazon Mechanical Turk, on Prolific and
## with students in Innsbruck. The replication package keeps each sample in its
## own folder and its own file -- MTurk, Prolific, Students, two robustness
## waves and two multi-item waves, seven in all. No participant id appears in
## more than one of them, so the samples are disjoint: 626 + 460 + 581 + 304 +
## 306 + 191 + 159 = 2627 people.
##
## Each file carries several hundred columns of search behaviour. Only the six
## needed here were copied out, by extract_from_raw.R next to this file, into
## original_dataset.csv: the sample, the id, the two risk items, age and sex.
##
## There is no risk elicitation task in the experiment -- what it elicits is
## search -- so the rows are 'quest_only' and generate_data_for_app.R moves
## `choice` into `soep`.
##
## riskgen is the general willingness to take risks and riskfin the same
## question for financial matters, both already on the 0 to 10 scale the site
## uses, so nothing is rescaled.
df <- read_csv("Data/Karle_et_al_2025/original_dataset.csv", show_col_types = FALSE)

## A handful of ages are impossible (0, 1 and 3) and one is 94; everything
## outside 15 to 100 is dropped to missing rather than guessed.
df <- df %>%
  arrange(sample, id) %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = riskgen,
            soep_financial = riskfin,
            gender = female,
            age = if_else(age >= 15 & age <= 100, age, NA_real_),
            bibkey = "Karle2025",
            paper = "Karle et al. 2025",
            ## only the student sample has a known place; the rest were online
            country = if_else(sample == "students", "Austria", NA_character_),
            city = if_else(sample == "students", "Innsbruck", ""))

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

df$lattitude = if_else(df$city == "Innsbruck", "47.2692", "")
df$longitude = if_else(df$city == "Innsbruck", "11.4041", "")

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Karle_et_al_2025/formatted_dataset.csv")
