#### Holden, S. T., Tione, S., Tilahun, M. & Katengeza, S. (2025).
#### Elicitation bias in Multiple Price Lists: A field experiment.
#### Journal of Behavioral and Experimental Economics, 119, 102479.
#### https://doi.org/10.1016/j.socec.2025.102479
#### Data: the journal's supplementary replication material
#### (JBEE-Final-Elicitation-Bias-in-Multiple-Price-Lists.dta and
#### JBEE-R2-Final-ElicitationBias031125.do). The do-file is in raw_repository/;
#### original_risk_lists.csv keeps only the three pure risk lists, with sex, year
#### of birth, interview date and the elicitation treatment.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "a field experiment with 906 rural Malawian farmers. With 20 MPLs per
## subject": CLs 1-4 are pure time lists, CLs 5-20 trade a sure near-future
## amount (in one week) against a risky far-future amount. In three of them the
## far future is also one week (fftw == 1), so they are pure risk lists: a sure
## amount against 30,000 MWK with probability 0.10, 0.25 or 0.75, all paid in
## one week. "The subjects are informed that they have a 10% chance of winning
## in the game, and the amount they can win will be influenced by their
## decisions." cemin and cemax bound the certainty equivalent; every list has a
## single switch (the authors' swpa == 1 for all).
## The site keeps one row per subject and task, so one list is used: p = 0.75,
## the one closest to the usual 50/50 lottery (the others are 0.10 and 0.25,
## where probability weighting matters most). The paper is about elicitation
## bias: 183 farmers took a sure 100 MWK over a 75% chance of 30,000, and 110
## kept the lottery against a sure 30,000; both are kept, at the two bounds.
df <- read_csv("Data/Holden_et_al_2025/original_risk_lists.csv", show_col_types = FALSE) %>%
  filter(prob == 0.75)
stopifnot(nrow(df) == 906, !anyDuplicated(df$hhid))

## The sure amounts of the list, in MWK: 100, 200, 400, 1000, 3000, 6000, ...,
## 30000. With cemin = 0 the farmer took even the smallest sure amount (100)
## over the lottery. choice = position of cemin in c(0, those amounts), so the
## CE lies between grid[choice] and grid[choice + 1]; choice 15 (cemin = 30000)
## means the lottery was kept even against a sure 30,000.
grid <- c(0, 100, 200, 400, 1000, seq(3000, 30000, by = 3000))
stopifnot(all(df$cemin %in% grid))

## stptreat: the three elicitation treatments (row-by-row from the top, from
## the bottom, and the Rapid Elicitation with a random starting row), kept as
## the authors' code. Sex1Female0Male: 1 woman. Age from the year of birth and
## the interview year (2024).
df <- df %>%
  transmute(subject = row_number(),
            age = as.numeric(substr(as.character(Date), 1, 4)) - Yearofbirth,
            gender = Sex1Female0Male,
            task = "CEPL",
            choice = match(cemin, grid),
            treatment = paste0("stptreat ", stptreat))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Holden2025",
         paper = "Holden et al. 2025")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "The study is conducted on the East Bank of the Shire River in the Chikwawa
## district in the Southern Region of Malawi."
df$country = 'Malawi'
df$city = 'Chikwawa'
df$lattitude = '-16.0333'
df$longitude = '34.8000'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holden_et_al_2025/formatted_dataset.csv")
