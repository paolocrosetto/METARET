#### Crosetto, P. & Filippin, A. (2023).
#### Safe options and gender differences in risk attitudes.
#### Journal of Risk and Uncertainty, 66, 19-46.
#### https://doi.org/10.1007/s11166-022-09400-0
#### Data: https://github.com/paolocrosetto/Safe_options_risk_attitudes_gender_data_and_analysis
#### (the whole package is kept in raw_repository/)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## One file per task, between subjects (no subject ID is in two files):
## HL.csv (treatment 1 = HL baseline 179, 2 = HLsafe 165), EG.csv (1 = EGsafe
## baseline 145, 3 = EGnosafe 134) and BRET.csv (1 = BRET baseline 271,
## 2 = BRETsafe 191) -- the 1085 subjects of Table 1.
hl   <- read_csv("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2023/original_HL.csv", show_col_types = FALSE)
eg   <- read_csv("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2023/original_EG.csv", show_col_types = FALSE)
bret <- read_csv("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2023/original_BRET.csv", show_col_types = FALSE)

## Subjects already on the site. Footnote 5: "The data of the baseline BRET are
## the same as in Crosetto and Filippin (2013). Part of the baseline HL and
## EGsafe data are the same as in Crosetto and Filippin (2016) ... The treatment
## conditions are entirely original data." The 88 HL and 88 EG subjects of
## Crosetto2016 are all in the two baselines here, with the same IDs and the
## same answers, so they are dropped, as is the whole BRET baseline. What is
## left: 91 HL extra-session subjects, HLsafe, 57 EGsafe extra-session
## subjects, EGnosafe and BRETsafe.
c16 <- read_dta("Data/Crosetto_FIlippin_Experimental_Economics_2016/original_dataset.dta") %>% as_factor()
hl <- hl %>% filter(!subject %in% c16$subject[c16$treatment == "hl"])
eg <- eg %>% filter(!subject %in% c16$subject[c16$treatment == "eg"])
bret <- bret %>% filter(treatment == 2)
stopifnot(nrow(hl) == 179 - 88 + 165, nrow(eg) == 145 - 88 + 134, nrow(bret) == 191)

## HL: numbersafe is the number of safe (A) choices and is missing for the
## subjects who switched more than once; as in Crosetto2016 they are kept for
## the download only, with inconsistent = 1 (Data/inconsistent_rows.R). The file
## has no row-by-row answers, so their choice is left empty. Nobody kept the
## safe side in the last row. choice = number of risky choices. HLsafe pitches a
## sure amount against a lottery, which this site calls a CEPL; its r bounds are
## in generate_r.R.
hl <- hl %>%
  transmute(subject = as.character(subject), female, soep,
            task = if_else(treatment == 2, "CEPL", "HL"),
            treatment = if_else(treatment == 2, "HLsafe", "HL"),
            choice = 10 - numbersafe,
            inconsistent = as.numeric(is.na(numbersafe)))
stopifnot(!any(hl$choice %in% 0 & hl$task == "HL"))

## EG: eg is the lottery chosen, 1 the safest (the sure 4 euro in EGsafe).
eg <- eg %>%
  transmute(subject = as.character(subject), female, soep, task = "EG",
            treatment = if_else(treatment == 3, "EGnosafe", "EGsafe"),
            choice = eg)

## BRETsafe: perc is the number of boxes collected. Subject numbers restart in
## each session, so the session goes into the ID.
bret <- bret %>%
  transmute(subject = paste0(session, "_", subject), female, soep, task = "BRET",
            treatment = "BRETsafe", choice = perc)

df <- bind_rows(hl, eg, bret) %>%
  ## the app reads subject as a number, so the IDs are renumbered 1..n
  mutate(subject = row_number(),
         gender = female,
         age = NA_real_) %>%
  select(-female)

## The paper and the package report no age.

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Crosetto2023",
         paper = "Crosetto and Filippin 2023")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(inconsistent = coalesce(inconsistent, 0))
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## "The experimental sessions were run in 2014 (BRETsafe, HLsafe, HL extra
## sessions) at the Laboratory of the Max Planck Institute of Economics, and in
## 2016 (EGnosafe and EGsafe extra sessions) at the Laboratory of the Friedrich
## Schiller University, both in Jena, Germany."
df$country = 'Germany'
df$city = 'Jena'
df$lattitude = '50.9271'
df$longitude = '11.5892'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crosetto_Filippin_Journal_Risk_Uncertainty_2023/formatted_dataset.csv")
