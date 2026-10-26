#### Farjam, M. & Kirchkamp, O. (2018). Bubbles in hybrid markets: How
#### expectations about algorithmic trading affect human trading. Journal of
#### Economic Behavior & Organization, 146, 248-269.
#### https://doi.org/10.1016/j.jebo.2017.11.011
#### Data: replication package bubbleData (z-Tree tables in Daten/, Paper.R)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Smith-Suchanek-Williams asset markets with and without algorithmic traders.
## "All sessions were run between July and November 2014 in the laboratory of
## the Friedrich Schiller University Jena"; only men were recruited, to reduce
## within-group variability, so gender is 0 throughout. After the markets
## subjects did "the multiple price list method by Holt and Laury (2002)", ten
## rows with the probability of the high outcome rising 1/10 ... 10/10 (the
## riskTask chunk of Paper.R) -- the shared standard-HL block of generate_r.R.
##
## The z-Tree subjects tables store Risk1 ... Risk10, 1 = option B.
## original_dataset.csv has one row per subject and session (210, the 12
## sessions of the session codes) with the ten choices in order (pattern) and
## their sum (n_risky). 7 subjects who switched more than once are dropped, and
## so are the 3 who chose A even in the last row, where B is the better payoff
## for sure. 200 remain. choice = number of B choices. No age is recorded.
df <- read_csv("Data/Farjam_Kirchkamp_2018/original_dataset.csv",
               col_types = cols(pattern = col_character(), session = col_character()))

stopifnot(nrow(df) == 210, all(nchar(df$pattern) == 10))

df <- df %>%
  filter(str_detect(pattern, "^0*1*$"), n_risky >= 1)

stopifnot(nrow(df) == 200)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = n_risky,
            gender = 0,
            age = NA_real_,
            bibkey = "Farjam2018",
            paper = "Farjam and Kirchkamp 2018")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## University of Jena laboratory; the map shows only the country
df$country = 'Germany'
df$city = 'Jena'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Farjam_Kirchkamp_2018/formatted_dataset.csv")
