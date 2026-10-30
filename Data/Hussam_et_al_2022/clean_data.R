#### Hussam, R., Kelley, E. M., Lane, G. & Zahra, F. (2022).
#### The Psychosocial Value of Employment: Evidence from a Refugee Camp.
#### American Economic Review, 112(11), 3694-3724.
#### https://doi.org/10.1257/aer.20211616
#### Data: openICPSR 174781, "Data and Code for: The Psychosocial Value of
#### Employment: Evidence from a Refugee Camp" (downloaded by Liza; the README
#### states the authors have permission to share the data, no licence named).
#### raw_repository/ holds the READMEs and the baseline labelling, correction and
#### build do-files. original_dataset.csv keeps only a row number, sex, age, the
#### nine answers of the risk list and the payout: the processed baseline file
#### also carries respondent, father and household-head name fields (empty in
#### the public file), camp/block names and GPS coordinates, none of which is
#### copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Baseline survey (baseline_processed.dta), before the randomization: "we
## randomize 745 camp residents of working age into three arms" - Rohingya
## refugees in the camps of Cox's Bazar, Bangladesh.
df <- read_csv("Data/Hussam_et_al_2022/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 745)

## The risk game ("incentivized risk preferences (Holt and Laury 2002)"): ten
## buttons in a bag, and in each row the respondent chooses between "Take
## Certain Payout of Tk.100" (1) and "Play game for a chance to win Tk. 300"
## (2), the number of white (winning) buttons rising from 1 to 9 down the rows,
## so the chance of 300 is 10%, 20%, ..., 90% (otherwise 0). One choice is
## played out: riskpref_amount is the payout (300 or 100, 0 for a black
## button). The survey asks the list twice (risk_preference_1-9 and _39-47);
## the authors build their risk_choice from 39-47 (1.build_baseline.do), and
## that list is used here.
## One respondent switched more than once and is out of the statistics, as on
## the rest of the site, kept for the download only with inconsistent = 1 and
## one row per switch to the game (Data/inconsistent_rows.R). No row is
## dominated. choice = number of rows with the certain Tk 100 (0-9) = the row
## where the game starts - 1, as in the authors' risk_choice before they
## negate it.
m <- as.matrix(df[, paste0("risk_preference_", 39:47)])
single <- grepl("^1*2*$", apply(m, 1, paste, collapse = ""))
stopifnot(sum(single) == 744)
source("Data/inconsistent_rows.R")
G <- (m == 2) * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(G)), function(i) switch_points(G[i, ])),
         inconsistent = as.numeric(!single))

## resp_gender: 1 female, 0 male in the processed file ("label define genderl
## 0 Male 1 Female"). Age in years.
df <- df %>%
  transmute(subject = row_number(),
            age = age,
            gender = resp_gender,
            task = "HL",
            points, inconsistent) %>%
  expand_switches(function(k) if_else(is.na(k), 9, k - 1))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Hussam2022",
         paper = "Hussam et al. 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## The refugee camps of Cox's Bazar (Kutupalong area), Bangladesh.
df$country = 'Bangladesh'
df$city = "Cox's Bazar (Rohingya camps)"
df$lattitude = '21.2047'
df$longitude = '92.1630'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hussam_et_al_2022/formatted_dataset.csv")
