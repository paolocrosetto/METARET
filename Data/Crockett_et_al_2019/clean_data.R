#### Crockett, S., Duffy, J. & Izhakian, Y. (2019). An experimental test of the
#### Lucas asset pricing model. The Review of Economic Studies.
#### https://doi.org/10.1093/restud/rdy035
#### Data: the journal's supplementary material (Data&Programs.zip: raw and
#### transformed data, R files, z-Tree and Willow programs; OnlineAppendix.pdf),
#### kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "Subjects are undergraduate students from the University of Pittsburgh";
## nobody took part in more than one session. Two experiments, each with its own
## subjects: 20 sessions of the market experiment, 12 subjects each, the
## Holt-Laury task run only in sessions 7-20 (2009-2014, hl_[date] files); and 6
## sessions of the individual choice experiment, October-November 2011. The
## authors' all_hl.csv and choice_hl.csv have one row per subject; they are stacked
## in original_dataset.csv (experiment, session, subject).
##
## Task: Holt and Laury (2002) at the end of each session, "Option A: $6.00 ...
## OR $4.80; Option B: $11.55 ... OR $0.30" with the high payoff in 10, 20, ...,
## 100 of 100 draws, the Holt-Laury table times 3, which keeps its CRRA
## intervals; "the computer program will randomly select 1 of the 10 decisions"
## for payment. HL = "the number of high-variance choices" (B), which the raw
## files confirm; OneSwitch = 1 if the subject switched at most once. Only those
## are kept: 150 of the 168 market subjects with the task and 65 of the 72 in the
## individual choice experiment. choice = HL.
##
## Gender and age are not in the files.
df <- read_csv("Data/Crockett_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 312, sum(!is.na(df$HL)) == 240,
          sum(df$OneSwitch == 1) == 215, all(!is.na(df$HL[df$OneSwitch == 1])))

df <- df %>%
  filter(OneSwitch == 1) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = HL,
            age = NA_real_,
            gender = NA_real_,
            country = "United States",
            city = "Pittsburgh",
            bibkey = "CrockettDuffy2019",
            paper = "Crockett et al. 2019")

## the map is drawn by country; the coordinates are those of the university
df$lattitude = '40.4444'
df$longitude = '-79.9608'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Crockett_et_al_2019/formatted_dataset.csv")
