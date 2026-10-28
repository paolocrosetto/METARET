#### Gallo, E. & Yan, C. (2023). Efficiency and equilibrium in network games: An
#### experiment. The Review of Economics and Statistics, 105(6), 1515-1529.
#### https://doi.org/10.1162/rest_a_01105
#### Data: Harvard Dataverse 10.7910/DVN/9SRRLX (data_rep_gallo_efficiency.xls)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 234 Amazon Mechanical Turk workers resident in the US, 11 online sessions on
## the authors' UbiquityLab platform, 3-20 June 2013. After 40 rounds of a
## network game they filled in a questionnaire and took the classic Holt-Laury
## test (2.00 / 1.60 against 3.85 / 0.10 USD, high prize with probability
## 0.1 ... 1.0), paid.
## The authors' .xls has no row of column names and holds IP addresses, MTurk
## worker ids and browser details, so it is not copied. Its columns were
## identified from their values and checked against the paper's Table 2:
##  - columns 170-179: the ten HL rows, 1 = A (safe), 2 = B. 212 subjects switch
##    once from A to B, with mean switching row 7.30, as in the paper; 20 switch
##    more than once and 1 never takes B, the 21 the paper excludes; one did
##    not answer;
##  - column 165: female (mean 0.395 against 0.39 in Table 2);
##  - column 163: an age code; minus 19 it gives mean 30.72, sd 10.48 and range
##    18-70, Table 2's 30.72 and 10.48. (The file's own birth-year column is
##    derived from this code and gives an impossible mean age of 44.)
## original_dataset.csv keeps one row per worker: the ten choices, female, age
## and the session date; subjects are row numbers. Only the subjects who switch
## once are kept: there is no questionnaire to keep the others.
## The sample is online, so no city and no coordinates.
df <- read_csv("Data/Gallo_Yan_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 234)

hl <- df %>% select(hl_1:hl_10) %>% as.matrix()
pattern <- apply(hl, 1, paste, collapse = "")
single <- !is.na(pattern) & str_detect(pattern, "^1*2+$")
stopifnot(sum(single) == 212)

df <- df %>%
  mutate(nB = rowSums(hl == 2)) %>%
  filter(single) %>%
  transmute(subject,
            task = "HL",
            ## number of B choices
            choice = nB,
            age,
            gender = female,
            country = "United States",
            bibkey = "Gallo2023",
            paper = "Gallo and Yan 2023")

stopifnot(abs(mean(11 - df$choice) - 7.30) < 0.005)

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gallo_Yan_2023/formatted_dataset.csv")
