#### Idan-Tzach, T., Keinan, R. & Bereby-Meyer, Y. (2023).
#### Differentiating passive from active risk taking: the role of self-control and
#### time perspective.
#### Journal of Behavioral Decision Making, 36(5), e2344.
#### https://doi.org/10.1002/bdm.2344
#### Data: OSF uvn6b, view-only link given in the paper ("All data and codes can
#### be found online at this address"); no licence stated. raw_repository/ holds
#### the authors' variable list and code notes. original_dataset.csv keeps only
#### the study, id, sex, age and the 30 DOSPERT items of the four studies: Study 4
#### also recorded a free-text date and the new password some participants typed
#### in its cyber-security task, and neither is copied. The other scales (passive
#### risk taking, self-control, time perspective) are not used.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Four studies, all with the 30-item DOSPERT risk-taking scale (Weber et al.
## 2002 / Blais & Weber 2006), "a 7-point Likert scale ... (1 = extremely
## unlikely, 7 = extremely likely)":
##   Study 1: 150 participants "drawn from a pool of university participants"
##            (raffle in NIS), Hebrew questionnaires - Israel;
##   Study 2: 148 MTurk respondents, questionnaire in English;
##   Study 3: 103 MTurk respondents, in English;
##   Study 4: 191 participants from a university pool (raffle in NIS) - Israel.
## The MTurk studies do not state the respondents' country.
df <- read_csv("Data/IdanTzach_et_al_2023/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 592)

## The authors' variable list: "revDOS = 8-dos. Reversed Dospert scale. This was
## needed for the Hebrew version questionnaire only." The raw items of the two
## Hebrew studies average 4.5, against the paper's DOSPERT mean of 3.5 for
## Study 1 (Table 1), so in Studies 1 and 4 every item is reversed (8 - x)
## before scoring; Studies 2 and 3 are used as they are.
items <- paste0("dos", 1:30)
df <- df %>%
  mutate(across(all_of(items), ~ if_else(study %in% c(1, 4), 8 - .x, .x)))

## Domains with the Blais & Weber (2006) key: ethical 6 9 10 16 29 30;
## gambling 3 8 14; investment 4 12 18; health/safety 5 15 17 20 23 26;
## recreational 2 11 13 19 24 25; social 1 7 21 22 27 28. The site stores each
## domain as the mean per item on 1-7, and doall as the mean of all 30. The
## item order of the files is taken to be the standard one.
dm <- function(d, k) rowMeans(d[, paste0("dos", k)])
df <- df %>%
  mutate(doethic  = dm(., c(6, 9, 10, 16, 29, 30)),
         dogamble = dm(., c(3, 8, 14)),
         doinvest = dm(., c(4, 12, 18)),
         dohealth = dm(., c(5, 15, 17, 20, 23, 26)),
         dorecre  = dm(., c(2, 11, 13, 19, 24, 25)),
         dosocial = dm(., c(1, 7, 21, 22, 27, 28)),
         doall    = dm(., 1:30))

## Questionnaire only, so the rows are quest_only with no task choice.
## gender: 1 = male, 2 = female in the files; on the site 1 is female.
df <- df %>%
  transmute(subject = row_number(),
            age = as.numeric(age),
            gender = case_when(gender == 2 ~ 1, gender == 1 ~ 0),
            task = "quest_only",
            choice = NA_real_,
            treatment = paste("Study", study),
            dosocial, dohealth, doinvest, dogamble, doethic, dorecre, doall,
            country = if_else(study %in% c(1, 4), "Israel", ""))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "IdanTzach2023",
         paper = "Idan-Tzach, Keinan and Bereby-Meyer 2023",
         r = NA_real_)

## The university pool is not named; the corresponding author is at Ben-Gurion
## University, so no city is given.
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/IdanTzach_et_al_2023/formatted_dataset.csv")
