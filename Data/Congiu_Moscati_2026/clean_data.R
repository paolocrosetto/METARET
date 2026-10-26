#### Congiu, L. & Moscati, I. (2026).
#### Framing Allais: Is the paradox robust to the pictorial framing of
#### probabilities?
#### Journal of Behavioral and Experimental Economics, 123, 102573.
#### https://doi.org/10.1016/j.socec.2026.102573
#### Data: https://osf.io/h94bm

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## An online experiment on Prolific with 601 participants, all resident in the
## United Kingdom. The published file has one row per subject and 202 columns;
## the few needed here were copied out.
df <- read_csv("Data/Congiu_Moscati_2026/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 601)

## WHAT IS AND IS NOT USED. The paper is about the Allais paradox and whether
## it survives drawing the probabilities as pie charts or grids. That part is
## two binary choices between lottery pairs, (A,B) and (C,D), and what it
## identifies is whether a subject violates expected utility, not how risk
## averse they are; this site has no place for it.
##
## Task 3 of the same session is a Gneezy-Potters allocation and that is the
## row kept here: `investment` is the number of tokens, 0 to 100, put into the
## lottery. The parameters and the check against the realised payoffs are in
## the Congiu2026 block of generate_r.R. It was paid, at 10 tokens to six
## pence, on top of the rest.
##
## The final survey also carries a one-line "is willing to take risks, in
## general", but it sits inside a Big Five battery on a five-point agreement
## scale, not the eleven-point question this site collects, so it is left out.
##
## Gender is the study's own question; the two who answered non-binary and the
## three who declined are left missing, leaving 295 women and 301 men. The
## direction is the usual one: men invest 66.7 tokens against women's 58.5.
df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = as.numeric(`invest.1.player.investment`),
            gender = case_when(str_starts(Gender, "Woman") ~ 1,
                               str_starts(Gender, "Man") ~ 0,
                               TRUE ~ NA_real_),
            age = as.numeric(Age),
            bibkey = "Congiu2026",
            paper = "Congiu and Moscati 2026")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Online on Prolific; every subject reports the United Kingdom as country of
## residence, and no city is recorded.
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Congiu_Moscati_2026/formatted_dataset.csv")
