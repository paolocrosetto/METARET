#### Vieider, F. M. (2024).
#### Decisions under uncertainty as Bayesian inference on choice options.
#### Management Science, 70(12), 9014-9030. https://doi.org/10.1287/mnsc.2023.00265
#### Data: replication package on OSF (rqku5), part 3 "Risk and Mirrors"
#### (section 3.3), data_mirrors.csv. original_dataset.csv keeps only the risk
#### treatment and its prospect 8; the mirror treatment (deterministic boxes, no
#### risk) and the other eight prospects are not copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "The experiment was conducted in an introductory class of Behavioural
## Economics at Ghent University using a between-subject design ... 10 subjects
## were randomly selected to play one of their decisions for real money ... 133
## students submitted complete responses". 61 of them were in the risk
## treatment (risk == 1 in the package), 72 in the mirror treatment.
## Each subject made 200 randomised binary choices between a wager (100 boxes,
## some paying the high and the rest the low outcome) and 100 boxes with one
## sure amount; nine wagers (Table 1 of the paper), 20 choices repeated.
## Prospect 8, EUR 32 with 0.58 or else 0, is the only one with a zero low
## outcome and a middle probability, so it is used: sure amounts EUR 6 ... 25 in
## steps of 1, offered one at a time in random order (22-23 choices each).
df <- read_csv("Data/Vieider_2024/original_dataset.csv", show_col_types = FALSE)
stopifnot(n_distinct(df$id) == 61, all(df$high == 32), all(df$low == 0), all(df$prob == 0.58))

## The choices are not a list, so there is no single switching point: 42 of the
## 61 subjects choose the wager at some sure amount above one where they took
## the sure amount. The certainty equivalent is therefore counted: the share of
## wager choices at each sure amount (repeated amounts averaged) summed over the
## 20 amounts and added to 5.5, the lower end of the step below EUR 6. A
## subject who always takes the wager gets CE 25.5, one who never does 5.5; a
## single switch from wager to sure amount at s gives CE s - 0.5, the middle of
## the switching interval. Six subjects never saw one of the 20 amounts; its
## share is the mean of the two neighbouring amounts (the nearer one at an end).
shares <- df %>%
  group_by(id, sure) %>%
  summarise(share = mean(choice_risky), .groups = "drop") %>%
  complete(id, sure = 6:25) %>%
  arrange(id, sure) %>%
  group_by(id) %>%
  mutate(share = coalesce(share, (lag(share) + lead(share)) / 2, lag(share), lead(share))) %>%
  summarise(ce = 5.5 + sum(share), .groups = "drop")
stopifnot(nrow(shares) == 61, !anyNA(shares$ce))

## The package has no age or gender.
df <- shares %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = ce)

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Vieider2024",
         paper = "Vieider 2024")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Ghent University, Faculty of Economics and Business Administration.
df$country = 'Belgium'
df$city = 'Ghent'
df$lattitude = '51.0452'
df$longitude = '3.7290'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Vieider_2024/formatted_dataset.csv")
