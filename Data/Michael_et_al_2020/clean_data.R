#### Michael, J., Gutoreva, A., Lee, M. H., Tan, P. N., Bruce, E. M., Szekely, M.,
#### Ankush, T., Sakaguchi, H., Walasek, L. & Ludvig, E. A. (2020). Decision-makers
#### use social information to update their preferences but choose for others as they
#### do for themselves. Journal of Behavioral Decision Making, 33(3), 270-286.
#### https://doi.org/10.1002/bdm.2163
#### Data: https://osf.io/8ty5m (Experiment 3: adjbart.csv, Compiled.csv,
#### QuestionnaireScore.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Experiment 3 of the paper: 79 students at the University of Warwick (UK), lab,
## PsychoPy BART with a maximum of 128 pumps, paid by pumps. Only the individual
## baseline block is used (10 balloons, own money, no partner); the four partner
## and team conditions that follow are treatments and are not added.
## original_dataset.csv keeps one row per participant: age, sex, the adjusted BART
## score of the baseline block (mean pumps on the balloons that did not burst) and
## the answers to the 40-item DOSPERT (Weber, Blais & Betz 2002) on the paper's
## 1-5 scale, taken item by item from QuestionnaireScore.xlsx. Participant k of the
## questionnaire sheet is Sub_id k of the BART file, as in the authors' Bart4.R.
## Subject 35 has two sets of baseline trials in the file and is dropped.
##
## DOSPERT: domain means over the items each participant answered (27 of 3,160
## answers are missing; the authors' own sheet counts them as 0), for the social,
## recreational, gambling, health, ethical and investment domains, and doall = the
## mean of all answered items. The other DOSPERT data in METARET use the 1-7 scale,
## so the 1-5 means are rescaled linearly: 1 + (x - 1) * 6 / 4.
## female: 1 = F, 0 = M, NA for the one other answer; 4 ages are missing.
df <- read_csv("Data/Michael_et_al_2020/original_dataset.csv", show_col_types = FALSE) %>%
  filter(subject != 35)

items <- df %>% select(starts_with("q"))
dom <- sub(".*_", "", names(items))
dmean <- function(d) rowMeans(as.matrix(items[, dom %in% d]), na.rm = TRUE)
to7 <- function(x) 1 + (x - 1) * 6 / 4

df <- df %>%
  transmute(subject,
            task = "BART",
            choice = bart_adj,
            age,
            gender = female,
            dosocial = to7(dmean("S")[match(subject, df$subject)]),
            dorecre  = to7(dmean("R")[match(subject, df$subject)]),
            dogamble = to7(dmean("G")[match(subject, df$subject)]),
            dohealth = to7(dmean("H")[match(subject, df$subject)]),
            doethic  = to7(dmean("E")[match(subject, df$subject)]),
            doinvest = to7(dmean("I")[match(subject, df$subject)]),
            doall    = to7(dmean(c("S", "R", "G", "H", "E", "I"))[match(subject, df$subject)]),
            country = "United Kingdom")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Michael2020",
         paper = "Michael et al. 2020")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Michael_et_al_2020/formatted_dataset.csv")
