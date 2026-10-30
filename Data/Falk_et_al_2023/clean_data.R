#### Falk, A., Becker, A., Dohmen, T., Huffman, D. & Sunde, U. (2023). The
#### preference survey module: A validated instrument for measuring risk, time,
#### and social preferences. Management Science 69(4), 1935-1950.
#### https://doi.org/10.1287/mnsc.2022.4455
#### Data: the journal's replication package (MainSample_Replication.dta and the
#### test-retest and pretest files, MS_Replication.do), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "Four hundred and nine subjects participated in our study. Subjects were
## students from the University of Bonn", two lab sessions "at the Laboratory
## for Experimental Economics at the University of Bonn in winter 2010/2011".
## MainSample_Replication.dta has one row per subject; the file has no age or
## sex. The small test-retest and pretest samples are not used.
##
## The incentivized risk experiment was two price lists of 21 rows each: the
## same lottery, 1,000 points with probability 0.5 and 0 otherwise, against a
## sure 0, 50, ..., 1,000 points, the second list with every sure amount moved
## by a random -5 to +5 points (online appendix A). The file keeps x_risk_av,
## the average over the two lists of the first row in which the sure amount was
## taken (2 to 22). As the lists are the same up to five points, that average
## still pins the certainty equivalent: x.0 when both lists agree (199
## subjects), x.5 when they differ by one row (142). The remaining 54 values
## (3.17, 7.125, ...) can only come from several switch points within a list,
## and 22 means the sure 1,000 was never taken (dominated, 2 subjects); these
## 56 keep a CEPL row with inconsistent = 1, for the download only
## (Data/inconsistent_rows.R), with no choice, since the file keeps only the
## average of their switching rows; their soep still counts. The bounds are in
## the Falk2023 block of
## generate_r.R. Checked on 28.10.2026 from the online appendix, so nothing has
## to be asked of the authors.
##
## v_94, "Risk: willingness to take risks", is the general risk question of
## Dohmen et al. (2011), 0-10, answered by 394 subjects; it goes into soep, on
## the CEPL row where there is one and as a questionnaire-only row otherwise.
df <- read_csv("Data/Falk_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 409, sum(!is.na(df$v_94_general_risk)) == 394)

df <- df %>%
  mutate(cepl = !is.na(x_risk_av) & abs(2 * x_risk_av - round(2 * x_risk_av)) < 1e-6 &
                x_risk_av >= 2 & x_risk_av < 22) %>%
  mutate(inconsistent = as.numeric(!is.na(x_risk_av) & !cepl)) %>%
  filter(!is.na(x_risk_av) | !is.na(v_94_general_risk)) %>%
  transmute(subject = row,
            task = if_else(!is.na(x_risk_av), "CEPL", "quest_only"),
            inconsistent,
            ## for questionnaire-only rows generate_data_for_app.R moves
            ## choice into soep
            choice = case_when(cepl ~ round(2 * x_risk_av) / 2,
                               inconsistent == 1 ~ NA_real_,
                               TRUE ~ v_94_general_risk),
            soep = if_else(!is.na(x_risk_av), v_94_general_risk, NA_real_),
            gender = NA_real_,
            age = NA_real_,
            country = "Germany",
            city = "Bonn")

stopifnot(sum(df$task == "CEPL" & df$inconsistent == 0) == 341, sum(df$inconsistent) == 56)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Falk2023",
         paper = "Falk et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
cepl <- df$task == "CEPL" & df$inconsistent == 0
df$r <- NA_real_
df$r[cepl] <- purrr::pmap_dbl(list(df$bibkey[cepl], df$task[cepl], df$choice[cepl]), get_r)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Falk_et_al_2023/formatted_dataset.csv")
