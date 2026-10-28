#### Kagan, E., Leider, S. & Lovejoy, W. S. (2020). Equity contracts and incentive
#### design in start-up teams. Management Science 66(10).
#### https://doi.org/10.1287/mnsc.2019.3439
#### Data: the journal's replication package (data.dta, clusters.dta and the
#### authors' do-files) and the online appendix, kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment on start-up equity contracts with "undergraduate and graduate
## students at a large public midwestern university", the University of
## Michigan (the authors' affiliation; funded by its Rackham School), 354
## participants in all. data.dta has one row per subject and period;
## original_dataset.csv keeps one row per subject (304: the 50 pilot subjects of
## the paper-and-pencil treatment are not in the file).
##
## Task: "Risk preferences were measured using the Holt and Laury (2002)
## method", but only in the OPTOUT (treatment 8) and CLAIM (9) treatments.
## risk is labelled "Risk aversion switching decision" and runs 1-10 with no 0
## and no 11; it is read as the row at which the subject switched to the risky
## option B. choice is the number of B choices, as for the other HL papers:
## B from row risk to row 10, so choice = 11 - risk. Subjects with several
## switching points have risk missing ("6 subjects in OPTOUT and 9 subjects in
## CLAIM", online appendix), leaving 129 answers. The payoffs are not given (the
## software is "available from the authors upon request"); the standard HL list
## is assumed. That is harmless: with u = x^r the r bounds of an HL list do not
## change when all payoffs are scaled, only the HL ratios matter. Switch row,
## not number of safe choices (checked 28.10.2026): the label says "switching
## decision"; 10 subjects have risk = 10, which as a count would mean the
## dominated A in row 10, yet the appendix says inconsistent answers were
## dropped; and no value 11 (never switching, dominated) is left.
##
## sex: 0 = female. age 0 (one subject) is missing.
df <- read_csv("Data/Kagan_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 304, sum(!is.na(df$risk)) == 129,
          all(df$treatment[!is.na(df$risk)] %in% c(8, 9)))

df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject = id,
            task = "HL",
            choice = 11 - risk,
            gender = if_else(sex == 0, 1, 0),
            age = if_else(age > 0, age, NA_real_),
            country = "United States",
            city = "Ann Arbor")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Kagan2020",
         paper = "Kagan et al. 2020")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kagan_et_al_2020/formatted_dataset.csv")
