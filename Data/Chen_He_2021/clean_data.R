#### Chen, Y. & He, Y. (2021). Information acquisition and provision in school
#### choice: An experimental study. Journal of Economic Theory, 197, 105345.
#### https://doi.org/10.1016/j.jet.2021.105345
#### Data: openICPSR 119483, https://doi.org/10.3886/E119483
#### (replication_package/data, 27 session files)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Laboratory experiment on school choice mechanisms, 27 independent sessions
## with 324 University of Michigan students recruited through ORSEE. The
## repository ships one Stata file per session, each a panel of 20 periods;
## original_dataset.csv collapses them to one row per subject (session plus
## subject number, taken from period 20, where the lottery answers are stored)
## and keeps the ten rows of the risk task, sex and age. All 324 answered every
## row.
##
## Task: the Holt and Laury list played after the main game, printed in full in
## the online appendix. Option A pays 200 points when a ten-sided die falls in
## the winning range and 160 otherwise, option B 385 or 10; the winning range
## grows from "die is 1" to "die is 1-10" down the rows. choice1 ... choice10
## are 1 for option A and 2 for option B, so choice is the count of twos.
##
## Out of the statistics on the authors' own rule, written out in their
## main.do: the 47 subjects who go back from B to A at any point, and the 16 who
## take A in the last row, where it pays 200 points for sure against B's 385.
## Nine subjects fail both, so 274 remain. The 50 are kept for the download
## only, with inconsistent = 1 and one row per switch to B
## (Data/inconsistent_rows.R). choice = 11 - the row where B starts.
df <- read_csv("Data/Chen_He_2021/original_dataset.csv", show_col_types = FALSE)

b <- as.matrix(select(df, choice1:choice10))
back <- apply(b, 1, function(x) any(x[1:9] == 2 & x[2:10] == 1))

source("Data/inconsistent_rows.R")
B <- (b == 2) * 1
df <- df %>%
  mutate(points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(back | b[, 10] == 1)) %>%
  transmute(subject = row_number(),
            task = "HL",
            points, inconsistent,
            age,
            gender = female,
            country = "United States",
            city = "Ann Arbor") %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k))
stopifnot(sum(df$inconsistent == 0) == 274)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "ChenHe2021",
         paper = "Chen and He 2021")

df$lattitude = '42.2808'
df$longitude = '-83.7430'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chen_He_2021/formatted_dataset.csv")
