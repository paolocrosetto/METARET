#### Schipper, B. C. (2023). Sex hormones and choice under risk.
#### Journal of Economic Psychology, 96, 102607. https://doi.org/10.1016/j.joep.2023.102607
#### Data: https://faculty.econ.ucdavis.edu/faculty/schipper/research.htm
#### (sexhormones_mens_dr_data.zip; the author asks users to cite the papers listed
####  in hormrisk.do and to send him any paper that uses the data)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## 208 subjects, UC Davis, February-March 2010.
risk  <- read_dta("Data/Schipper_2023/original_risk.dta")
quest <- read_dta("Data/Schipper_2023/original_quest.dta") %>% 
  select(session, subject, gender, age)

## Holt-Laury list in the gain domain (Table 1 of the paper): A = $4.00 / $3.20,
## B = $7.70 / $0.20, i.e. the standard list x 2. Unlike the standard list, the
## probability of the high payoff runs from 0 (row 1, where A dominates) to 0.9
## (row 10). Rows 2-10 are therefore the standard rows 1-9, and a consistent subject
## makes one B choice fewer than in the standard list (which ends with a row where
## B dominates). To use the standard HL bounds, choice = number of B choices + 1,
## capped at 10. The loss-domain list (l1-l10) has no counterpart in METARET.
## Inconsistent (counted until 29.10.2026): the 20 subjects who switch more than
## once (the 2 who took B in row 1, where A dominates, are among them). They
## are kept for the download only, with inconsistent = 1 and one row per switch
## to B (Data/inconsistent_rows.R); a switch at row k is coded like a single
## switch there, min(12 - k, 10).
source("Data/inconsistent_rows.R")
Bg <- (as.matrix(select(risk, num_range("g", 1:10))) == "B") * 1
risk <- risk %>%
  mutate(points = lapply(seq_len(nrow(Bg)), function(i) switch_points(Bg[i, ])),
         inconsistent = as.numeric(!apply(Bg, 1, single_switch) | Bg[, 1] == 1))
stopifnot(sum(risk$inconsistent) == 20)
df <- risk %>% 
  left_join(quest, by = c("session", "subject")) %>% 
  transmute(subject = row_number(),
            points, inconsistent,
            age = as.numeric(age),
            ## 1 - female, 0 - male
            gender = case_when(gender == "Female" ~ 1,
                               gender == "Male" ~ 0,
                               TRUE ~ NA_real_)) %>%
  expand_switches(function(k) if_else(is.na(k), 1, pmin(12 - k, 10)))

# adding task, paper name and bibkey
df <- df %>% 
  mutate(task = "HL",
         bibkey = "Schipper2023",
         paper = "Schipper 2023")

## University of California, Davis
df$country = 'United States'
df$city = 'Davis'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Schipper_2023/formatted_dataset.csv")
