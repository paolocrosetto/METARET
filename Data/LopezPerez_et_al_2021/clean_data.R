#### López-Pérez, R., Rodriguez-Moral, A. & Vorsatz, M. (2021).
#### Simplified mental representations as a cause of overprecision.
#### Journal of Behavioral and Experimental Economics, 92, 101681.
#### https://doi.org/10.1016/j.socec.2021.101681
#### Data: https://osf.io/wq5nm

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## The experiment is about overprecision in belief elicitation; the risk
## question sits in the questionnaire that closed the session, next to the CRT
## and the demographics. The two files are the two sessions of the same
## experiment, 60 subjects each, run at LINEEX in Valencia.
##
## They are raw z-Tree dumps: row 1-2 are the "globals" table, row 3 is the
## header of the "subjects" table and the subjects follow from row 4. The
## header is read separately and put back on the body.
read_ztree <- function(path) {
  raw <- read_excel(path, col_names = FALSE)
  hdr <- as.character(unlist(raw[3, ]))
  body <- raw[-(1:3), ]
  keep <- which(!is.na(hdr))
  body <- body[, keep]
  names(body) <- hdr[keep]
  body %>% filter(.[[3]] == "subjects")
}

## Every session has one extra terminal for the experimenter, which z-Tree
## records as a subject with Participate = 0 and zeros everywhere. Dropping it
## leaves 60 real subjects per session, which is what the paper reports ("two
## sessions with 60 subjects each"), and removes the only HL = 0 and age = 0
## values -- HL could not be 0, the input box only accepted 1 to 100.
base <- bind_rows(
  read_ztree("Data/LopezPerez_et_al_2021/original_session1.xlsx") %>% mutate(session = 1),
  read_ztree("Data/LopezPerez_et_al_2021/original_session2.xlsx") %>% mutate(session = 2)
) %>%
  mutate(across(c(Subject, experimenter, HL, sex, age), as.numeric)) %>%
  filter(experimenter == 0) %>%
  arrange(session, Subject) %>%
  mutate(subject = row_number())

## Task: the Holt and Laury (2002) 1x lotteries, A paying 2.00 or 1.60 euros and
## B paying 3.85 or 0.10, both with the same probability X of the high prize.
## Rather than the ten-row menu, subjects named the smallest integer X at which
## they would switch from A to B, so `choice` here is that percentage, 1 to 100,
## and not the count of risky choices used for the other HL papers. The bounds
## in generate_r.R are built from those same payoffs and reproduce this site's
## canonical HL bounds when fed the ten menu probabilities.
##
## The question was not incentivised -- the z-Tree payoff stage pays only the
## two belief tasks (Profit = Profit1 + Profit2) and never reads HL -- and the
## paper calls it "a risk aversion index partly based on Holt and Laury (2002)".
## Read et al. 2023 is on the site on the same footing.
##
## sex is coded 0 = Femenino, 1 = Masculino, the opposite of this site's
## convention, hence 1 - sex. Age has no missing values once the experimenter
## row is gone.
df <- base %>%
  transmute(subject,
            task = "HL",
            choice = HL,
            gender = 1 - sex,
            age,
            bibkey = "LopezPerez2021",
            paper = "López-Pérez et al. 2021")

## LINEEX, Universitat de València.
df$country = 'Spain'
df$city = 'Valencia'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/LopezPerez_et_al_2021/formatted_dataset.csv")
