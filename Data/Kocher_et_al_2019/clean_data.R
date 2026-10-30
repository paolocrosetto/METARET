#### Kocher, M. G., Lucks, K. E. & Schindler, D. (2019). Unleashing Animal
#### Spirits: Self-Control and Overpricing in Experimental Asset Markets. The
#### Review of Financial Studies, 32(6), 2149-2178.
#### https://doi.org/10.1093/rfs/hhy109
#### Data: the journal's online appendix (Data.zip: Dataset_raw.dta); the price
#### list is shown only in a screenshot in Online Appendix.pdf (p. 21)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 400 students in the MELESSA lab, University of Munich, 21 sessions with 40
## asset markets (2013-2015). Before the market they faced ten rows of a lottery
## paying 0.20 or 4.20 EUR with probability 1/2 (expected value 2.20) against a
## sure 0.60, 1.00, ..., 4.20 EUR, one row paid. The file keeps only amount1, the
## last sure amount at which the lottery was still preferred (0.20 if the sure
## amount was taken in row 1), so the certainty equivalent lies between amount1
## and amount1 + 0.40; its mean, 2.14, matches the paper's 2.2 and 2.15 by
## treatment. choice = the row of the first sure amount taken,
## (amount1 - 0.20) / 0.40 + 1. One subject kept the lottery even against a sure
## 4.20 EUR (dominated): kept for the download only, with inconsistent = 1 and
## choice 11 (Data/inconsistent_rows.R); the file has no row-by-row answers, so
## multiple switching cannot be seen.
## risk is a self-assessment, "How risk loving" from 1 (very much) to 6 (not at
## all); it is reversed and rescaled to 0-10 and kept in soep.
## The additional experiment (welfare.dta) asks for investments in an asset
## whose value is unknown, which is ambiguity, and is not used.
## original_dataset.csv keeps one row per subject: session, treatment, Stroop
## condition, amount1, the self-assessment, sex and age.
df <- read_csv("Data/Kocher_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 400, all(round(df$ce_lower, 1) %in% round(seq(0.2, 4.2, 0.4), 1)))

df <- df %>%
  mutate(row = round((ce_lower - 0.2) / 0.4) + 1,
         soep_risk = (6 - risk_self) / 5 * 10,
         dominated = row == 11) %>%
  transmute(subject,
            task = "CEPL",
            choice = row,
            inconsistent = as.numeric(dominated),
            soep = soep_risk,
            age,
            gender,
            country = "Germany",
            city = "Munich",
            bibkey = "Kocher2019",
            paper = "Kocher et al. 2019")

stopifnot(sum(df$inconsistent == 0) == 399)

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '48.1351'
df$longitude = '11.5820'

source("Data/generate_r.R")
cepl <- df$inconsistent == 0
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kocher_et_al_2019/formatted_dataset.csv")
