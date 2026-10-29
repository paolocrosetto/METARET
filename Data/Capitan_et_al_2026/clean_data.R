#### Capitán, T., Thunström, L., van 't Veld, K., Nordström, J. & Shogren, J. (2026).
#### Show me the labels: Using pre-nudges to reduce calorie information avoidance.
#### Journal of Risk and Uncertainty, 72, 1-39.
#### https://doi.org/10.1007/s11166-025-09471-9
#### Data: https://github.com/tabareCapitan/jru-2026
#### (do-files, codebooks, questionnaires and the raw Qualtrics exports are in
#### raw_repository/; IP addresses and the Qualtrics GPS coordinates are removed
#### from every csv, and the MTurk export that was not de-identified
#### (instructions/online/) is not copied -- the _no_personal_data one is used)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Qualtrics exports: row 1 the variable names, row 2 the question texts, row 3
## the import ids, then one row per response. Columns are found by name or by
## question text, since the lab background survey repeats some names.
read_qualtrics <- function(f) {
  x <- read_csv(f, col_names = FALSE, col_types = cols(.default = "c"), na = character())
  list(names = unlist(x[1, ]), text = unlist(x[2, ]), data = x[-(1:3), ])
}
pick <- function(q, name = NULL, text = NULL) {
  j <- if (!is.null(name)) which(q$names == name) else which(startsWith(q$text, text))
  stopifnot(length(j) == 1)
  q$data[[j]]
}

## The risk question, the same in both experiments and NOT incentivized ("a
## simple, non-incentivized measure based on Eckel and Grossman (2002)"): six
## 50/50 gambles, low/high $28/28, 24/36, 20/44, 16/52, 12/60, 2/70. The answer
## text starts "Gamble k: ..."; choice = k, 1 the sure $28. As in the authors'
## do-files, k is the 8th character.
gamble <- function(x) as.numeric(substr(x, 8, 8))

## Laboratory experiment, University of Wyoming, 2018. The sample of the paper
## (731) is built as in getcleanDataExperiment.do, getcleanDataBackground.do and
## getcleanDataAll.do: the meal-choice survey without unfinished responses,
## vegetarians, people with food allergies and the "C" treatment (a pilot of
## meal switching), with the two id typos fixed; the background survey (which
## holds the risk question, gender and age) with Progress 100 and Finished, and
## its id typo fixed; then the subjects in both. Three of the 731 (ids 470,
## 619, 620) have no background survey, which is why the paper's Table A1
## reports "Preference for risk" for 728.
ex <-read_qualtrics("Data/Capitan_et_al_2026/original_lab_experiment.csv")
lab_ex <- tibble(id1 = as.numeric(pick(ex, "id1")), id2 = as.numeric(pick(ex, "id2")),
                 finished = pick(ex, "Finished"), veg = pick(ex, "introveg"),
                 allergy = pick(ex, "introallergy"), treat = pick(ex, "Treatment")) %>%
  filter(finished != "False",
         veg != "Yes, I am a vegetarian/vegan",
         allergy != "Yes, I have food allergies") %>%
  mutate(id2 = if_else(id1 == 241, 241, id2),
         id1 = if_else(id2 == 619, 619, id1)) %>%
  filter(treat != "C")
stopifnot(all(lab_ex$id1 == lab_ex$id2), !anyDuplicated(lab_ex$id1))

bg <- read_qualtrics("Data/Capitan_et_al_2026/original_lab_background.csv")
lab_bg <- tibble(id = as.numeric(pick(bg, "Q114")),
                 progress = pick(bg, "Progress"), finished = pick(bg, "Finished"),
                 gender = pick(bg, text = "What is your gender?"),
                 age = pick(bg, text = "What is your age?"),
                 risk = pick(bg, text = "Now we are going to ask you how you feel about risk")) %>%
  filter(progress == "100", finished == "True")
stopifnot(!anyDuplicated(lab_bg$id))

lab <- lab_bg %>% filter(id %in% lab_ex$id1)
stopifnot(nrow(lab) == 728)

## MTurk replication (473 subjects, getcleanDataMturk.do): the same filters.
mt <- read_qualtrics("Data/Capitan_et_al_2026/original_mturk.csv")
mturk <- tibble(finished = pick(mt, "Finished"), veg = pick(mt, "introveg"),
                allergy = pick(mt, "introallergy"), treat = pick(mt, "Treatment"),
                gender = pick(mt, "gender"), age = pick(mt, "age"),
                risk = pick(mt, "riskpref")) %>%
  filter(finished != "False",
         veg != "Yes, I am a vegetarian/vegan",
         allergy != "Yes, I have food allergies",
         treat != "C")
stopifnot(nrow(mturk) == 473)

## gender: 1 female, 0 male, "Other" missing. Age is asked in years.
df <- bind_rows(lab %>% mutate(treatment = "lab"),
                mturk %>% mutate(treatment = "MTurk")) %>%
  filter(risk != "") %>%
  transmute(subject = row_number(),
            age = suppressWarnings(as.numeric(age)),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            task = "EG",
            choice = gamble(risk),
            treatment)
stopifnot(all(df$choice %in% 1:6))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Capitan2026",
         paper = "Capitan et al. 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## The laboratory sessions were at the University of Wyoming ("Participants
## were recruited from the University of Wyoming"), Laramie; the MTurk sample
## is online, so no city and no coordinates.
df <- df %>%
  mutate(country = "United States",
         city = if_else(treatment == "lab", "Laramie", ""),
         lattitude = if_else(treatment == "lab", "41.3149", ""),
         longitude = if_else(treatment == "lab", "-105.5666", ""))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Capitan_et_al_2026/formatted_dataset.csv")
