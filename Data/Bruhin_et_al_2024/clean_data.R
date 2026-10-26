#### Bruhin, A., Petros, F. & Santos-Pinto, L. (2024).
#### The role of self-confidence in teamwork: experimental evidence.
#### Experimental Economics, 27(3), 687-712.
#### https://doi.org/10.1007/s10683-024-09829-x
#### Data: replication package of the paper

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## The replication package ships the raw z-Tree output of every session and no
## combined file, so the sessions are read and stacked here. Each session left
## two files: <session>_subjects.xlsx, the panel of decisions, and
## <session>_q.xlsx, the questionnaire. There are 40 of each -- the experiment
## ran 20 sessions of 24 subjects at the LABEX in November 2019, split into two
## groups of 12 that z-Tree logged separately -- giving 480 subjects. The paper
## describes 240 of them as the two main treatments and the other 240 as two
## further treatments that rule out mood effects (Appendix J); the BRET is the
## same in all four, so they are pooled.
sessions <- list.files("Data/Bruhin_et_al_2024/original_sessions",
                       pattern = "_subjects[.]xlsx$") %>%
  sub("_subjects[.]xlsx$", "", .)

path <- function(s, suffix) {
  file.path("Data/Bruhin_et_al_2024/original_sessions", paste0(s, suffix))
}

## The risk task is the last of the 20 periods in the subjects table. Period 19
## holds the practice round (the stage is called InstructionsBRETTrial), and
## periods 1 to 18 leave `choice` at -1 because the variable belongs to the
## BRET only. The authors' own do-file takes period 20 in the same way.
bret <- map_dfr(sessions, function(s) {
  read_excel(path(s, "_subjects.xlsx")) %>%
    filter(Period == 20) %>%
    transmute(session = s, Subject = as.numeric(Subject), choice = as.numeric(choice))
})

## The questionnaire files carry the z-Tree file path on the first row and the
## real header on the second.
quest <- map_dfr(sessions, function(s) {
  raw <- read_excel(path(s, "_q.xlsx"), col_names = FALSE)
  hdr <- as.character(unlist(raw[2, ]))
  body <- raw[-(1:2), ]
  names(body) <- hdr
  body %>%
    filter(!is.na(Subject)) %>%
    transmute(session = s, Subject = as.numeric(Subject),
              age = as.numeric(age), gender_fr = gender)
})

## Task: the Bomb Risk Elicitation Task of Crosetto and Filippin (2013) with a
## hundred boxes. The paper does not say so directly, but its payment for the
## risk task runs from CHF 0 to 2.48, and 99 boxes at 2.5 centimes each is
## 2.475 -- so a hundred boxes, which is also what the data show (the largest
## number collected is 99). `choice` is the number of boxes collected, the
## convention this site uses for the BRET.
##
## gender is written out in French; Féminin becomes 1, the site's convention.
df <- bret %>%
  left_join(quest, by = c("session", "Subject")) %>%
  arrange(session, Subject) %>%
  transmute(subject = row_number(),
            task = "BRET",
            choice,
            gender = if_else(gender_fr == "Féminin", 1, 0),
            age,
            bibkey = "Bruhin2024",
            paper = "Bruhin et al. 2024")

## LABEX, University of Lausanne; subjects came from the University of Lausanne
## and the EPFL through ORSEE.
df$country = 'Switzerland'
df$city = 'Lausanne'
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
df %>% write_csv("Data/Bruhin_et_al_2024/formatted_dataset.csv")
