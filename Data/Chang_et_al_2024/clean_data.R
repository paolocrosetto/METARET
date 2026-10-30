#### Chang, H. I., Dariel, A., Reuben, A. & Zhang, H. (2024). Gender identity,
#### salience of information, and tacit coordination: Gender differences in
#### response to strategic uncertainty. Journal of Economic Psychology, 105,
#### 102761. https://doi.org/10.1016/j.joep.2024.102761
#### Data: Mendeley Data, https://data.mendeley.com/datasets/wx6ygc984x
#### (data.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## z-Tree laboratory experiment at a large private university in the United Arab
## Emirates (payments in AED), 20 sessions, 304 students. The main task is a
## stag hunt game played against avatars; the risk elicitation is a separate
## lottery list. original_dataset.csv is data.csv of the repository reduced to
## the session and subject numbers, the eleven list rows and the demographics.
##
## Task: eleven rows, each offering 40 points for sure (option 1) against 60
## points with probability p and 0 otherwise (option 2), p running 0, 0.1, ...,
## 1.0 -- the same payoffs as the stag hunt game, which is why the authors built
## it that way. choice = number of rows in which the gamble was taken, the
## authors' risk_loving.
##
## Out of the statistics, as in the paper: the 13 subjects who switched more
## than once, whose risk attitude the authors say cannot be estimated; in
## addition the 11 subjects with choice == 0, who refused a certain 60 over a
## certain 40 in the last row; no one chose the gamble in the first row, where
## it pays 0 for sure. 280 subjects remain. The 24 are kept for the download
## only, with inconsistent = 1 and one row per switch to the gamble
## (Data/inconsistent_rows.R).
##
## gender is the authors' recode: female = gender - 1, with session 11 subject 4
## corrected to female, as in their do file.
df <- read_csv("Data/Chang_et_al_2024/original_dataset.csv", show_col_types = FALSE)

source("Data/inconsistent_rows.R")
df <- df %>%
  rowwise() %>%
  mutate(rows = list(c_across(starts_with("part2_choice"))),
         switch_row = if (any(rows == 2)) which(rows == 2)[1] else 12L,
         multiple_switching = any(rows[switch_row:11] == 1),
         points = list(switch_points(as.numeric(rows == 2)))) %>%
  ungroup() %>%
  mutate(inconsistent = as.numeric(multiple_switching | !(12L - switch_row) %in% 1:10))
stopifnot(sum(df$inconsistent == 0) == 280, sum(df$inconsistent) == 24)

df <- df %>%
  transmute(subject = session * 100 + Subject,
            task = "HL",
            points, inconsistent,
            age,
            gender = if_else(session == 11 & Subject == 4, 1, gender - 1),
            country = "United Arab Emirates") %>%
  ## choice = number of gamble rows = 12 - the row where the gamble starts
  expand_switches(function(k) if_else(is.na(k), 0, 12 - k))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chang2024",
         paper = "Chang et al. 2024")

## the university is not named in the paper, so the country only
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chang_et_al_2024/formatted_dataset.csv")
