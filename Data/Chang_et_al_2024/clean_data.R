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
## Dropped, as in the paper: the 13 subjects who switched more than once, whose
## risk attitude the authors say cannot be estimated. Dropped in addition: the
## 11 subjects with choice == 0, who refused a certain 60 over a certain 40 in
## the last row; no one chose the gamble in the first row, where it pays 0 for
## sure. 280 subjects remain.
##
## gender is the authors' recode: female = gender - 1, with session 11 subject 4
## corrected to female, as in their do file.
df <- read_csv("Data/Chang_et_al_2024/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  rowwise() %>%
  mutate(rows = list(c_across(starts_with("part2_choice"))),
         switch_row = if (any(rows == 2)) which(rows == 2)[1] else 12L,
         multiple_switching = any(rows[switch_row:11] == 1)) %>%
  ungroup() %>%
  filter(!multiple_switching) %>%
  mutate(choice = 12L - switch_row) %>%
  filter(choice >= 1, choice <= 10) %>%
  transmute(subject = session * 100 + Subject,
            task = "HL",
            choice,
            age,
            gender = if_else(session == 11 & Subject == 4, 1, gender - 1),
            country = "United Arab Emirates")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chang2024",
         paper = "Chang et al. 2024")

## the university is not named in the paper, so the country only
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chang_et_al_2024/formatted_dataset.csv")
