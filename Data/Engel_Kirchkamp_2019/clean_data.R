#### Engel, C. & Kirchkamp, O. (2019). How to deal with inconsistent choices on
#### multiple price lists. Journal of Economic Behavior & Organization, 160,
#### 138-157. https://doi.org/10.1016/j.jebo.2019.02.024
#### Data: replication package errorsInVar (data/rawPrep.Rdata, table subL)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The data are those of the public good game with punishment of Engel (2014),
## "conducted in the Cologne Laboratory for Economic Research in 2012" (z-Tree,
## ORSEE), after which participants did a Holt and Laury (2002) list with the
## standard payoffs (2 or 1.60 against 3.85 or 0.10). subL holds the list for
## 72 participants, one row per decision; y = 1 is the risky option B.
## original_dataset.csv has one row per participant with the ten choices in
## order (pattern) and their sum (n_risky).
##
## The paper is about how to use inconsistent lists; the site keeps the
## standard rule: 11 participants who switched more than once are dropped, and
## so are the 2 who chose A even in the last row, where B pays 3.85 for sure.
## 59 remain. choice = number of B choices, the convention of the shared
## standard-HL block of generate_r.R. subL carries no age or gender.
df <- read_csv("Data/Engel_Kirchkamp_2019/original_dataset.csv",
               col_types = cols(pattern = col_character()))

stopifnot(nrow(df) == 72, all(nchar(df$pattern) == 10))

df <- df %>%
  filter(str_detect(pattern, "^0*1*$"), n_risky >= 1)

stopifnot(nrow(df) == 59)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = n_risky,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "EngelKirchkamp2019",
            paper = "Engel and Kirchkamp 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Cologne Laboratory for Economic Research; the map shows only the country
df$country = 'Germany'
df$city = 'Cologne'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Engel_Kirchkamp_2019/formatted_dataset.csv")
