#### Bauer, M., Chytilova, J. & Miguel, E. (2020). Using survey questions to
#### measure preferences: Lessons from an experimental validation in Kenya.
#### European Economic Review, 127, 103493.
#### https://doi.org/10.1016/j.euroecorev.2020.103493
#### Data: "Replication files.7z" (Validation_Dataset.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Validation of the Global Preference Survey with low-income adults from
## Kibera, Nairobi, in the Busara Center lab: two visits a week apart, one
## with incentivized experiments and one with the survey. The qualitative
## risk item of the survey is the GPS / SOEP self-assessment on 0 to 10
## ("using a scale from 0 to 10"), s_risk_qual; it goes into soep.
##
## The task coded is the quantitative risk item of the same survey visit: the
## GPS staircase of Falk et al. (CE_staircase), hypothetical, five binary
## choices between a 50/50 draw of KSh 900 (else 0) and a sure amount. The
## variable labels of s_risk_q74 ... s_risk_q104 give the 31 sure amounts, 30,
## 60, ..., 930: the GPS tree (lottery 300, sure amounts 10 ... 310) times 3.
## The first sure amount is 480, then +-240, +-120, +-60, +-30 (up after the
## lottery, down after the sure amount). Rebuilding each path from those five
## answers gives the authors' s_risk_quant (1 ... 32) for all 123 rows, so
## choice = s_risk_quant and the CE lies in [30 (choice - 1), 30 choice] --
## the same choice-to-r mapping as Bittner2024. 13 people took the draw even
## against a sure 930 (choice 32) and 2 against a sure 900 (choice 31); as for
## Bittner2024 they are kept and coded at the bound r(870).
##
## The incentivized task of the experiment visit is a certainty-equivalent list
## (CEPL). The amounts are in the Online Appendix, printed at the end of the
## working paper (CERGE-EI WP 653, January 2020, kept in raw_repository): 21
## binary choices between a lottery paying KSh 0 or KSh 2,000 with equal
## probability and a sure amount rising in steps of KSh 100 from KSh 0 (row 1)
## to KSh 2,000 (row 21). e_risk_choices holds the 21 answers in row order
## (L = lottery, S = sure amount, from e_risk_q1 ... e_risk_q21).
## Only answers with a single switch from the lottery to the sure amount are
## used (43), plus the 7 who took the lottery in every row. For all of them the
## authors' e_risk is the first row with the sure amount (22 if none), so
## choice = e_risk and the CE lies in [100 (choice - 2), 100 (choice - 1)].
## The 7 all-lottery answers are coded at the bound, as for the staircase.
## Kept for the download only, with inconsistent = 1 and one row per switch to
## the sure amount (Data/inconsistent_rows.R): 34 who took the sure amount in
## every row and 7 more who took a sure KSh 0 over the lottery in row 1
## (dominated), and 29 who switched back and forth (the authors flag only some
## of them in e_risk_incons). Their choice is coded like everyone's: the row
## where the sure amount starts.
##
## 123 rows in the file, 120 people: survey_id 142149 appears four times with
## the same experimental record, risk answer, age and gender, differing only in
## other survey items, and is kept once. gender and age are taken from the
## survey visit (s_gender, s_age); four ages are missing.
df <- read_csv("Data/Bauer_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 120, all(df$risk_qual %in% 0:10), all(df$risk_quant %in% 1:32))

## single switchers (and all-lottery): e_risk must be the first sure-amount row
single <- grepl("^L+S*$", df$e_risk_choices)
stopifnot(sum(single) == 50,
          all(df$e_risk[single] == nchar(sub("S*$", "", df$e_risk_choices[single])) + 1))

source("Data/inconsistent_rows.R")
S_rows <- lapply(strsplit(df$e_risk_choices, ""), function(x) as.numeric(x == "S"))
df <- df %>%
  mutate(points = lapply(S_rows, switch_points),
         cepl_inconsistent = as.numeric(!single))
stopifnot(sum(df$cepl_inconsistent) == 70)

df <- df %>%
  transmute(subject,
            CE_staircase = risk_quant,
            CEPL = e_risk,
            points, cepl_inconsistent,
            soep = risk_qual,
            gender = case_when(s_gender == "Female" ~ 1, s_gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            age = s_age,
            bibkey = "Bauer2020",
            paper = "Bauer et al. 2020") %>%
  pivot_longer(c(CE_staircase, CEPL), names_to = "task", values_to = "choice") %>%
  mutate(inconsistent = if_else(task == "CEPL", cepl_inconsistent, 0)) %>%
  select(-cepl_inconsistent)
## the consistent CEPL choice is e_risk (checked above); the inconsistent ones
## get one row per switch to the sure amount, coded the same way (22 if never)
df <- bind_rows(
  df %>% filter(!(task == "CEPL" & inconsistent == 1)) %>% select(-points),
  df %>% filter(task == "CEPL", inconsistent == 1) %>%
    expand_switches(function(k) if_else(is.na(k), 22, as.numeric(k)))) %>%
  ## staircase rows first, so their seeded draws of r stay as they were before
  ## the CEPL rows were added
  arrange(task != "CE_staircase")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Busara Center, Nairobi; participants from Kibera
df$country = 'Kenya'
df$city = 'Nairobi'
df$lattitude = '-1.3133'
df$longitude = '36.7876'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Bauer_et_al_2020/formatted_dataset.csv")
