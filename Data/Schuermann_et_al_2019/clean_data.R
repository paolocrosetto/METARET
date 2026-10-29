#### Schürmann, O., Frey, R. & Pleskac, T. J. (2019).
#### Mapping risk perceptions in dynamic risk-taking environments.
#### Journal of Behavioral Decision Making, 32, 94-105. https://doi.org/10.1002/bdm.2098

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Replication package (OSF). Only Study 2 has BART data in the package (the
## folder st1 holds copies of the Study 2 files), so Study 1 is not added.
## Study 2: 90 participants, lab of the Max Planck Institute for Human
## Development (Berlin), classic BART with 30 balloons, max 128 pumps,
## EUR 0.05 per pump, 3 of 30 balloons paid.
## The first balloon's explosion point was manipulated (cond.BART):
## 1 = control (65, as in Lejuez et al.), 2 = low (13), 3 = high (98).
## Only the control condition is kept, as the manipulation changed pumping.
## original_dataset.csv joins the subject-level files classic_quest2.RData and
## BART_summary2.RData. adj.pumps = mean pumps on balloons that did not explode
## (checked against the trial data).
## gender: 2 = female (55 of 90, 61% in the paper), 1 = male.
##
## Questionnaires (classic_quest2.RData, joined into original_dataset.csv on
## 29.10.2026): "their alcohol consumption (using the Alcohol Use Disorders
## Identification Test ...) ... the Zuckermann Sensation Seeking Scale V ... and
## the Barratt Impulsiveness Scale". d_score is the AUDIT total (0-15 here, on
## the 0-40 scale) and BARtotal the Barratt total (44-90, the range of the
## 30-item BIS-11 total, as Fairley2019's BIS); they go into AuditS and BIS.
## SStotal (45-76) is not the 8-item Brief Sensation Seeking Scale the site's
## BSSS column holds (8-40), so it is not used; nor is the nicotine score.
## Everyone answered the questionnaires, so the 60 subjects of the two
## manipulated BART conditions are kept as questionnaire-only rows (as for
## Krull2024).
df <- read_csv("Data/Schuermann_et_al_2019/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = if_else(cond.BART == 1, "BART", "quest_only"),
            choice = if_else(cond.BART == 1, adj.pumps, NA_real_),
            age = as.numeric(age),
            gender = case_when(gender == 2 ~ 1, gender == 1 ~ 0, TRUE ~ NA_real_),
            BIS = BARtotal,
            AuditS = d_score,
            country = "Germany",
            city = "Berlin")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Schuermann2019",
         paper = "Schürmann et al. 2019")

## lab coordinates not added (as for the other new papers)
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = if_else(task == "BART",
                                 purrr::pmap_dbl(list(bibkey, if_else(task == "BART", task, "BART"), coalesce(choice, 0)), get_r),
                                 NA_real_))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Schuermann_et_al_2019/formatted_dataset.csv")
