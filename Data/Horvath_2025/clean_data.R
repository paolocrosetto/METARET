#### Horvath, G. (2025). Network formation and efficiency in linear-quadratic
#### games: An experimental study. The Economic Journal, 135(665), 212-234.
#### https://doi.org/10.1093/ej/ueae073
#### Data: replication package (Data and software/Main experiment)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment on network formation and effort in a linear-quadratic
## game, run through oTree between July and September 2022 with subjects
## recruited on Prolific. 420 participants in groups of five or nine, 30 periods
## each, 3.50 GBP show-up fee plus variable earnings.
##
## The closing survey carried "an incentivized risk-aversion measure (based on
## Gneezy and Potters, 1997)", and the exact wording is in the oTree page
## shipped with the package (Survey3.html): 100 points, invest Y, the return is
## 2.5*Y or 0 by a coin toss, keep 100 - Y either way. The parameters are in the
## Horvath2025 block of generate_r.R. The paper itself only cites Gneezy and
## Potters and refers to an appendix, so the software is the source here.
##
## original_dataset.csv is the subject level extract of
## processeddata_T1_T5.csv: the amount invested, the authors' gender and age
## fields and the self-reported nationality. The 30 periods of network play, the
## cognitive reflection test and the dictator game are not used.
## gender: the oTree field codes 0 = Male, 1 = Female, 2 = Prefer not to say,
## so it is recoded to the site's 1 = female, 0 = male, with 2 as missing.
## country: NOT SET. This was a Prolific study with no stated country
## restriction; nationality is recorded per subject and spans dozens of
## countries, but nationality is not where the subject took part, so it would
## be wrong to put it on the map. Same treatment as Chan2024 and Snowberg2021's
## online pools.
df <- read_csv("Data/Horvath_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 420, all(df$riskaversion >= 0 & df$riskaversion <= 100))

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = riskaversion,
            age,
            gender = case_when(gender == 1 ~ 1, gender == 0 ~ 0, TRUE ~ NA_real_),
            country = NA_character_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Horvath2025",
         paper = "Horvath 2025")

## online experiment, so no coordinates
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Horvath_2025/formatted_dataset.csv")
