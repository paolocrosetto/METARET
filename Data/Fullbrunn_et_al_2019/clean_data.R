#### Füllbrunn, S., Janssen, D.-J. & Weitzel, U. (2019). Risk aversion and
#### overbidding in first price sealed bid auctions: New experimental evidence.
#### Economic Inquiry, 57(1), 631-647. https://doi.org/10.1111/ecin.12716
#### Data: Radboud Data Repository 10.34973/bw4c-bk20 (FJW Auction Data (anonym).xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 184 students in 8 sessions "from April to June of 2015 at the IMR Experimental
## Laboratory, Nijmegen School of Management, Radboud University, the
## Netherlands". Before 50 first-price auctions each subject played the dynamic
## BRET (Crosetto and Filippin 2013): 100 boxes, one collected per second until
## the subject stops, EUR 0.10 per box, nothing if the bomb is among them.
## bret_i is the number of boxes collected; the file has one row per subject and
## auction, and bret_i, age and sex are the same in every row, so
## original_dataset.csv keeps one row per subject (bs_sub_id).
## d_male: 1 = man.
df <- read_csv("Data/Fullbrunn_et_al_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 184, all(df$bret_i %in% 0:100))

df <- df %>%
  transmute(subject = bs_sub_id,
            task = "BRET",
            choice = bret_i,
            age,
            gender = if_else(d_male == 1, 0, 1),
            country = "Netherlands",
            city = "Nijmegen",
            bibkey = "Fullbrunn2019",
            paper = "Füllbrunn et al. 2019")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '51.8126'
df$longitude = '5.8372'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fullbrunn_et_al_2019/formatted_dataset.csv")
