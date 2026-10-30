#### Mimra, W. & Waibel, C. (2025). Contracting Environments and Efficiency in
#### Markets with Hidden Information: An Experiment. American Economic Journal:
#### Microeconomics, 17(3), 35-74. https://doi.org/10.1257/mic.20170293
#### Data: openICPSR 201307 (z-Tree exports Data/s1 ... s17, table subjects)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Students in the ETH Decision Science Laboratory, Zurich: 15 sessions in
## March-May 2016 and 2 control sessions in July 2018, 488 subjects in the files.
## After the market experiment a Holt-Laury list (z-Tree LOTTERYA = 8 / 6.4 and
## LOTTERYB = 15.4 / 0.4 points, the original proportions; the paper reports
## doubled HL amounts in CHF), one row paid. riskChoice[k]: 1 = B, as in the
## authors' consistency check.
## Sessions 9 and 12 belong to treatment 6, which has no label in the authors'
## code and is not reported; without them the files give the paper's sample
## exactly (424 subjects, 59.91% women, mean age 22.50), and only that sample is
## used. Of these 424, 349 switch once from A to B (B in row 10), against the
## 399 consistent subjects the paper reports; the authors' own definition
## (non-decreasing choices, B in row 10) gives 349 in their files as well. The
## other 75 are kept for the download only, with inconsistent = 1 and one row
## per switch to B (Data/inconsistent_rows.R); there is no general risk
## question (the five domain questions use a 0-3 scale).
## original_dataset.csv keeps session, the ten choices, sex (1 = female) and
## age for all 488; subjects are row numbers.
df <- read_csv("Data/Mimra_Waibel_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 488)

df <- df %>% filter(!session %in% c(9, 12))
stopifnot(nrow(df) == 424)

hl <- df %>% select(hl_1:hl_10) %>% as.matrix()
pattern <- apply(hl, 1, paste, collapse = "")
single <- str_detect(pattern, "^0*1+$")

source("Data/inconsistent_rows.R")
df <- df %>%
  mutate(points = lapply(seq_len(nrow(hl)), function(i) switch_points(hl[i, ])),
         inconsistent = as.numeric(!single)) %>%
  transmute(subject,
            task = "HL",
            points, inconsistent,
            age,
            gender = female,
            country = "Switzerland",
            city = "Zurich",
            bibkey = "Mimra2025",
            paper = "Mimra and Waibel 2025") %>%
  ## choice = number of B choices = 11 - the row where B starts
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))

stopifnot(sum(df$inconsistent == 0) == 349, n_distinct(df$subject[df$inconsistent == 1]) == 75)

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '47.3769'
df$longitude = '8.5417'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Mimra_Waibel_2025/formatted_dataset.csv")
